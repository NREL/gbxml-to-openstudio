require_relative '../minitest_helper'

class TestSchedule < MiniTest::Test

  def test_insert_schedule
    xml = <<EOF
    <gbXML>
      <Schedule type="Fraction" id="aim0030">
        <YearSchedule id="aim0031">
          <BeginDate>2019-01-01</BeginDate>
          <EndDate>2019-12-31</EndDate>
          <WeekScheduleId weekScheduleIdRef="aim0028" />
        </YearSchedule>
        <Name>School Lighting - 7 AM to 9 PM</Name>
      </Schedule>
      <WeekSchedule type="Fraction" id="aim0028">
        <Day dayScheduleIdRef="aim0027" dayType="All" />
        <Name>School Lighting - 7 AM to 9 PM</Name>
      </WeekSchedule>
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
        <ScheduleValue>0.35</ScheduleValue>
        <ScheduleValue>0.3</ScheduleValue>
        <ScheduleValue>0.3</ScheduleValue>
        <ScheduleValue>0</ScheduleValue>
        <ScheduleValue>0</ScheduleValue>
        <Name>School Lighting - 7 AM to 9 PM</Name>
      </DaySchedule>
    </gbXML>
EOF


    model = OpenStudio::Model::Model.new
    document = REXML::Document.new(xml).get_elements('gbXML')[0]
    gbxml_day_schedule = GBXML::DaySchedule.from_xml(document.get_elements('DaySchedule')[0])
    GBXML::WeekSchedule.from_xml(document.get_elements('WeekSchedule')[0])
    gbxml_schedule = GBXML::Schedule.from_xml(document.get_elements('Schedule')[0])
    day_schedule_mapper = Mappers::DaySchedule.new(model)
    os_day_schedule = day_schedule_mapper.insert(gbxml_day_schedule)

    schedule_mapper = Mappers::ScheduleRuleset.new(model)
    os_schedule = schedule_mapper.insert(gbxml_schedule)

    assert(os_schedule.name.get == gbxml_schedule.name)
    schedule_rule = os_schedule.scheduleRules[0]
    gbxml_year_schedule = gbxml_schedule.year_schedules[0]

    assert(schedule_rule.startDate.get.monthOfYear.value == gbxml_year_schedule.begin_date.month)
    assert(schedule_rule.startDate.get.dayOfMonth == gbxml_year_schedule.begin_date.day)
    assert(schedule_rule.endDate.get.monthOfYear.value == gbxml_year_schedule.end_date.month)
    assert(schedule_rule.endDate.get.dayOfMonth == gbxml_year_schedule.end_date.day)

    assert(data_fields_equal?(schedule_rule.daySchedule, os_day_schedule))
  end

  def test_day_schedule_find
      model = OpenStudio::Model::Model.new
      gbxml_schedule = GBXML::Schedule.new
      gbxml_schedule.id = "aim0345"
      gbxml_schedule.name = "TestName"

      schedule_mapper = Mappers::ScheduleRuleset.new(model)
      expected_schedule = schedule_mapper.insert(gbxml_schedule)
      found_schedule = schedule_mapper.find(gbxml_schedule.id)

      assert(expected_schedule == found_schedule)
  end
end