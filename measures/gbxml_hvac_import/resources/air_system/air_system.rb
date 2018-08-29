require 'rexml/document'
require 'openstudio'
require_relative '../model/helpers'

class AirSystem

  def self.create_air_system_from_xml(model, std, xml)

    air_loop_hvac = OpenStudio::Model::AirLoopHVAC.new(model)

    unless xml.elements['Name'].nil?
      air_loop_hvac.setName(xml.elements['Name'].text)
    end

    # Add the fan
    unless xml.elements['Fan'].nil?
      fan_type = xml.elements['Fan'].attributes['FanType']
      if fan_type == "VariableVolume"
        fan = OpenStudio::Model::FanVariableVolume.new(model)
        fan.addToNode(air_loop_hvac.supplyInletNode)
      elsif fan_type == "ConstantVolume"
        fan = OpenStudio::Model::FanConstantVolume.new(model)
        fan.addToNode(air_loop_hvac.supplyInletNode)
      end
    end

    # Add the heating coil
    unless xml.attributes['heatingCoilType'].nil? or xml.attributes['heatingCoilType'] == "None"
      heating_coil_type = xml.attributes['heatingCoilType']
      if heating_coil_type == "ElectricResistance"
        create_coil_heating_electric(model, air_loop:air_loop_hvac)
      elsif heating_coil_type == "Furnace"
        create_coil_heating_gas(model, air_loop:air_loop_hvac)
      elsif heating_coil_type == "HotWater"
        hydronic_loop_id = xml.elements['HydronicLoopId[@coilType="Heating"]']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            hw_loop = Helpers.get_plant_loop_by_id(model, hydronic_loop_id_ref)
            if hw_loop
              create_coil_heating_water(model, hw_loop, air_loop:air_loop_hvac)
            end
          end
        end
      end
    end

    # Add the cooling coil
    unless xml.attributes['coolingCoilType'].nil? or xml.attributes['coolingCoilType'] == "None"
      cooling_coil_type = xml.attributes['coolingCoilType']
      if cooling_coil_type == "DX"
        create_coil_cooling_dx_single_speed(model, air_loop:air_loop_hvac)
      elsif cooling_coil_type == "ChilledWater"
        hydronic_loop_id = xml.elements['HydronicLoopId[@coilType="Cooling"]']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            chw_loop = Helpers.get_plant_loop_by_id(model, hydronic_loop_id_ref)
            if chw_loop
              create_coil_cooling_water(model, chw_loop, air_loop:air_loop_hvac)
            end
          end
        end
      end
    end

    # Add the preheat coil
    unless xml.attributes['preheatCoilType'].nil? or xml.attributes['preheatCoilType'] == "None"
      preheating_coil_type = xml.attributes['preheatCoilType']
      if preheating_coil_type == "ElectricResistance"
        create_coil_heating_electric(model, air_loop:air_loop_hvac)
      elsif preheating_coil_type == "Furnace"
        create_coil_heating_gas(model, air_loop:air_loop_hvac)
      elsif preheating_coil_type == "HotWater"
        hydronic_loop_id = xml.elements['HydronicLoopId[@coilType="preheat"]']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            hw_loop = Helpers.get_plant_loop_by_id(model, hydronic_loop_id_ref)
            if hw_loop
              create_coil_heating_water(model, hw_loop, air_loop:air_loop_hvac)
            end
          end
        end
      end
    end

    # Add the OA System
    oa_controller = OpenStudio::Model::ControllerOutdoorAir.new(model)
    oa_system = OpenStudio::Model::AirLoopHVACOutdoorAirSystem.new(model, oa_controller)
    oa_system.addToNode(air_loop_hvac.supplyInletNode)

    # Add the Heat Exchanger
    heat_exchanger_element = xml.elements['HeatExchanger']
    unless heat_exchanger_element.nil?
      hx_type = heat_exchanger_element.attributes['heatExchangerType']
      unless hx_type.nil? or hx_type == 'None'
        std.air_loop_hvac_apply_energy_recovery_ventilator(air_loop_hvac)
      end
    end

    # Add an SPM
    spm = OpenStudio::Model::SetpointManagerWarmest.new(model)
    spm.addToNode(air_loop_hvac.supplyOutletNode)

    unless xml.attributes['id'].nil?
      air_loop_hvac.additionalProperties.setFeature('id', xml.attributes['id'])
    end

    unless xml.elements['CADObjectId'].nil?
      air_loop_hvac.additionalProperties.setFeature('CADObjectId', xml.elements['CADObjectId'].text)
    end

  end

  def self.create_coil_cooling_dx_single_speed(model,
                                          air_loop: nil,
                                          name: "1spd DX Clg Coil",
                                          schedule: nil,
                                          type: nil,
                                          cop: nil)

    clg_coil = OpenStudio::Model::CoilCoolingDXSingleSpeed.new(model)

    # add to air loop if specified
    clg_coil.addToNode(air_loop.supplyInletNode) if !air_loop.nil?

    # set coil name
    clg_coil.setName(name)

    coil_availability_schedule = model.alwaysOnDiscreteSchedule

    clg_coil.setAvailabilitySchedule(coil_availability_schedule)

    # set coil cop
    if !cop.nil?
      clg_coil.setRatedCOP(cop)
    end

    return clg_coil
  end

  def self.create_coil_cooling_water(model,
                                chilled_water_loop,
                                air_loop: nil,
                                name: "Clg Coil",
                                schedule: nil,
                                design_inlet_water_temperature: nil,
                                design_inlet_air_temperature: nil,
                                design_outlet_air_temperature: nil)

    clg_coil = OpenStudio::Model::CoilCoolingWater.new(model)

    # add to chilled water loop
    chilled_water_loop.addDemandBranchForComponent(clg_coil)

    # add to air loop if specified
    clg_coil.addToNode(air_loop.supplyInletNode) if !air_loop.nil?

    # set coil name
    if name.nil?
      clg_coil.setName("Clg Coil")
    else
      clg_coil.setName(name)
    end

    coil_availability_schedule = model.alwaysOnDiscreteSchedule

    clg_coil.setAvailabilitySchedule(coil_availability_schedule)

    # rated temperatures
    if !design_inlet_water_temperature.nil?
      clg_coil.setDesignInletWaterTemperature(design_inlet_water_temperature)
    else # use loop design exit temperature
      design_inlet_water_temperature = chilled_water_loop.sizingPlant.designLoopExitTemperature
      clg_coil.setDesignInletWaterTemperature(design_inlet_water_temperature)
    end
    clg_coil.setDesignInletAirTemperature(design_inlet_air_temperature) if !design_inlet_air_temperature.nil?
    clg_coil.setDesignOutletAirTemperature(design_outlet_air_temperature) if !design_outlet_air_temperature.nil?

    # defaults
    clg_coil.setHeatExchangerConfiguration('CrossFlow')

    # coil controller properties
    # NOTE: These inputs will get overwritten if addToNode or addDemandBranchForComponent is called on the htg_coil object after this
    clg_coil_controller = clg_coil.controllerWaterCoil.get
    clg_coil_controller.setName("#{clg_coil.name.to_s} Controller")
    clg_coil_controller.setAction("Reverse")
    clg_coil_controller.setMinimumActuatedFlow(0.0)

    return clg_coil
  end

  def self.create_coil_heating_electric(model,
                                   air_loop: nil,
                                   name: "Electric Htg Coil",
                                   schedule: nil,
                                   nominal_capacity: nil,
                                   efficiency: 1.0)

    htg_coil = OpenStudio::Model::CoilHeatingElectric.new(model)

    # add to air loop if specified
    htg_coil.addToNode(air_loop.supplyInletNode) if !air_loop.nil?

    # set coil name
    htg_coil.setName(name)

    coil_availability_schedule = model.alwaysOnDiscreteSchedule

    htg_coil.setAvailabilitySchedule(coil_availability_schedule)

    # set coil eff
    htg_coil.setEfficiency(efficiency) if !efficiency.nil?

    return htg_coil
  end

  def self.create_coil_heating_gas(model,
                              air_loop: nil,
                              name: "Gas Htg Coil",
                              schedule: nil,
                              nominal_capacity: nil,
                              efficiency: 0.80)

    htg_coil = OpenStudio::Model::CoilHeatingGas.new(model)

    # add to air loop if specified
    htg_coil.addToNode(air_loop.supplyInletNode) if !air_loop.nil?

    # set coil name
    htg_coil.setName(name)

    coil_availability_schedule = model.alwaysOnDiscreteSchedule

    htg_coil.setAvailabilitySchedule(coil_availability_schedule)

    # set coil eff
    htg_coil.setGasBurnerEfficiency(efficiency) if !efficiency.nil?

    return htg_coil
  end

  def self.create_coil_heating_water(model,
                                hot_water_loop,
                                air_loop: nil,
                                name: "Htg Coil",
                                schedule: nil,
                                rated_inlet_water_temperature: nil,
                                rated_outlet_water_temperature: nil,
                                rated_inlet_air_temperature: 16.6,
                                rated_outlet_air_temperature: 32.2,
                                controller_convergence_tolerance: 0.1)

    htg_coil = OpenStudio::Model::CoilHeatingWater.new(model)

    # add to hot water loop
    hot_water_loop.addDemandBranchForComponent(htg_coil)

    # add to air loop if specified
    htg_coil.addToNode(air_loop.supplyInletNode) if !air_loop.nil?

    # set coil name
    if name.nil?
      htg_coil.setName("Htg Coil")
    else
      htg_coil.setName(name)
    end

    coil_availability_schedule = model.alwaysOnDiscreteSchedule

    htg_coil.setAvailabilitySchedule(coil_availability_schedule)

    # rated water temperatures, use hot water loop temperatures if defined
    if rated_inlet_water_temperature.nil?
      rated_inlet_water_temperature = hot_water_loop.sizingPlant.designLoopExitTemperature
      htg_coil.setRatedInletWaterTemperature(rated_inlet_water_temperature)
    else
      htg_coil.setRatedInletWaterTemperature(rated_inlet_water_temperature)
    end
    if rated_outlet_water_temperature.nil?
      rated_outlet_water_temperature = rated_inlet_water_temperature - hot_water_loop.sizingPlant.loopDesignTemperatureDifference
      htg_coil.setRatedOutletWaterTemperature(rated_outlet_water_temperature)
    else
      htg_coil.setRatedOutletWaterTemperature(rated_outlet_water_temperature)
    end

    # rated air temperatures
    if rated_inlet_air_temperature.nil?
      htg_coil.setRatedInletAirTemperature(16.6)
    else
      htg_coil.setRatedInletAirTemperature(rated_inlet_air_temperature)
    end
    if rated_outlet_air_temperature.nil?
      htg_coil.setRatedOutletAirTemperature(32.2)
    else
      htg_coil.setRatedOutletAirTemperature(rated_outlet_air_temperature)
    end

    # coil controller properties
    # NOTE: These inputs will get overwritten if addToNode or addDemandBranchForComponent is called on the htg_coil object after this
    htg_coil_controller = htg_coil.controllerWaterCoil.get
    htg_coil_controller.setName("#{htg_coil.name.to_s} Controller")
    htg_coil_controller.setMinimumActuatedFlow(0.0)
    htg_coil_controller.setControllerConvergenceTolerance(controller_convergence_tolerance) if !controller_convergence_tolerance.nil?

    return htg_coil
  end

end