module GBXML
  class Day
    attr_accessor :day_schedule_id_ref, :day_type

    def self.from_xml(xml)
      day = new
      day.day_schedule_id_ref = xml.attributes['dayScheduleIdRef'] unless xml.attributes['dayScheduleIdRef'].nil?
      day.day_type = xml.attributes['dayType'] unless xml.attributes['dayType'].nil?

      day
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