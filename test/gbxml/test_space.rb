require_relative '../minitest_helper'

class TestSpace < MiniTest::Test

  def test_from_xml_populated()

    xml = <<EOF
      <Space spaceType="ClassroomOrLectureOrTraining" zoneIdRef="aim0852" lightScheduleIdRef="aim0030" equipmentScheduleIdRef="aim0030" peopleScheduleIdRef="aim0036" conditionType="HeatedAndCooled" id="aim0014">
        <InfiltrationFlowPerArea unit="CFMPerSquareFoot">0.038</InfiltrationFlowPerArea>
        <PeopleNumber unit="NumberOfPeople">72</PeopleNumber>
        <PeopleHeatGain unit="BtuPerHourPerson" heatGainType="Total">240</PeopleHeatGain>
        <PeopleHeatGain unit="BtuPerHourPerson" heatGainType="Latent">120</PeopleHeatGain>
        <PeopleHeatGain unit="BtuPerHourPerson" heatGainType="Sensible">120</PeopleHeatGain>
        <LightPowerPerArea unit="WattPerSquareFoot">1.999</LightPowerPerArea>
        <EquipPowerPerArea unit="WattPerSquareFoot">2</EquipPowerPerArea>
        <AirChangesPerHour>0</AirChangesPerHour>
        <OAFlowPerArea unit="CFMPerSquareFoot">0.06</OAFlowPerArea>
        <OAFlowPerPerson unit="CFM">7.5</OAFlowPerPerson>
        <OAFlowPerSpace unit="CFM">626.08</OAFlowPerSpace>
        <Area>1798</Area>
        <Volume>17213.08</Volume>
        <Name>Space 1</Name>
        <Description>Classroom/Lecture/Training</Description>
        <CADObjectId>280876</CADObjectId>
      </Space>
EOF
    document = REXML::Document.new(xml)
    xml_space = GBXML::Space.from_xml(document.get_elements('Space')[0])
    memory_space = GBXML::Space.new
    memory_space.space_type = "ClassroomOrLectureOrTraining"
    memory_space.zone_id_ref = "aim0852"
    memory_space.light_schedule_id_ref = "aim0030"
    memory_space.equipment_schedule_id_ref = "aim0030"
    memory_space.people_schedule_id_ref = "aim0036"
    memory_space.condition_type = "HeatedAndCooled"
    memory_space.id = "aim0014"
    memory_space.infiltration_flow_per_area = "0.038"
    memory_space.people_number = "72"
    memory_space.people_heat_gain_total = "240"
    memory_space.people_heat_gain_latent = "120"
    memory_space.people_heat_gain_sensible = "120"
    memory_space.light_power_per_area = "1.999"
    memory_space.equip_power_per_area = "2"
    memory_space.air_changes_per_hour = "0"
    memory_space.oa_flow_per_area = "0.06"
    memory_space.oa_flow_per_person = "7.5"
    memory_space.oa_flow_per_space = "626.08"
    memory_space.volume = "17213.08"
    memory_space.name = "Space 1"
    memory_space.cad_object_id = "280876"

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
end