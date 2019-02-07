module GBXML
  class GBXML
    attr_accessor :campus, :schedules, :week_schedules, :day_schedules

    def initialize
      self.schedules = {}
      self.week_schedules = {}
      self.day_schedules = {}
    end

    def self.from_xml(xml)
      gbxml = new
      gbxml.campus = xml.elements['Campus'] if xml.elements['Campus']

      xml.get_elements('Schedule').each do |element|
        schedule = Schedule.from_xml(element)
        gbxml.schedules[schedule.id] = schedule unless schedule.id.nil?
      end

      xml.get_elements('WeekSchedule').each do |element|
        schedule = WeekSchedule.from_xml(element)
        gbxml.week_schedules[schedule.id] = schedule unless schedule.id.nil?
      end

      xml.get_elements('DaySchedule').each do |element|
        schedule = DaySchedule.from_xml(element)
        gbxml.day_schedules[schedule.id] = schedule unless schedule.id.nil?
      end

      gbxml
    end
  end
end