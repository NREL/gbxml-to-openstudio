# require_relative '../vav_box/vav_box'
# require_relative '../cav_box/cav_box'
# require_relative '../ptac/ptac'
# require_relative '../pthp/pthp'
# require_relative '../unit_heater/unit_heater'

class ZoneHVACEquipment
  # This can be a factory based on the zoneHVACEquipmentType
  def self.equipment_type_mapping(xml)
    equipment_type = xml.attributes['zoneHVACEquipmentType']
    unless equipment_type.nil?
      case equipment_type
      when 'VAVBox'
        VAVBox.create_from_xml(xml)
      when 'CAVBox'
        CAVBox.create_from_xml(xml)
      when 'PackagedTerminalAirConditioner'
        PTAC.create_from_xml(xml)
      when 'PackagedTerminalHeatPump'
        PTHP.create_from_xml(xml)
      when 'UnitHeater'
        UnitHeater.create_from_xml(xml)
      end
    end
  end
end