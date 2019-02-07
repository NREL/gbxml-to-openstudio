module GBXML
  class Schedule
    attr_accessor :year_schedules, :name, :type, :id

    def initialize
      @year_schedules = []
    end

    def self.from_xml(xml)
      schedule = new
      schedule.name = xml.elements['Name'].text unless xml.elements['Name'].nil?

      xml.get_elements('YearSchedule').each do |day|
        schedule.year_schedules << YearSchedule.from_xml(day)
      end

      schedule.id = xml.attributes['id'] unless xml.attributes['id'].nil?
      schedule.type = xml.attributes['type'] unless xml.attributes['type'].nil?

      schedule
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