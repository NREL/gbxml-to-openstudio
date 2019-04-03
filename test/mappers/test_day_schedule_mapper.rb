require_relative '../minitest_helper'
require_relative '../../measures/advanced_import_gbxml/resources/gbxml/day_schedule'
require_relative '../../measures/advanced_import_gbxml/resources/mappers/day_schedule'

class TestDayScheduleMapper < MiniTest::Test

  include Mappers

  def test_insert_day_schedule
    model = OpenStudio::Model::Model.new
    gbxml_day_schedule = GBXML::DaySchedule.new
    gbxml_day_schedule.schedule_values = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0,
                                          15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0]

    Mappers::DaySchedule.connect_model(model)
    os_day_schedule = Mappers::DaySchedule.insert(gbxml_day_schedule)

    assert(gbxml_day_schedule.schedule_values == os_day_schedule.values)
  end

  def test_day_schedule_find
    model = OpenStudio::Model::Model.new
    gbxml_day_schedule = GBXML::DaySchedule.new
    gbxml_day_schedule.id = "aim0345"
    gbxml_day_schedule.name = "TestName"

    Mappers::DaySchedule.connect_model(model)
    expected_schedule = Mappers::DaySchedule.insert(gbxml_day_schedule)
    found_schedule = Mappers::DaySchedule.find(gbxml_day_schedule.id)

    assert(expected_schedule == found_schedule)
  end
end