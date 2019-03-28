module GBXML
  class WeekSchedule
    @@instances = {}
    attr_accessor :type, :id, :days, :name

    def initialize
      self.days = []
    end

    def self.instances
      return @@instances
    end

    def self.from_xml(xml)
      week_schedule = new
      week_schedule.name = xml.elements['Name'].text unless xml.elements['Name'].nil?

      xml.get_elements('Day').each do |day|
        week_schedule.days << Day.from_xml(day)
      end

      week_schedule.id = xml.attributes['id'] unless xml.attributes['id'].nil?
      week_schedule.type = xml.attributes['type'] unless xml.attributes['type'].nil?

      @@instances[week_schedule.id] = week_schedule
      week_schedule
    end

    def self.find(id)
      if @@instances.key?(id)
        return @@instances[id]
      end
    end

    def self.all
      return @@instances.values
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