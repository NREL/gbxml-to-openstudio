module GBXML
    class DaySchedule
    attr_accessor :type, :id, :name, :schedule_values

    def initialize
      self.schedule_values = []
    end

    def self.from_xml(xml)
      day_schedule = new
      day_schedule.name = xml.elements['Name'].text unless xml.elements['Name'].nil?
      xml.get_elements('ScheduleValue').each do |schedule_value|
        day_schedule.schedule_values << schedule_value.text.to_f
      end

      day_schedule.id = xml.attributes['id'] unless xml.attributes['id'].nil?
      day_schedule.type = xml.attributes['type'] unless xml.attributes['type'].nil?

      day_schedule
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
