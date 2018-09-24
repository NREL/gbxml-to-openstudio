require_relative '../hvac_object/hvac_object'

class Zone < HVACObject
  attr_accessor :thermal_zone, :zone_hvac_equipment_refs

  def initialize
    self.name = "Thermal Zone"
    self.zone_hvac_equipment_refs = []
  end

  def build(model_manager)
    self.model_manager = model_manager
    self.model = model_manager.model
    self.thermal_zone = self.model.getThermalZoneByName(self.name).get

    self.zone_hvac_equipment_refs.each do |zone_hvac_equipment_ref|
      equipment = model_manager.zone_hvac_equipments[zone_hvac_equipment_ref]
      equipment.connect_thermal_zone(self.thermal_zone)
      # equipment = model_manager.zone_hvac_equipments[zone_hvac_equipment_ref].ptac
      # equipment.addToThermalZone(self.thermal_zone)
      # outlet_node = equipment.outletModelObject.get.to_Node.get
      # self.thermal_zone.addToNode(outlet_node)
    end

    self.thermal_zone.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    self.thermal_zone.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?

    self.thermal_zone
  end

  def self.create_from_xml(xml)
    zone = new

    name = xml.elements['Name']
    zone.set_name(name.text) unless name.nil?
    zone.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    zone.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?
    # puts xml.elements['ZoneHVACEquipmentId']
    xml.get_elements('ZoneHVACEquipmentId').each do |zone_hvac_equipment_id|
      zone.zone_hvac_equipment_refs << zone_hvac_equipment_id.attributes['zoneHVACEquipmentIdRef']
    end

    zone
  end

  def self.map_to_zone_hvac_equipment(xml)
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
