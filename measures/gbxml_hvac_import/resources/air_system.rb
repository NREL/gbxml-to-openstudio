class AirSystem < HVACObject
  attr_accessor :air_loop_hvac, :supply_fan, :heating_coil, :cooling_coil, :preheat_coil, :oa_system, :heat_exchanger,
                :spm, :supply_fan_type, :heating_coil_type, :heating_loop_ref, :heating_loop, :cooling_coil_type,
                :cooling_loop_ref, :cooling_loop, :preheat_coil_type, :preheat_loop_ref, :preheat_loop,
                :heat_exchanger_type, :is_doas, :zone_hvac_equipment, :preheat_spm

  PREHEAT_DESIGN_TEMP = 4
  COOLING_DESIGN_TEMP = 12.777778
  HEATING_DESIGN_TEMP = 12.777778
  DOAS_COOLING_DESIGN_TEMP = 12.777778
  DOAS_HEATING_DESIGN_TEMP = 15.555556
  COOLING_DESIGN_HUMIDITY_RATIO = 0.0085
  HEATING_DESIGN_HUMIDITY_RATIO = 0.005

  def initialize
    self.name = "Air System"
    self.zone_hvac_equipment = []
    self.is_doas = false
  end

  def self.create_from_xml(model_manager, xml)
    air_loop = new
    air_loop.model_manager = model_manager

    name = xml.elements['Name']

    air_loop.set_name(xml.elements['Name'].text) if name
    air_loop.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    air_loop.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    supply_fan = xml.elements['Fan']
    air_loop.supply_fan_type = supply_fan.attributes['FanType'] unless supply_fan.nil?

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

    heat_exchanger = xml.elements['HeatExchanger']
    unless heat_exchanger.nil?
      air_loop.heat_exchanger_type = heat_exchanger.attributes['heatExchangerType']
    end

    doas_true_arr = REXML::XPath.match(xml,
                                       "AnalysisParameter[Name[text()=='DOAS']][ParameterValue[text()='True']]")
    air_loop.is_doas = true unless doas_true_arr.empty?

    air_loop
  end

  def design_htg_temp
    if self.is_doas
      DOAS_HEATING_DESIGN_TEMP
    else
      HEATING_DESIGN_TEMP
    end
  end

  def design_clg_temp
    if self.is_doas
      DOAS_COOLING_DESIGN_TEMP
    else
      COOLING_DESIGN_TEMP
    end
  end

  def heating_coil_rated_inlet_air_temperature
    if self.preheat_coil_type.nil?
      Helpers::get_minimum_design_day_temperature(self.model)
    else
      PREHEAT_DESIGN_TEMP
    end
  end

  def resolve_references
    if self.preheat_loop_ref
      hw_loop = self.model_manager.hw_loops[self.preheat_loop_ref]
      self.preheat_loop = hw_loop if hw_loop
    end

    if self.heating_loop_ref
      hw_loop = self.model_manager.hw_loops[self.heating_loop_ref]
      self.heating_loop = hw_loop if hw_loop
    end

    if self.cooling_loop_ref
      chw_loop = self.model_manager.chw_loops[self.cooling_loop_ref]
      self.cooling_loop = chw_loop if chw_loop
    end
  end

  def add_zone_hvac_equipment(equipment)
    self.zone_hvac_equipment << equipment
  end

  def resolve_read_relationships
    unless self.cooling_loop.nil?
      self.cooling_loop.is_low_temperature = true
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
    self.oa_system.addToNode(air_loop_hvac.supplyInletNode)
    unless preheat_coil.nil?
      self.preheat_coil.addToNode(self.oa_system.outboardOANode.get)
      self.preheat_spm.addToNode(self.oa_system.outdoorAirModelObject.get.to_Node.get)
    end
    self.heat_exchanger.addToNode(self.oa_system.outdoorAirModelObject.get.to_Node.get) unless self.heat_exchanger.nil?
    self.spm.addToNode(self.air_loop_hvac.supplyOutletNode)

    self.air_loop_hvac.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    self.air_loop_hvac.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
  end

  def post_build
    self.preheat_loop.plant_loop.addDemandBranchForComponent(self.preheat_coil) if self.preheat_loop
    self.cooling_loop.plant_loop.addDemandBranchForComponent(self.cooling_coil) if self.cooling_loop
    self.heating_loop.plant_loop.addDemandBranchForComponent(self.heating_coil) if self.heating_loop
    set_schedules
  end

  private

  def add_air_loop_hvac
    air_loop_hvac = OpenStudio::Model::AirLoopHVAC.new(self.model)
    air_loop_hvac.setName(self.name) unless self.name.nil?
    air_loop_hvac.setAvailabilitySchedule(self.model.alwaysOnDiscreteSchedule)
    air_loop_hvac.setNightCycleControlType("CycleOnAny") unless self.is_doas
    air_loop_hvac.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    air_loop_hvac.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?

    air_loop_sizing = air_loop_hvac.sizingSystem
    air_loop_sizing.setSizingOption('Coincident')
    air_loop_sizing.setPreheatDesignTemperature(PREHEAT_DESIGN_TEMP)
    air_loop_sizing.setPreheatDesignHumidityRatio(HEATING_DESIGN_HUMIDITY_RATIO)
    air_loop_sizing.setCentralCoolingDesignSupplyAirTemperature(self.design_clg_temp)
    air_loop_sizing.setCentralHeatingDesignSupplyAirTemperature(self.design_htg_temp)
    air_loop_sizing.autosizeCentralHeatingMaximumSystemAirFlowRatio
    air_loop_sizing.setCentralCoolingDesignSupplyAirHumidityRatio(COOLING_DESIGN_HUMIDITY_RATIO)
    air_loop_sizing.setCentralHeatingDesignSupplyAirHumidityRatio(HEATING_DESIGN_HUMIDITY_RATIO)
    air_loop_sizing.setSystemOutdoorAirMethod('ZoneSum')

    if self.is_doas
      air_loop_sizing.setTypeofLoadtoSizeOn('VentilationRequirement')
      air_loop_sizing.setAllOutdoorAirinCooling(true)
      air_loop_sizing.setAllOutdoorAirinHeating(true)
      air_loop_sizing.setZoneMaximumOutdoorAirFraction(1.0)
    else
      air_loop_sizing.setTypeofLoadtoSizeOn('Sensible')
      air_loop_sizing.setMinimumSystemAirFlowRatio(0.3)
      air_loop_sizing.setAllOutdoorAirinCooling(false)
      air_loop_sizing.setAllOutdoorAirinHeating(false)
    end

    air_loop_hvac
  end

  def add_supply_fan
    fan = nil

    if self.supply_fan_type == "VariableVolume"
      fan = OpenStudio::Model::FanVariableVolume.new(self.model)
      fan.setFanPowerMinimumFlowFraction(0.3)
    elsif self.supply_fan_type == "ConstantVolume"
      fan = OpenStudio::Model::FanConstantVolume.new(self.model)
    end

    if fan
      fan.setPressureRise(996)
      fan.setFanTotalEfficiency(0.60)
      fan.setMotorEfficiency(0.94)
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
      heating_coil.setRatedInletWaterTemperature(self.heating_loop.design_loop_exit_temp)
      heating_coil.setRatedOutletWaterTemperature(self.heating_loop.design_loop_return_temp)
      heating_coil.setRatedInletAirTemperature(self.heating_coil_rated_inlet_air_temperature)
      heating_coil.setRatedOutletAirTemperature(self.design_htg_temp)
    end

    if heating_coil
      heating_coil.setName(self.name + " Heating Coil") unless self.name.nil?
      heating_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
      heating_coil.additionalProperties.setFeature('coil_type', 'primary_heating')
    end

    heating_coil
  end

  def add_cooling_coil
    cooling_coil = nil

    if self.cooling_coil_type == "DirectExpansion" or self.cooling_coil_type == "DirectExpansionAirCooled"
      cooling_coil = OpenStudio::Model::CoilCoolingDXSingleSpeed.new(self.model)
    # elsif self.cooling_coil_type == "DirectExpansionWaterCooled"
    #   cooling_coil = OpenStudio::Model::CoilCoolingDXSingleSpeed.new(self.model)
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
      preheat_coil.setRatedInletWaterTemperature(self.heating_loop.design_loop_exit_temp)
      preheat_coil.setRatedOutletWaterTemperature(self.heating_loop.design_loop_return_temp)
      preheat_coil.setRatedInletAirTemperature(Helpers::get_minimum_design_day_temperature(self.model))
      preheat_coil.setRatedOutletAirTemperature(PREHEAT_DESIGN_TEMP)
    end

    if preheat_coil
      preheat_coil.setName(self.name + " Preheat Coil") unless self.name.nil?
      preheat_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.name.nil?
      preheat_coil.additionalProperties.setFeature('coil_type', 'preheat')

      preheat_schedule = OpenStudio::Model::ScheduleConstant.new(model)
      preheat_schedule.setValue(PREHEAT_DESIGN_TEMP)
      self.preheat_spm = OpenStudio::Model::SetpointManagerScheduled.new(self.model, preheat_schedule)
    end

    preheat_coil
  end

  def add_oa_system
    oa_controller = OpenStudio::Model::ControllerOutdoorAir.new(self.model)
    oa_controller.setName(self.name + " Controller Outdoor Air") unless self.name.nil?
    oa_controller.setMinimumFractionofOutdoorAirSchedule(self.model.alwaysOnDiscreteSchedule) if self.is_doas
    oa_controller.setMinimumLimitType('FixedMinimum')
    oa_controller.autosizeMinimumOutdoorAirFlowRate
    oa_controller.setEconomizerControlType('DifferentialEnthalpy') unless self.is_doas

    controller_mech_vent = oa_controller.controllerMechanicalVentilation
    controller_mech_vent.setName(self.name + " Controller Mechanical Ventilation") unless self.name.nil?
    controller_mech_vent.setDemandControlledVentilation(true)

    oa_system = OpenStudio::Model::AirLoopHVACOutdoorAirSystem.new(self.model, oa_controller)
    oa_system.setName(self.name + " Outdoor Air System") unless self.name.nil?
    oa_system
  end

  def add_heat_exchanger
    heat_exchanger = nil

    if self.heat_exchanger_type == "Enthalpy"
      heat_exchanger = OpenStudio::Model::HeatExchangerAirToAirSensibleAndLatent.new(self.model)
      heat_exchanger.setName(self.name + " Heat Exchanger") unless self.name.nil?
      heat_exchanger.setSupplyAirOutletTemperatureControl(true)
      heat_exchanger.setSensibleEffectivenessat100HeatingAirFlow(0.76)
      heat_exchanger.setSensibleEffectivenessat75HeatingAirFlow(0.81)
      heat_exchanger.setLatentEffectivenessat100HeatingAirFlow(0.68)
      heat_exchanger.setLatentEffectivenessat75HeatingAirFlow(0.73)
      heat_exchanger.setSensibleEffectivenessat100CoolingAirFlow(0.76)
      heat_exchanger.setSensibleEffectivenessat75CoolingAirFlow(0.81)
      heat_exchanger.setLatentEffectivenessat100CoolingAirFlow(0.68)
      heat_exchanger.setLatentEffectivenessat75CoolingAirFlow(0.73)
    elsif self.heat_exchanger_type == "Sensible"
      heat_exchanger = OpenStudio::Model::HeatExchangerAirToAirSensibleAndLatent.new(self.model)
      heat_exchanger.setName(self.name + " Heat Exchanger") unless self.name.nil?
      heat_exchanger.setSupplyAirOutletTemperatureControl(true)
      heat_exchanger.setSensibleEffectivenessat100HeatingAirFlow(0.76)
      heat_exchanger.setSensibleEffectivenessat75HeatingAirFlow(0.81)
      heat_exchanger.setLatentEffectivenessat100HeatingAirFlow(0)
      heat_exchanger.setLatentEffectivenessat75HeatingAirFlow(0)
      heat_exchanger.setSensibleEffectivenessat100CoolingAirFlow(0.76)
      heat_exchanger.setSensibleEffectivenessat75CoolingAirFlow(0.81)
      heat_exchanger.setLatentEffectivenessat100CoolingAirFlow(0)
      heat_exchanger.setLatentEffectivenessat75CoolingAirFlow(0)
    end

    heat_exchanger
  end

  def add_spm
    if self.is_doas
      temp_sch = OpenStudio::Model::ScheduleRuleset.new(self.model)
      temp_sch.setName("#{self.name} Air Supply Temperature Schedule")
      temp_sch.defaultDaySchedule.setName("#{self.name} Air Supply Temperature Schedule Default")
      temp_sch.defaultDaySchedule.addValue(OpenStudio::Time.new(0, 24, 0, 0), DOAS_COOLING_DESIGN_TEMP)
      spm = OpenStudio::Model::SetpointManagerScheduled.new(self.model, temp_sch)
    else
      spm = OpenStudio::Model::SetpointManagerWarmest.new(self.model)
      spm.setMaximumSetpointTemperature(18.33333)
      spm.setMinimumSetpointTemperature(COOLING_DESIGN_TEMP)
    end

    spm.setName("#{self.name} Setpoint Manager")
    spm
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
    assign_airloop_infiltration_sch(infil_sch)
  end
end