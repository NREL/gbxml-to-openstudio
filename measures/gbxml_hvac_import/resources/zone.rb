class Zone < HVACObject
  attr_accessor :thermal_zone, :zone_hvac_equipment_refs, :use_ideal_air_loads

  def initialize
    self.name = "Thermal Zone"
    self.zone_hvac_equipment_refs = []
  end

  def build
    self.model = model_manager.model if self.model_manager
    self.thermal_zone = Helpers.get_thermal_zone_by_cad_object_id(model, cad_object_id)

    self.zone_hvac_equipment_refs.each do |zone_hvac_equipment_ref|
      equipment = model_manager.zone_hvac_equipments[zone_hvac_equipment_ref]
      equipment.connect_thermal_zone(self.thermal_zone) unless equipment.nil?
    end

    @thermal_zone.setUseIdealAirLoads(true) if use_ideal_air_loads

    self.thermal_zone.additionalProperties.setFeature('id', self.id) unless self.id.nil?

    self.thermal_zone
  end

  def self.create_from_xml(model_manager, xml)
    zone = new
    zone.model_manager = model_manager

    name = xml.elements['Name']
    zone.set_name(name.text) unless name.nil?
    zone.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    zone.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?
    # puts xml.elements['ZoneHVACEquipmentId']
    xml.get_elements('ZoneHVACEquipmentId').each do |zone_hvac_equipment_id|
      zone.zone_hvac_equipment_refs << zone_hvac_equipment_id.attributes['zoneHVACEquipmentIdRef']
    end

    zone.use_ideal_air_loads = true if xml.get_elements('ZoneHVACEquipmentId').count == 0

    zone
  end
end
