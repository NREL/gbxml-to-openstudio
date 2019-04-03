module GBXML
  class Zone
    @@instances = {}
    attr_accessor :design_heat_t, :design_cool_t, :id, :name, :cad_object_id

    def self.from_xml(xml)
      space.name = xml.elements['Name'].text unless xml.elements['Name'].nil?
      space.id = xml.attributes['id'] unless xml.attributes['id'].nil?
      space.design_heat_t = convert_to_metric_from_xml(xml.elements['DesignHeatT']) unless xml.elements['DesignHeatT'].nil?
      space.design_cool_t = convert_to_metric_from_xml(xml.elements['DesignCoolT']) unless xml.elements['DesignCoolT'].nil?
    end

    def self.convert_to_metric_from_xml(xml, unit = nil)
      value = xml.text.to_f
      unit = xml.attributes['unit'] if unit.nil?
      case unit
      when "F"
        return OpenStudio.convert(value, "F", "C").get
      end

      return value
    end
  end
end