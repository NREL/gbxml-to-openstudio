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

      xml.get_elements('DaySchedule').each { |element| DaySchedule.from_xml(element) }
      xml.get_elements('WeekSchedule').each { |element| WeekSchedule.from_xml(element) }
      xml.get_elements('YearSchedule').each { |element| YearSchedule.from_xml(element) }
      xml.get_elements('Schedule').each { |element| Schedule.from_xml(element) }

      gbxml
    end
  end
end