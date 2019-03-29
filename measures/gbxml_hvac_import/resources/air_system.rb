class AirSystem < HVACObject
  attr_accessor :air_loop_hvac, :supply_fan, :heating_coil, :cooling_coil, :preheat_coil, :oa_system, :heat_exchanger,
                :spm, :supply_fan_type, :heating_coil_type, :heating_loop_ref, :cooling_coil_type, :cooling_loop_ref,
                :preheat_coil_type, :preheat_loop_ref, :heat_exchanger_type, :is_doas

  def initialize
    self.name = "Air System"
  end

  def add_air_loop_hvac
    air_loop_hvac = OpenStudio::Model::AirLoopHVAC.new(self.model)
    air_loop_hvac.setName(self.name) unless self.name.nil?
    air_loop_hvac.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    air_loop_hvac.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    air_loop_hvac
  end

  def add_supply_fan
    fan = nil

    if self.supply_fan_type == "VariableVolume"
      fan = OpenStudio::Model::FanVariableVolume.new(self.model)
    elsif self.supply_fan_type == "ConstantVolume"
      fan = OpenStudio::Model::FanConstantVolume.new(self.model)
    end

    if fan
      fan.setName(self.name + " Supply Fan") unless self.name.nil?
      fan.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.name.nil?
    end

    fan
  end

  def add_heating_coil
    heating_coil = nil

    if self.heating_coil_type == "ElectricResistance"
      heating_coil = OpenStudio::Model::CoilHeatingElectric.new(self.model)
    elsif self.heating_coil_type == "Furnace"
      heating_coil = OpenStudio::Model::CoilHeatingGas.new(self.model)
    elsif self.heating_coil_type == "HotWater"
      heating_coil = OpenStudio::Model::CoilHeatingWater.new(self.model)
    end

    if heating_coil
      heating_coil.setName(self.name + " Heating Coil") unless self.name.nil?
      heating_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.name.nil?
      heating_coil.additionalProperties.setFeature('coil_type', 'primary_heating')
    end

    heating_coil
  end

  def add_cooling_coil
    cooling_coil = nil

    if self.cooling_coil_type == "DirectExpansion" or self.cooling_coil_type == "DirectExpansionAirCooled"
      cooling_coil = OpenStudio::Model::CoilCoolingDXSingleSpeed.new(self.model)
    elsif self.cooling_coil_type == "DirectExpansionWaterCooled"
      cooling_coil = OpenStudio::Model::CoilCoolingDXSingleSpeed.new(self.model)
    elsif self.cooling_coil_type == "ChilledWater"
      cooling_coil = OpenStudio::Model::CoilCoolingWater.new(self.model)
    end

    if cooling_coil
      cooling_coil.setName(self.name + " Cooling Coil") unless self.name.nil?
      cooling_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.name.nil?
      cooling_coil.additionalProperties.setFeature('coil_type', 'primary_cooling')
    end

    cooling_coil
  end

  def add_preheat_coil
    preheat_coil = nil

    if self.preheat_coil_type == "ElectricResistance"
      preheat_coil = OpenStudio::Model::CoilHeatingElectric.new(self.model)
    elsif self.preheat_coil_type == "Furnace"
      preheat_coil = OpenStudio::Model::CoilHeatingGas.new(self.model)
    elsif self.preheat_coil_type == "HotWater"
      preheat_coil = OpenStudio::Model::CoilHeatingWater.new(self.model)
    end

    if preheat_coil
      preheat_coil.setName(self.name + " Preheat Coil") unless self.name.nil?
      preheat_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.name.nil?
      preheat_coil.additionalProperties.setFeature('coil_type', 'preheat')
    end

    preheat_coil
  end

  def add_oa_system
    oa_controller = OpenStudio::Model::ControllerOutdoorAir.new(self.model)
    oa_system = OpenStudio::Model::AirLoopHVACOutdoorAirSystem.new(self.model, oa_controller)
    oa_system
  end

  def add_heat_exchanger
    heat_exchanger = nil

    if self.heat_exchanger_type == "Enthalpy"
      heat_exchanger = OpenStudio::Model::HeatExchangerAirToAirSensibleAndLatent.new(self.model)
      heat_exchanger.setSupplyAirOutletTemperatureControl(true)
    elsif self.heat_exchanger_type == "Sensible"
      heat_exchanger = OpenStudio::Model::HeatExchangerAirToAirSensibleAndLatent.new(self.model)
      heat_exchanger.setSupplyAirOutletTemperatureControl(true)
    end

    heat_exchanger
  end

  def add_spm_warmest
    OpenStudio::Model::SetpointManagerWarmest.new(model)
  end

  def add_spm_doas
    temp_sch = OpenStudio::Model::ScheduleRuleset.new(self.model)
    temp_sch.setName("#{self.name} Air Supply Temperature Schedule")
    temp_sch.defaultDaySchedule.setName("#{self.name} Air Supply Temperature Schedule Default")
    # default to 70F / 21.11C
    temp_sch.defaultDaySchedule.addValue(OpenStudio::Time.new(0, 24, 0, 0), 21.11)
    spm = OpenStudio::Model::SetpointManagerScheduled.new(self.model, temp_sch)
    spm.setName("#{self.name} Setpoint Manager")
    spm
  end

  def add_spm
    spm = add_spm_warmest if !self.is_doas
    spm = add_spm_doas if self.is_doas
    spm
  end

  def resolve_read_relationships
    unless self.cooling_loop_ref.nil?
      cooling_loop = self.model_manager.chw_loops[self.cooling_loop_ref]
      cooling_loop.is_low_temperature = true
    end
  end

  def resolve_dependencies
    unless self.heating_loop_ref.nil?
      heating_loop = self.model_manager.hw_loops[self.heating_loop_ref]
      heating_loop.plant_loop.addDemandBranchForComponent(self.heating_coil)
    end

    unless self.cooling_loop_ref.nil?
      cooling_loop = self.model_manager.chw_loops[self.cooling_loop_ref]
      cooling_loop.plant_loop.addDemandBranchForComponent(self.cooling_coil)
      cooling_loop.is_low_temperature = true
    end

    unless self.preheat_loop_ref.nil?
      preheat_loop = self.model_manager.hw_loops[self.preheat_loop_ref]
      preheat_loop.plant_loop.addDemandBranchForComponent(self.preheat_coil)
    end
  end

  def build
    self.model = model_manager.model
    self.air_loop_hvac = add_air_loop_hvac
    self.oa_system = add_oa_system
    self.supply_fan = add_supply_fan
    self.heating_coil = add_heating_coil
    self.cooling_coil = add_cooling_coil
    self.preheat_coil = add_preheat_coil
    self.heat_exchanger = add_heat_exchanger
    self.spm = add_spm

    self.supply_fan.addToNode(air_loop_hvac.supplyInletNode) unless self.supply_fan.nil?
    self.heating_coil.addToNode(air_loop_hvac.supplyInletNode) unless self.heating_coil.nil?
    self.cooling_coil.addToNode(air_loop_hvac.supplyInletNode) unless self.cooling_coil.nil?
    self.preheat_coil.addToNode(air_loop_hvac.supplyInletNode) unless self.preheat_coil.nil?
    self.oa_system.addToNode(air_loop_hvac.supplyInletNode)
    self.heat_exchanger.addToNode(self.oa_system.outboardOANode.get) unless self.heat_exchanger.nil?
    self.spm.addToNode(self.air_loop_hvac.supplyOutletNode)
    resolve_dependencies

    self.air_loop_hvac.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    self.air_loop_hvac.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    self.air_loop_hvac
  end

  # Replaces values in a Schedule Ruleset schedule
  #
  # @param sch [OpenStudio::Model::ScheduleRuleset] ScheduleRuleset
  # @param new_value_map [Array<Array<Double,Double>>] array of old and new value pairs
  #   e.g. [[1.0,0.25],[0.0,1.0]]
  # @return [OpenStudio::Model::ScheduleRuleset] ScheduleRuleset with new values
  def self.replace_schedule_ruleset_values(sch, new_value_map)
    # get and store ScheduleDay objects
    schedule_days = []
    schedule_days << sch.defaultDaySchedule
    sch.scheduleRules.each do |sch_rule|
      schedule_days << sch_rule.daySchedule
    end

    # replace values in each ScheduleDay object
    schedule_days.each do |sch_day|
      # get times and values
      sch_times = sch_day.times
      sch_values = sch_day.values

      # replace values
      new_value_map.each do |pair|
        sch_values = sch_values.map { |x| x == pair[0] ? pair[1] : x }
      end

      # clear values and set new ones
      sch_day.clearValues
      sch_times.each_with_index do |time, i|
        sch_day.addValue(time, sch_values[i])
      end
    end

    return sch
  end

  # infer an infiltration schedule from the HVAC schedule ruleset
  def self.infer_infiltration_schedule(hvac_op_sch)
    # clone HVAC operating schedule
    infil_sch = hvac_op_sch.clone.to_ScheduleRuleset.get
    infil_sch.setName("#{hvac_op_sch.name} based infiltration sch")
    # set to 0.25 when HVAC is on and 1.0 when HVAC is off
    infil_sch = AirSystem.replace_schedule_ruleset_values(infil_sch, [[1.0,0.25],[0,1.0]])
    infil_sch
  end

  # assign a schedule to all infiltration objects in spaces served by an air loop
  def assign_airloop_infiltration_sch(infil_sch)
    self.air_loop_hvac.thermalZones.each do |zone|
      zone.spaces.each do |space|
        space.spaceInfiltrationDesignFlowRates.each do |space_infil|
          space_infil.setSchedule(infil_sch)
        end
      end
    end
  end

  def set_schedules
    # set HVAC operating schedule to combined zone occupancy schedule
    std = Standard.build('90.1-2013')
    loop_occ_sch = std.air_loop_hvac_get_occupancy_schedule(self.air_loop_hvac)
    self.air_loop_hvac.setAvailabilitySchedule(loop_occ_sch)

    # set infiltration schedules for spaces matched to HVAC operation
    infil_sch = AirSystem.infer_infiltration_schedule(loop_occ_sch)
    self.assign_airloop_infiltration_sch(infil_sch)
  end

  def assign_airloop_sizing_properties
    if self.is_doas
      # set minimum outdoor air flow fraction to 1
      oa_controller = self.oa_system.getControllerOutdoorAir
      oa_controller.setMinimumFractionofOutdoorAirSchedule(self.model.alwaysOnDiscreteSchedule)

      # set system sizing properties
      air_loop_sizing = self.air_loop_hvac.sizingSystem
      air_loop_sizing.setTypeofLoadtoSizeOn('VentilationRequirement')
      air_loop_sizing.setAllOutdoorAirinCooling(true)
      air_loop_sizing.setAllOutdoorAirinHeating(true)
      air_loop_sizing.setZoneMaximumOutdoorAirFraction(1.0)
      air_loop_sizing.setCentralCoolingDesignSupplyAirTemperature(21.11)
      air_loop_sizing.setCentralHeatingDesignSupplyAirTemperature(21.11)

      # set zone sizing properties
      self.air_loop_hvac.thermalZones.each do |zone|
        sizing_zone = zone.sizingZone
        sizing_zone.setAccountforDedicatedOutdoorAirSystem(true)
        sizing_zone.setDedicatedOutdoorAirLowSetpointTemperatureforDesign(21.11)
        sizing_zone.setDedicatedOutdoorAirHighSetpointTemperatureforDesign(21.11)
      end
    end
  end

  # TODO: Break out into classes for each object to prevent this mess.
  def self.create_from_xml(model_manager, xml)
    air_loop = new
    air_loop.model_manager = model_manager

    name = xml.elements['Name']
    air_loop.set_name(xml.elements['Name'].text) unless name.nil?
    air_loop.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    air_loop.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    supply_fan = xml.elements['Fan']
    air_loop.supply_fan_type = supply_fan.attributes['FanType'] unless supply_fan.nil?

    if xml.attributes['isDOAS'].nil? or xml.attributes['isDOAS'] == "None"
      air_loop.is_doas = false
    else
      air_loop.is_doas == xml.attributes['isDOAS']
    end

    unless xml.attributes['heatingCoilType'].nil? or xml.attributes['heatingCoilType'] == "None"
      air_loop.heating_coil_type = xml.attributes['heatingCoilType']

      if air_loop.heating_coil_type == 'HotWater'
        hydronic_loop_id = xml.elements['HydronicLoopId[@coilType="Heating"]']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            air_loop.heating_loop_ref = hydronic_loop_id_ref
          end
        end
      end
    end

    unless xml.attributes['coolingCoilType'].nil? or xml.attributes['coolingCoilType'] == "None"
      air_loop.cooling_coil_type = xml.attributes['coolingCoilType']

      if air_loop.cooling_coil_type == 'ChilledWater'
        hydronic_loop_id = xml.elements['HydronicLoopId[@coilType="Cooling"]']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            air_loop.cooling_loop_ref = hydronic_loop_id_ref
          end
        end
      end
    end

    unless xml.attributes['preheatCoilType'].nil? or xml.attributes['preheatCoilType'] == "None"
      air_loop.preheat_coil_type = xml.attributes['preheatCoilType']

      if air_loop.preheat_coil_type == 'HotWater'
        hydronic_loop_id = xml.elements['HydronicLoopId[@coilType="Preheat"]']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            air_loop.preheat_loop_ref = hydronic_loop_id_ref
          end
        end
      end
    end

    # Add the Heat Exchanger
    heat_exchanger = xml.elements['HeatExchanger']
    unless heat_exchanger.nil?
      air_loop.heat_exchanger_type = heat_exchanger.attributes['heatExchangerType']
    end

    air_loop
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