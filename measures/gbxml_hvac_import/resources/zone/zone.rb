require 'openstudio'
require_relative '../model/helpers'

class Zone
  def self.map_to_zone_hvac_equipment(model, xml)
    name = xml.elements['Name']
    zone_hvac_equipment_id = xml.elements['ZoneHVACEquipmentId']

    unless zone_hvac_equipment_id.nil? or name.nil?
      zone_hvac_equipment_id_ref = zone_hvac_equipment_id.attributes['zoneHVACEquipmentIdRef']
      unless zone_hvac_equipment_id_ref.nil?
        hvac_component = Helpers.get_hvac_component_by_id(model, zone_hvac_equipment_id_ref)
        optional_zone = model.getThermalZoneByName(name.text)
        if optional_zone.is_initialized and !hvac_component.nil?
          zone = optional_zone.get
          outlet_node = hvac_component.to_StraightComponent.get.outletModelObject.get.to_Node.get
          zone.addToNode(outlet_node)
        end
      end
    end

    # need to get the zone in the osm from the xml id or name
    # once the zone is retrieved, find it's zoneHVACEquipmentID/Ref
    # retrieve the zoneHVACEquipmentIDRef
    # add zone to the zoneHVACEquipment outletModelObject
  end
end
