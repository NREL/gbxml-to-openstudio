module Mappers
  class Mapper
    attr_accessor :os_model, :day_schedule, :schedule, :space

    def initialize(os_model)
      @os_model = os_model
      Mappers::DaySchedule.connect_model(os_model)
      Mappers::Schedule.connect_model(os_model)
      Mappers::Space.connect_model(os_model)
    end

    def translate_gbxml_to_os
      GBXML::DaySchedule.all.each { |schedule| Mappers::DaySchedule.insert(schedule) }
      GBXML::Schedule.all.each { |schedule| Mappers::ScheduleRuleset.insert(schedule) }
      GBXML::Space.all.each do |gbxml_space|
        next if gbxml_space.cad_object_id.nil?
        os_space = Mappers::Space.find_by_cad_object_id(gbxml_space.cad_object_id)
        Mappers::Space.update(gbxml_space, os_space) unless os_space.nil?
      end
    end
  end
end