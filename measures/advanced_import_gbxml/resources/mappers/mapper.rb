module Mappers
  class Mapper
    attr_accessor :gbxml, :os_model, :day_schedule, :schedule, :space

    def initialize(gbxml, os_model)
      @gbxml = gbxml
      @os_model = os_model
      @day_schedule = Mappers::DaySchedule.new(os_model)
      @schedule = Mappers::Schedule.new(@gbxml, self, os_model)
      @space = Mappers::Space.new(os_model)
    end

    def translate_gbxml_to_os
      @gbxml.day_schedules.values.each do |day_schedule|
        @day_schedule.insert(day_schedule)
      end

      @gbxml.schedules.values.each do |schedule|
        @schedule.insert(schedule)
      end
    end
  end
end