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
    document = REXML::Document.new(xml).elements['gbXML']
    gbxml = GBXML::GBXML.from_xml(document)
    mapper = Mappers::Mapper.new(gbxml, model)
    mapper.day_schedule.insert(gbxml.day_schedules['aim0027'])
    gbxml_schedule = gbxml.schedules['aim0030']
    # @type [OpenStudio::Model::ScheduleRuleset] os_schedule
    os_schedule = mapper.schedule.insert(gbxml.schedules['aim0030'])

    assert(os_schedule.name.get == gbxml_schedule.name)
    schedule_rule = os_schedule.scheduleRules[0]
    gbxml_year_schedule = gbxml_schedule.year_schedules[0]

    assert(schedule_rule.startDate.get.monthOfYear.value == gbxml_year_schedule.begin_date.month)
    assert(schedule_rule.startDate.get.dayOfMonth == gbxml_year_schedule.begin_date.day)
    assert(schedule_rule.endDate.get.monthOfYear.value == gbxml_year_schedule.end_date.month)
    assert(schedule_rule.endDate.get.dayOfMonth == gbxml_year_schedule.end_date.day)

  end
end