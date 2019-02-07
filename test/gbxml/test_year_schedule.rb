require 'date'
require_relative '../minitest_helper'

class TestYearSchedule < MiniTest::Test

  def test_from_xml_populated
    xml = <<EOF
      <YearSchedule id="aim0160">
        <BeginDate>2019-01-01</BeginDate>
        <EndDate>2019-12-31</EndDate>
        <WeekScheduleId weekScheduleIdRef="aim0157" />
      </YearSchedule>
EOF

    document = REXML::Document.new(xml)
    xml_schedule = GBXML::YearSchedule.from_xml(document.get_elements('YearSchedule')[0])
    memory_schedule = GBXML::YearSchedule.new
    memory_schedule.begin_date = Date.parse("2019-01-01")
    memory_schedule.end_date = Date.parse("2019-12-31")
    memory_schedule.week_schedule_id = "aim0157"
    memory_schedule.id = 'aim0160'

    puts memory_schedule.begin_date.month

    assert(memory_schedule == xml_schedule)
  end

  def test_from_xml_empty
    xml = <<EOF
      <YearSchedule>
      </YearSchedule>
EOF
    document = REXML::Document.new(xml)
    xml_schedule = GBXML::YearSchedule.from_xml(document.get_elements('YearSchedule')[0])
    memory_schedule = GBXML::YearSchedule.new

    assert(xml_schedule == memory_schedule)
  end
end