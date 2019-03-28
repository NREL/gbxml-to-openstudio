require_relative '../minitest_helper'

class TestDaySchedule < MiniTest::Test

  def test_from_xml_populated
    xml = <<EOF
  <DaySchedule type="Fraction" id="aim0027">
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0.3</ScheduleValue>
    <ScheduleValue>0.85</ScheduleValue>
    <ScheduleValue>0.95</ScheduleValue>
    <ScheduleValue>0.95</ScheduleValue>
    <ScheduleValue>0.95</ScheduleValue>
    <ScheduleValue>0.8</ScheduleValue>
    <ScheduleValue>0.8</ScheduleValue>
    <ScheduleValue>0.8</ScheduleValue>
    <ScheduleValue>0.7</ScheduleValue>
    <ScheduleValue>0.5</ScheduleValue>
    <ScheduleValue>0.5</ScheduleValue>
    <ScheduleValue>0.35</ScheduleValue>
    <ScheduleValue>0.35</ScheduleValue>R
    <ScheduleValue>0.3</ScheduleValue>
    <ScheduleValue>0.3</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <Name>School Lighting - 7 AM to 9 PM</Name>
  </DaySchedule>
EOF

    document = REXML::Document.new(xml)
    xml_day_schedule = GBXML::DaySchedule.from_xml(document.get_elements('DaySchedule')[0])
    memory_day_schedule = GBXML::DaySchedule.new
    memory_day_schedule.type = "Fraction"
    memory_day_schedule.id = "aim0027"
    memory_day_schedule.name = "School Lighting - 7 AM to 9 PM"
    memory_day_schedule.schedule_values = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.85, 0.95, 0.95, 0.95, 0.8, 0.8, 0.8, 0.7, 0.5, 0.5, 0.35, 0.35, 0.3, 0.3, 0.0, 0.0]

    assert(xml_day_schedule == memory_day_schedule)
  end

  def test_from_xml_empty
    xml = <<EOF
      <DaySchedule>
      </DaySchedule>
EOF
    document = REXML::Document.new(xml)
    xml_day_schedule = GBXML::DaySchedule.from_xml(document.get_elements('DaySchedule')[0])
    memory_day_schedule = GBXML::DaySchedule.new

    assert(xml_day_schedule == memory_day_schedule)
  end

  def test_day_schedule_find
    xml = <<EOF
  <DaySchedule type="Fraction" id="aim0027">
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0.3</ScheduleValue>
    <ScheduleValue>0.85</ScheduleValue>
    <ScheduleValue>0.95</ScheduleValue>
    <ScheduleValue>0.95</ScheduleValue>
    <ScheduleValue>0.95</ScheduleValue>
    <ScheduleValue>0.8</ScheduleValue>
    <ScheduleValue>0.8</ScheduleValue>
    <ScheduleValue>0.8</ScheduleValue>
    <ScheduleValue>0.7</ScheduleValue>
    <ScheduleValue>0.5</ScheduleValue>
    <ScheduleValue>0.5</ScheduleValue>
    <ScheduleValue>0.35</ScheduleValue>
    <ScheduleValue>0.35</ScheduleValue>R
    <ScheduleValue>0.3</ScheduleValue>
    <ScheduleValue>0.3</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <ScheduleValue>0</ScheduleValue>
    <Name>School Lighting - 7 AM to 9 PM</Name>
  </DaySchedule>
EOF

    document = REXML::Document.new(xml)
    expected_schedule = GBXML::DaySchedule.from_xml(document.get_elements('DaySchedule')[0])
    retrieved_schedule = GBXML::DaySchedule.find(document.get_elements('DaySchedule')[0].attributes['id'])
    assert(expected_schedule == retrieved_schedule)
  end
end