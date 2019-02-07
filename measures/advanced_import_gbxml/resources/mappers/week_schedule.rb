module Mappers
  class WeekSchedule < BaseMapper
    def initialize(os_model)
      super(os_model)
    end

    def insert(gbxml_week_schedule)
      os_week_schedule = OpenStudio::Model::ScheduleWeek.new(@os_model)
      os_week_schedule.setName(gbxml_week_schedule.name) if gbxml_week_schedule.name
      gbxml_week_schedule.schedule_values.each_with_index do |value, i|
        time = OpenStudio::Time.new(0, i + 1, 0, 0)
        os_week_schedule.addValue(time, value)
      end

      if gbxml_week_schedule.id
        @loaded_objects[gbxml_week_schedule.id] = os_week_schedule
      end
    end
  end
end