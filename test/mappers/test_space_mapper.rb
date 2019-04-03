require_relative '../minitest_helper'

class TestSpaceMapper < MiniTest::Test

  include Mappers

  def test_update_infiltration
    model = OpenStudio::Model::Model.new
    os_space = OpenStudio::Model::Space.new(model)
    gbxml_space = GBXML::Space.new
    gbxml_space.infiltration_flow_per_area = 0.2

    Space.connect_model(model)
    Space.update_infiltration(gbxml_space, os_space)

    assert(gbxml_space.infiltration_flow_per_area == os_space.infiltrationDesignFlowPerExteriorSurfaceArea)
  end

  def test_update_lighting
    model = OpenStudio::Model::Model.new
    os_space = OpenStudio::Model::Space.new(model)
    gbxml_space = GBXML::Space.new
    gbxml_space.light_power_per_area = 0.5

    Space.connect_model(model)
    Space.update_lighting(gbxml_space, os_space)

    assert(gbxml_space.light_power_per_area == os_space.lightingPowerPerFloorArea)
  end

  def test_update_equipment
    model = OpenStudio::Model::Model.new
    os_space = OpenStudio::Model::Space.new(model)
    gbxml_space = GBXML::Space.new
    gbxml_space.equip_power_per_area = 0.7

    Space.connect_model(model)
    Space.update_equipment(gbxml_space, os_space)

    assert(gbxml_space.equip_power_per_area == os_space.electricEquipmentPowerPerFloorArea)
  end

  def test_update_people
    model = OpenStudio::Model::Model.new
    os_space = OpenStudio::Model::Space.new(model)
    gbxml_space = GBXML::Space.new
    gbxml_space.people_number = 10
    gbxml_space.people_heat_gain_total = 131.0
    gbxml_space.people_heat_gain_sensible = 85.0
    gbxml_space.people_heat_gain_latent = 46.0

    Space.connect_model(model)
    Space.update_people(gbxml_space, os_space)

    expected_shr = gbxml_space.people_heat_gain_sensible / gbxml_space.people_heat_gain_total
    activity_schedule_level = os_space.people[0].activityLevelSchedule.get.to_ScheduleRuleset.get.defaultDaySchedule.values[0]

    assert(gbxml_space.people_number, os_space.numberOfPeople)
    assert(gbxml_space.people_heat_gain_total, activity_schedule_level)
    assert_in_delta(expected_shr, os_space.people[0].peopleDefinition.sensibleHeatFraction.get, 0.0001)
  end

  def test_update_ventilation
    model = OpenStudio::Model::Model.new
    os_space = OpenStudio::Model::Space.new(model)
    gbxml_space = GBXML::Space.new
    gbxml_space.air_changes_per_hour = 0.7
    gbxml_space.oa_flow_per_area = 0.6
    gbxml_space.oa_flow_per_person = 0.5
    gbxml_space.oa_flow_per_space = 0.4

    Space.connect_model(model)
    Space.update_ventilation(gbxml_space, os_space)

    design_specification_outdoor_air = os_space.designSpecificationOutdoorAir.get
    assert(gbxml_space.air_changes_per_hour == design_specification_outdoor_air.outdoorAirFlowAirChangesperHour)
    assert(gbxml_space.oa_flow_per_area == design_specification_outdoor_air.outdoorAirFlowperFloorArea)
    assert(gbxml_space.oa_flow_per_person == design_specification_outdoor_air.outdoorAirFlowperPerson)
    assert(gbxml_space.oa_flow_per_space == design_specification_outdoor_air.outdoorAirFlowRate)

  end

  def test_update_schedules
    xml = <<EOF
  <gbXML>
    <Space zoneIdRef="aim0431" lightScheduleIdRef="aim0109" equipmentScheduleIdRef="aim0109" peopleScheduleIdRef="aim0115" id="aim0092">
    </Space>
    <Schedule type="Fraction" id="aim0109">
      <YearSchedule id="aim0110">
        <BeginDate>2019-01-01</BeginDate>
        <EndDate>2019-12-31</EndDate>
        <WeekScheduleId weekScheduleIdRef="aim0107" />
      </YearSchedule>
      <Name>Office Lighting - 6 AM to 11 PM</Name>
    </Schedule>
    <Schedule type="Fraction" id="aim0115">
      <YearSchedule id="aim0116">
        <BeginDate>2019-01-01</BeginDate>
        <EndDate>2019-12-31</EndDate>
        <WeekScheduleId weekScheduleIdRef="aim0113" />
      </YearSchedule>
      <Name>Common Office Occupancy - 8 AM to 5 PM</Name>
    </Schedule>
    <WeekSchedule type="Fraction" id="aim0107">
      <Day dayScheduleIdRef="aim0106" dayType="All" />
      <Name>Office Lighting - 6 AM to 11 PM</Name>
    </WeekSchedule>
    <WeekSchedule type="Fraction" id="aim0113">
      <Day dayScheduleIdRef="aim0112" dayType="All" />
      <Name>Common Office Occupancy - 8 AM to 5 PM</Name>
    </WeekSchedule>
    <DaySchedule type="Fraction" id="aim0106">
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0.1</ScheduleValue>
      <ScheduleValue>0.3</ScheduleValue>
      <ScheduleValue>0.9</ScheduleValue>
      <ScheduleValue>0.9</ScheduleValue>
      <ScheduleValue>0.9</ScheduleValue>
      <ScheduleValue>0.9</ScheduleValue>
      <ScheduleValue>0.8</ScheduleValue>
      <ScheduleValue>0.9</ScheduleValue>
      <ScheduleValue>0.9</ScheduleValue>
      <ScheduleValue>0.9</ScheduleValue>
      <ScheduleValue>0.9</ScheduleValue>
      <ScheduleValue>0.5</ScheduleValue>
      <ScheduleValue>0.3</ScheduleValue>
      <ScheduleValue>0.3</ScheduleValue>
      <ScheduleValue>0.2</ScheduleValue>
      <ScheduleValue>0.2</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <Name>Office Lighting - 6 AM to 11 PM</Name>
    </DaySchedule>
    <DaySchedule type="Fraction" id="aim0112">
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0.1</ScheduleValue>
      <ScheduleValue>0.2</ScheduleValue>
      <ScheduleValue>0.95</ScheduleValue>
      <ScheduleValue>0.95</ScheduleValue>
      <ScheduleValue>0.45</ScheduleValue>
      <ScheduleValue>0.45</ScheduleValue>
      <ScheduleValue>0.95</ScheduleValue>
      <ScheduleValue>0.95</ScheduleValue>
      <ScheduleValue>0.95</ScheduleValue>
      <ScheduleValue>0.95</ScheduleValue>
      <ScheduleValue>0.95</ScheduleValue>
      <ScheduleValue>0.3</ScheduleValue>
      <ScheduleValue>0.1</ScheduleValue>
      <ScheduleValue>0.1</ScheduleValue>
      <ScheduleValue>0.1</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <ScheduleValue>0</ScheduleValue>
      <Name>Common Office Occupancy - 8 AM to 5 PM</Name>
    </DaySchedule>
  </gbXML>
EOF

    model = OpenStudio::Model::Model.new
    os_space = OpenStudio::Model::Space.new(model)
    os_space.setName("Test Space")

    document = REXML::Document.new(xml).elements['gbXML']
    document.get_elements('DaySchedule').each { |element| GBXML::DaySchedule.from_xml(element) }
    document.get_elements('WeekSchedule').each { |element| GBXML::WeekSchedule.from_xml(element) }
    document.get_elements('YearSchedule').each { |element| GBXML::YearSchedule.from_xml(element) }
    document.get_elements('Schedule').each { |element| GBXML::Schedule.from_xml(element) }

    Mappers::DaySchedule.connect_model(model)
    Mappers::ScheduleRuleset.connect_model(model)
    Mappers::Space.connect_model(model)

    GBXML::DaySchedule.all.each { |schedule| Mappers::DaySchedule.insert(schedule) }
    GBXML::Schedule.all.each { |schedule| Mappers::ScheduleRuleset.insert(schedule) }

    gbxml_space = GBXML::Space.from_xml(document.get_elements('Space')[0])
    Mappers::Space.update_schedules(gbxml_space, os_space)
    default_schedule_set = os_space.defaultScheduleSet.get
    assert(default_schedule_set.numberofPeopleSchedule.get == Mappers::ScheduleRuleset.find(gbxml_space.people_schedule_id_ref))
    assert(default_schedule_set.lightingSchedule.get == Mappers::ScheduleRuleset.find(gbxml_space.light_schedule_id_ref))
    assert(default_schedule_set.electricEquipmentSchedule.get == Mappers::ScheduleRuleset.find(gbxml_space.equipment_schedule_id_ref))
  end

  def test_update_volume_no_existing_volume
    model = OpenStudio::Model::Model.new
    gbxml_space = GBXML::Space.new
    gbxml_space.volume = 100

    os_space = OpenStudio::Model::Space.new(model)
    os_thermal_zone = OpenStudio::Model::ThermalZone.new(model)
    os_space.setThermalZone(os_thermal_zone)

    Mappers::Space.update_volume(gbxml_space, os_space)
    assert(os_thermal_zone.volume.get == gbxml_space.volume)
  end

  def test_find_by_cad_object_id
    model = OpenStudio::Model::Model.new
    Mappers::Space.connect_model(model)
    expected_space = OpenStudio::Model::Space.new(model)
    expected_cad_object_id = "104801"
    expected_space.additionalProperties.setFeature('CADObjectId', expected_cad_object_id)
    found_space = Mappers::Space.find_by_cad_object_id(expected_cad_object_id)
    assert(expected_space == found_space)
  end

  def test_update_volume_add_to_existing_volume
    model = OpenStudio::Model::Model.new
    gbxml_space = GBXML::Space.new
    gbxml_space.volume = 100
    additional_volume = 50

    os_space = OpenStudio::Model::Space.new(model)
    os_thermal_zone = OpenStudio::Model::ThermalZone.new(model)
    os_thermal_zone.setVolume(additional_volume)
    os_space.setThermalZone(os_thermal_zone)

    Mappers::Space.update_volume(gbxml_space, os_space)
    assert(os_thermal_zone.volume.get == (gbxml_space.volume + additional_volume))
  end

  def test_calculate_sensible_heat_fraction
    assert(Space.calculate_sensible_heat_fraction(2.0, 1.0, 0) == 0.5)
    assert(Space.calculate_sensible_heat_fraction(nil, 1.0, 1.0) == 0.5)
    assert(Space.calculate_sensible_heat_fraction(2.0, nil, 1.0) == 0.5)
    assert(Space.calculate_sensible_heat_fraction(nil, nil, 1.0) == nil)
  end
end