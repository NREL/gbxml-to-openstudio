require 'date'

module GBXML
  class YearSchedule
    attr_accessor :begin_date, :end_date, :week_schedule_id, :name, :id

    def self.from_xml(xml)
      year_schedule = new
      year_schedule.name = xml.elements['Name'].text unless xml.elements['Name'].nil?
      year_schedule.begin_date = Date.parse(xml.elements['BeginDate'].text) unless xml.elements['BeginDate'].nil?
      year_schedule.end_date = Date.parse(xml.elements['EndDate'].text) unless xml.elements['EndDate'].nil?
      week_schedule_id = xml.elements['WeekScheduleId'] unless xml.elements['WeekScheduleId'].nil?
      if week_schedule_id
        year_schedule.week_schedule_id = week_schedule_id.attributes['weekScheduleIdRef'] unless week_schedule_id.attributes['weekScheduleIdRef'].nil?
      end

      year_schedule.id = xml.attributes['id'] unless xml.attributes['id'].nil?

      year_schedule
    end

    def ==(other)
      equal = true
      self.instance_variables.each do |variable|
        unless self.instance_variable_get(variable) == other.instance_variable_get(variable)
          equal = false
          break
        end
      end

      return equal
    end
  end
end