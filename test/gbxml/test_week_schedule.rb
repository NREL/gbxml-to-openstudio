require_relative '../minitest_helper'

class TestWeekSchedule < MiniTest::Test

  def test_from_xml_populated
    xml = <<EOF
  <WeekSchedule type="Fraction" id="aim0028">
    <Day dayScheduleIdRef="aim0027" dayType="All" />
    <Name>School Lighting - 7 AM to 9 PM</Name>
  </WeekSchedule>
EOF

    document = REXML::Document.new(xml)
    xml_week_schedule = GBXML::WeekSchedule.from_xml(document.get_elements('WeekSchedule')[0])
    memory_week_schedule = GBXML::WeekSchedule.new
    memory_week_schedule.id = "aim0028"
    memory_week_schedule.type = "Fraction"
    day = GBXML::Day.new()
    day.day_schedule_id_ref = "aim0027"
    day.day_type = "All"
    memory_week_schedule.days << day
    memory_week_schedule.name = "School Lighting - 7 AM to 9 PM"

    assert(xml_week_schedule == memory_week_schedule)
  end

  def test_from_xml_empty
    xml = <<EOF
  <WeekSchedule>
  </WeekSchedule>
EOF
    document = REXML::Document.new(xml)
    xml_week_schedule = GBXML::WeekSchedule.from_xml(document.get_elements('WeekSchedule')[0])
    memory_week_schedule = GBXML::WeekSchedule.new

    assert(xml_week_schedule == memory_week_schedule)
  end

  def test_week_schedule_find
    xml = <<EOF
  <WeekSchedule type="Fraction" id="aim0028">
    <Day dayScheduleIdRef="aim0027" dayType="All" />
    <Name>School Lighting - 7 AM to 9 PM</Name>
  </WeekSchedule>
EOF

    document = REXML::Document.new(xml)
    expected_schedule = GBXML::WeekSchedule.from_xml(document.get_elements('WeekSchedule')[0])
    retrieved_schedule = GBXML::WeekSchedule.find(document.get_elements('WeekSchedule')[0].attributes['id'])
    assert(expected_schedule == retrieved_schedule)
  end
end