require_relative '../minitest_helper'

class TestSpace < MiniTest::Test
  def before_setup
    GBXML::Space.configure_units("F", "Feet", "SquareFeet", "CubicFeet")
  end

  def test_from_xml_populated()

    xml = <<EOF
      <Space zoneIdRef="aim0431" lightScheduleIdRef="aim0109" equipmentScheduleIdRef="aim0109" peopleScheduleIdRef="aim0115" id="aim0092">
        <InfiltrationFlowPerArea unit="LPerSecPerSquareM">0.19304</InfiltrationFlowPerArea>
        <PeopleNumber unit="NumberOfPeople">10</PeopleNumber>
        <PeopleHeatGain unit="WattPerPerson" heatGainType="Total">131.882</PeopleHeatGain>
        <PeopleHeatGain unit="WattPerPerson" heatGainType="Latent">58.61422</PeopleHeatGain>
        <PeopleHeatGain unit="WattPerPerson" heatGainType="Sensible">73.26777</PeopleHeatGain>
        <LightPowerPerArea unit="WattPerSquareMeter">10.76391</LightPowerPerArea>
        <EquipPowerPerArea unit="WattPerSquareMeter">13.99308</EquipPowerPerArea>
        <AirChangesPerHour>0</AirChangesPerHour>
        <OAFlowPerArea unit="LPerSecPerSquareM">0.3048</OAFlowPerArea>
        <OAFlowPerPerson unit="LPerSec">2.359737</OAFlowPerPerson>
        <OAFlowPerSpace unit="LPerSec">110.112</OAFlowPerSpace>
        <Area>284.24</Area>
        <Volume>1097.534</Volume>
        <Name>Space 1</Name>
        <Description>Classroom/Lecture/Training</Description>
        <CADObjectId>204851</CADObjectId>
      </Space>
EOF
    document = REXML::Document.new(xml)
    xml_space = GBXML::Space.from_xml(document.get_elements('Space')[0])
    memory_space = GBXML::Space.new
    # memory_space.space_type = "ClassroomOrLectureOrTraining"
    memory_space.zone_id_ref = "aim0431"
    memory_space.light_schedule_id_ref = "aim0109"
    memory_space.equipment_schedule_id_ref = "aim0109"
    memory_space.people_schedule_id_ref = "aim0115"
    memory_space.id = "aim0092"
    memory_space.infiltration_flow_per_area = 0.00019304000000000004
    memory_space.people_number = 10.0
    memory_space.people_heat_gain_total = 131.882
    memory_space.people_heat_gain_latent = 58.61422
    memory_space.people_heat_gain_sensible = 73.26777
    memory_space.light_power_per_area = 10.76391
    memory_space.equip_power_per_area = 13.99308
    memory_space.air_changes_per_hour = 0.0
    memory_space.oa_flow_per_area = 0.0003048000000000001
    memory_space.oa_flow_per_person = 0.0023597370000000006
    memory_space.oa_flow_per_space = 0.11011200000000002
    memory_space.volume = 31.078701907504136
    memory_space.name = "Space 1"
    memory_space.cad_object_id = "204851"

    assert(xml_space == memory_space)
  end

  def test_from_xml_empty
    xml = <<EOF
      <Space>
      </Space>
EOF
    document = REXML::Document.new(xml)
    xml_space = GBXML::Space.from_xml(document.get_elements('Space')[0])
    memory_space = GBXML::Space.new

    assert(xml_space == memory_space)
  end

  def test_calculate_infiltration_from_xml_imperial
    xml = <<EOF
      <InfiltrationFlowPerArea unit="CFMPerSquareFoot">0.038</InfiltrationFlowPerArea>
EOF
    expected_infiltration = 0.00019303999999999998

    element = REXML::Document.new(xml).elements['InfiltrationFlowPerArea']
    calculated_infiltration = GBXML::Space.convert_to_metric_from_xml(element)
    assert(expected_infiltration == calculated_infiltration)
  end

  def test_calculate_infiltration_from_xml_metric
    xml = <<EOF
      <InfiltrationFlowPerArea unit="LPerSecSquareMeter">0.038</InfiltrationFlowPerArea>
EOF
    expected_infiltration = 0.038

    element = REXML::Document.new(xml).elements['InfiltrationFlowPerArea']
    calculated_infiltration = GBXML::Space.convert_to_metric_from_xml(element)
    assert(expected_infiltration == calculated_infiltration)
  end

  def test_calculate_lighting_power_per_area_from_xml_imperial
    xml = <<EOF
     <LightPowerPerArea unit="WattPerSquareFoot">1</LightPowerPerArea>
EOF
    expected_value = 10.763910416709722

    element = REXML::Document.new(xml).elements['LightPowerPerArea']
    calculated_value = GBXML::Space.convert_to_metric_from_xml(element)
    assert(expected_value == calculated_value)
  end

  def test_calculate_lighting_power_per_area_from_xml_metric
    xml = <<EOF
     <LightPowerPerArea unit="WattPerSquareMeter">10.76391</LightPowerPerArea>
EOF
    expected_value = 10.76391

    element = REXML::Document.new(xml).elements['LightPowerPerArea']
    calculated_value = GBXML::Space.convert_to_metric_from_xml(element)
    assert(expected_value == calculated_value)
  end

  def test_calculate_equipment_power_per_area_from_xml_imperial
    xml = <<EOF
       <EquipmentPowerPerArea unit="WattPerSquareFoot">1</EquipmentPowerPerArea>
EOF
    expected_value = 10.763910416709722

    element = REXML::Document.new(xml).elements['EquipmentPowerPerArea']
    calculated_value = GBXML::Space.convert_to_metric_from_xml(element)
    assert(expected_value == calculated_value)
  end

  def test_calculate_equipment_power_per_area_from_xml_metric
    xml = <<EOF
       <EquipmentPowerPerArea unit="WattPerSquareMeter">10.76391</EquipmentPowerPerArea>
EOF
    expected_value = 10.76391

    element = REXML::Document.new(xml).elements['EquipmentPowerPerArea']
    calculated_value = GBXML::Space.convert_to_metric_from_xml(element)
    assert(expected_value == calculated_value)
  end

  def test_calculate_people_heat_gain_from_xml_imperial
    xml = <<EOF
        <PeopleHeatGain unit="BtuPerHourPerson" heatGainType="Total">450</PeopleHeatGain>
EOF
    expected_value = 131.8819815775

    element = REXML::Document.new(xml).elements['PeopleHeatGain']
    calculated_value = GBXML::Space.convert_to_metric_from_xml(element)
    assert(expected_value == calculated_value)
  end

  def test_calculate_people_heat_gain_from_xml_metric
    xml = <<EOF
        <PeopleHeatGain unit="WattPerPerson" heatGainType="Total">131.882</PeopleHeatGain>
EOF
    expected_value = 131.882

    element = REXML::Document.new(xml).elements['PeopleHeatGain']
    calculated_value = GBXML::Space.convert_to_metric_from_xml(element)
    assert(expected_value == calculated_value)
  end
end