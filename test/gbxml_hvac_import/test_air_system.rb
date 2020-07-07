require_relative 'minitest_helper'

class TestAirSystem < Minitest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = Config::GBXML_FILES + '/AirSystemAllVariations.xml'
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    self.model = translator.loadModel(self.gbxml_path).get
    self.model_manager = ModelManager.new(self.model, self.gbxml_path)
    self.model_manager.load_gbxml
    self.model_manager.resolve_references
    self.model_manager.resolve_read_relationships
  end

  def test_air_system_xml_creation
    equipment = self.model_manager.air_systems.values[0]
    xml_element = self.model_manager.gbxml_parser.air_systems[0]
    name = xml_element.elements['Name'].text
    id = xml_element.attributes['id']
    cad_object_id = xml_element.elements['CADObjectId'].text

    assert(equipment.name == name)
    assert(equipment.cad_object_id == cad_object_id)
    assert(equipment.id == id)
  end

  def test_is_doas
    xml_string = <<EOF
  <AirSystem preheatCoilType="ElectricResistance" heatingCoilType="ElectricResistance" coolingCoilType="ChilledWater" id="aim0554">
    <Name>Air System</Name>
    <CADObjectId>355815</CADObjectId>
    <HeatExchanger heatExchangerType="Enthalpy"/>
    <Fan FanType="ConstantVolume"/>
    <HydronicLoopId hydronicLoopIdRef="aim0553" hydronicLoopType="PrimaryChilledWater" coilType="Cooling"/>
    <AnalysisParameter parameterType="xs:boolean">
       <Name>DOAS</Name>
       <Description>Dedicated Outdoor Air System</Description>
       <ParameterValue>True</ParameterValue>
     </AnalysisParameter>
  </AirSystem>
EOF

    xml = REXML::Document.new(xml_string)
    air_system_xml = xml.elements['AirSystem']
    air_system = AirSystem.create_from_xml(self.model_manager, air_system_xml)

    assert(air_system.is_doas)
  end

  def test_is_not_doas
    xml_string = <<EOF
  <AirSystem preheatCoilType="ElectricResistance" heatingCoilType="ElectricResistance" coolingCoilType="ChilledWater" id="aim0554">
    <Name>Air System</Name>
    <CADObjectId>355815</CADObjectId>
    <HeatExchanger heatExchangerType="Enthalpy"/>
    <Fan FanType="ConstantVolume"/>
    <HydronicLoopId hydronicLoopIdRef="aim0553" hydronicLoopType="PrimaryChilledWater" coilType="Cooling"/>
  </AirSystem>
EOF

    xml = REXML::Document.new(xml_string)
    air_system_xml = xml.elements['AirSystem']
    air_system = AirSystem.create_from_xml(self.model_manager, air_system_xml)

    assert(air_system.is_doas == false)
  end

  def test_air_system_build
    self.model_manager.build
    all_none = self.model_manager.air_systems.values[0].air_loop_hvac
    enth_elec_ac_dx_elec_var = self.model_manager.air_systems.values[1].air_loop_hvac
    sens_furn_wc_dx_furn_var = self.model_manager.air_systems.values[2].air_loop_hvac
    none_hw_chw_hw_vav = self.model_manager.air_systems.values[3].air_loop_hvac

    # Should have OAsys and supply fan
    assert(all_none.airLoopHVACOutdoorAirSystem.is_initialized)
    optional_hx = all_none.airLoopHVACOutdoorAirSystem.get.reliefAirModelObject.get.to_Node.get.outletModelObject
    assert(!optional_hx.is_initialized)
    mixed_air_node = all_none.airLoopHVACOutdoorAirSystem.get.mixedAirModelObject.get.to_Node.get
    fan = mixed_air_node.outletModelObject.get.to_FanVariableVolume
    assert(fan.is_initialized)
    assert(fan.get.outletModelObject.get == all_none.supplyOutletNode)

    # Should have OAsys, HX, elec preheat, AC DX, elec heating, vav
    assert(enth_elec_ac_dx_elec_var.airLoopHVACOutdoorAirSystem.is_initialized)
    optional_hx = enth_elec_ac_dx_elec_var.airLoopHVACOutdoorAirSystem.get.reliefAirModelObject.get.to_Node.get.outletModelObject.get.to_HeatExchangerAirToAirSensibleAndLatent
    assert(optional_hx.is_initialized)
    mixed_air_node = enth_elec_ac_dx_elec_var.airLoopHVACOutdoorAirSystem.get.mixedAirModelObject.get.to_Node.get
    preheat_coil = mixed_air_node.outletModelObject.get.to_CoilHeatingElectric
    assert(preheat_coil.is_initialized)
    cooling_coil = preheat_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_CoilCoolingDXSingleSpeed
    assert(cooling_coil.is_initialized)
    heating_coil = cooling_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_CoilHeatingElectric
    assert(heating_coil.is_initialized)
    fan = heating_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_FanVariableVolume
    assert(fan.is_initialized)

    assert(enth_elec_ac_dx_elec_var.airLoopHVACOutdoorAirSystem.is_initialized)
    optional_hx = enth_elec_ac_dx_elec_var.airLoopHVACOutdoorAirSystem.get.reliefAirModelObject.get.to_Node.get.outletModelObject.get.to_HeatExchangerAirToAirSensibleAndLatent
    assert(optional_hx.is_initialized)
    mixed_air_node = enth_elec_ac_dx_elec_var.airLoopHVACOutdoorAirSystem.get.mixedAirModelObject.get.to_Node.get
    preheat_coil = mixed_air_node.outletModelObject.get.to_CoilHeatingElectric
    assert(preheat_coil.is_initialized)
    cooling_coil = preheat_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_CoilCoolingDXSingleSpeed
    assert(cooling_coil.is_initialized)
    heating_coil = cooling_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_CoilHeatingElectric
    assert(heating_coil.is_initialized)
    fan = heating_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_FanVariableVolume
    assert(fan.is_initialized)

    assert(sens_furn_wc_dx_furn_var.airLoopHVACOutdoorAirSystem.is_initialized)
    optional_hx = sens_furn_wc_dx_furn_var.airLoopHVACOutdoorAirSystem.get.reliefAirModelObject.get.to_Node.get.outletModelObject.get.to_HeatExchangerAirToAirSensibleAndLatent
    assert(optional_hx.is_initialized)
    mixed_air_node = sens_furn_wc_dx_furn_var.airLoopHVACOutdoorAirSystem.get.mixedAirModelObject.get.to_Node.get
    preheat_coil = mixed_air_node.outletModelObject.get.to_CoilHeatingGas
    assert(preheat_coil.is_initialized)
    cooling_coil = preheat_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_CoilCoolingDXSingleSpeed
    assert(cooling_coil.is_initialized)
    heating_coil = cooling_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_CoilHeatingGas
    assert(heating_coil.is_initialized)
    fan = heating_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_FanVariableVolume
    assert(fan.is_initialized)

    assert(none_hw_chw_hw_vav.airLoopHVACOutdoorAirSystem.is_initialized)
    optional_hx = none_hw_chw_hw_vav.airLoopHVACOutdoorAirSystem.get.reliefAirModelObject.get.to_Node.get.outletModelObject
    assert(!optional_hx.is_initialized)
    mixed_air_node = none_hw_chw_hw_vav.airLoopHVACOutdoorAirSystem.get.mixedAirModelObject.get.to_Node.get
    preheat_coil = mixed_air_node.outletModelObject.get.to_CoilHeatingWater
    assert(preheat_coil.is_initialized)
    cooling_coil = preheat_coil.get.airOutletModelObject.get.to_Node.get.outletModelObject.get.to_CoilCoolingWater
    assert(cooling_coil.is_initialized)
    heating_coil = cooling_coil.get.airOutletModelObject.get.to_Node.get.outletModelObject.get.to_CoilHeatingWater
    assert(heating_coil.is_initialized)
    fan = heating_coil.get.airOutletModelObject.get.to_Node.get.outletModelObject.get.to_FanConstantVolume
    assert(fan.is_initialized)
  end

  def create_sizing_osw
    osw = create_test_sizing_osw
    osw = adjust_gbxml_paths(osw, 'AirSystemAllVariations.xml')
    osw_in_path = Config::TEST_OUTPUT_PATH + '/air_system/in.osw'
    osw.saveAs(osw_in_path)
  end

  def test_sizing_simulation
    create_sizing_osw
    # set osw_path to find location of osw to run
    osw_in_path = Config::TEST_OUTPUT_PATH + '/air_system/in.osw'
    cmd = "\"#{Config::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = Config::TEST_OUTPUT_PATH + '/air_system/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end

  def create_annual_osw
    osw = create_test_annual_osw
    osw = adjust_gbxml_paths(osw, 'AirSystemAllVariations.xml')
    osw_in_path = Config::TEST_OUTPUT_PATH + '/air_system/in.osw'
    osw.saveAs(osw_in_path)
  end

  def test_annual_simulation
    create_annual_osw
    # set osw_path to find location of osw to run
    osw_in_path = Config::TEST_OUTPUT_PATH + '/air_system/in.osw'
    cmd = "\"#{Config::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = Config::TEST_OUTPUT_PATH + '/air_system/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end

  def test_infer_infiltration_schedule
    hourly_values = [0,0,0,0,0,1,1,1,1,1,1,1,1,1,
                     1,1,1,1,1,1,0,0,0,0]

    schedule_ruleset = OpenStudio::Model::ScheduleRuleset.new(model)
    hourly_values.each_with_index do |hourly_value, i|
      schedule_ruleset.defaultDaySchedule.addValue(OpenStudio::Time.new(0, i + 1,0,0), hourly_value)
    end

    inferred_schedule = AirSystem.infer_infiltration_schedule(schedule_ruleset)

    expected_values = [1,1,1,1,1,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,
                       0.25,0.25,0.25,0.25,0.25,0.25,1,1,1,1]

    assert(inferred_schedule.defaultDaySchedule.values == expected_values)
  end

  def test_set_schedules
    hourly_values = [0,0,0,0,0.04,0.05,0.06,0.1,0.3,0.4,0.5,0.5,0.5,0.5,
                           0.5,0.5,0.5,0.5,0.06,0.05,0.04,0,0,0]

    model = OpenStudio::Model::Model.new
    space = OpenStudio::Model::Space.new(model)
    thermal_zone = OpenStudio::Model::ThermalZone.new(model)

    # Create floor for space
    points = OpenStudio::Point3dVector.new
    points << OpenStudio::Point3d.new(0, 0, 0)
    points << OpenStudio::Point3d.new(0, 10, 0)
    points << OpenStudio::Point3d.new(10, 10, 0)
    points << OpenStudio::Point3d.new(10, 0, 0)

    surface = OpenStudio::Model::Surface.new(points, model)
    surface.setSurfaceType('Floor')
    surface.setSpace(space)

    schedule_ruleset = OpenStudio::Model::ScheduleRuleset.new(model)
    schedule_type_limits = OpenStudio::Model::ScheduleTypeLimits.new(model)
    schedule_type_limits.setName("Fractional")
    schedule_type_limits.setLowerLimitValue(0.0)
    schedule_type_limits.setUpperLimitValue(1.0)
    schedule_type_limits.setNumericType("Continuous")
    schedule_type_limits.setUnitType("Dimensionless")
    schedule_ruleset.setScheduleTypeLimits(schedule_type_limits)

    hourly_values.each_with_index do |hourly_value, i|
      schedule_ruleset.defaultDaySchedule.addValue(OpenStudio::Time.new(0, i + 1,0,0), hourly_value)
    end

    people_definition = OpenStudio::Model::PeopleDefinition.new(model)
    people_definition.setSpaceFloorAreaperPerson(20)
    # people_definition.setNumberofPeople(10)
    people = OpenStudio::Model::People.new(people_definition)
    people.setSpace(space)
    puts people.getNumberOfPeople(space.floorArea)

    puts people.setNumberofPeopleSchedule(schedule_ruleset)

    space_infiltration = OpenStudio::Model::SpaceInfiltrationDesignFlowRate.new(model)
    space_infiltration.setFlowperExteriorSurfaceArea(0.019)

    space.setThermalZone(thermal_zone)
    space_infiltration.setSpace(space)

    air_loop_hvac = OpenStudio::Model::AirLoopHVAC.new(model)
    vav_box = OpenStudio::Model::AirTerminalSingleDuctVAVReheat.new(model, model.alwaysOnDiscreteSchedule, OpenStudio::Model::CoilHeatingElectric.new(model))

    air_loop_hvac.addBranchForZone(thermal_zone, vav_box)

    air_system = AirSystem.new
    air_system.air_loop_hvac = air_loop_hvac
    air_system.set_schedules

    expected_infiltration_values = [1.0,0.25,1.0]
    expected_infiltration_times = []
    expected_infiltration_times << OpenStudio::Time.new(0, 5, 0)
    expected_infiltration_times << OpenStudio::Time.new(0, 20, 0)
    expected_infiltration_times << OpenStudio::Time.new(0, 24, 0)

    space.spaceInfiltrationDesignFlowRates[0].schedule.get.to_ScheduleRuleset.get.scheduleRules.each do |schedule_rule|
      assert(schedule_rule.daySchedule.times == expected_infiltration_times)
      assert(schedule_rule.daySchedule.values == expected_infiltration_values)
    end

    # puts space.people[0].numberofPeopleSchedule.get.to_ScheduleRuleset.get.defaultDaySchedule

  end

  def schedule_day_from_array(hours)
    schedule_day = OpenStudio::Model::ScheduleDay.new()

    hours.each_with_index do |hour, i|
      schedule_day.addValue(time, sch_values[i])
    end
  end
end