require_relative '../minitest_helper'

class TestSchedule < MiniTest::Test

  def test_from_xml_populated
    xml = <<EOF
      <Schedule type="Fraction" id="aim0159">
        <YearSchedule id="aim0160">
          <BeginDate>2019-01-01</BeginDate>
          <EndDate>2019-12-31</EndDate>
          <WeekScheduleId weekScheduleIdRef="aim0157" />
        </YearSchedule>
        <Name>Restaurant Occupancy - Lunch and Dinner</Name>
      </Schedule>
EOF

    document = REXML::Document.new(xml)
    xml_schedule = GBXML::Schedule.from_xml(document.get_elements('Schedule')[0])
    memory_schedule = GBXML::Schedule.new
    memory_schedule.type = "Fraction"
    memory_schedule.id = "aim0159"
    memory_schedule.name = "Restaurant Occupancy - Lunch and Dinner"
    year_schedule_xml = <<EOF
    <YearSchedule id="aim0160">
      <BeginDate>2019-01-01</BeginDate>
      <EndDate>2019-12-31</EndDate>
      <WeekScheduleId weekScheduleIdRef="aim0157" />
    </YearSchedule>
EOF
    year_schedule_doc = REXML::Document.new(year_schedule_xml)
    year_schedule = GBXML::YearSchedule.from_xml(year_schedule_doc.get_elements('YearSchedule')[0])
    memory_schedule.year_schedules << year_schedule

    assert(xml_schedule == memory_schedule)
  end

  def test_from_xml_empty
    xml = <<EOF
      <Schedule>
      </Schedule>
EOF
    document = REXML::Document.new(xml)
    xml_schedule = GBXML::Schedule.from_xml(document.get_elements('Schedule')[0])
    memory_schedule = GBXML::Schedule.new

    assert(xml_schedule == memory_schedule)
  end

  def test_schedule_find
    xml = <<EOF
      <Schedule type="Fraction" id="aim0159">
        <YearSchedule id="aim0160">
          <BeginDate>2019-01-01</BeginDate>
          <EndDate>2019-12-31</EndDate>
          <WeekScheduleId weekScheduleIdRef="aim0157" />
        </YearSchedule>
        <Name>Restaurant Occupancy - Lunch and Dinner</Name>
      </Schedule>
EOF

    document = REXML::Document.new(xml)
    expected_schedule = GBXML::Schedule.from_xml(document.get_elements('Schedule')[0])
    retrieved_schedule = GBXML::Schedule.find(document.get_elements('Schedule')[0].attributes['id'])
    assert(expected_schedule == retrieved_schedule)
  end
end