module Mappers
  class DaySchedule < BaseMapper
    @@instances = {}

    def initialize(os_model)
      super(os_model)
    end

    def insert(gbxml_day_schedule)
      os_day_schedule = OpenStudio::Model::ScheduleDay.new(@os_model)
      os_day_schedule.setName(gbxml_day_schedule.name) if gbxml_day_schedule.name

      gbxml_day_schedule.schedule_values.each_with_index do |value, i|
        time = OpenStudio::Time.new(0, i + 1, 0, 0)
        os_day_schedule.addValue(time, value)
      end

      if gbxml_day_schedule.id
        @@instances[gbxml_day_schedule.id] = os_day_schedule
      end

      os_day_schedule
    end

    def self.find(id)
      if @@instances.key?(id)
        return @@instances[id]
      end
    end
  end
end