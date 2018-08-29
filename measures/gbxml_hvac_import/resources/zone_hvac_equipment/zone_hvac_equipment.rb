require_relative '../vav_box/vav_box'

class ZoneHVACEquipment
  # This can be a factory based on the zoneHVACEquipmentType
  def self.equipment_type_mapping(model, std, xml)
    equipment_type = xml.attributes['zoneHVACEquipmentType']
    unless equipment_type.nil?
      if equipment_type == 'VAVBox'
        VAVBox.create_vav_box_from_xml(model, std, xml)
      end
    end
  end
end