class Zone < HVACObject
  attr_accessor :thermal_zone, :zone_hvac_equipment, :use_ideal_air_loads, :design_htg_temp, :design_clg_temp,
                :account_for_doas, :doas_low_setpoint, :doas_control_strategy, :doas_high_setpoint, :references

  COOLING_DESIGN_HUMIDITY_RATIO = 0.0085
  HEATING_DESIGN_HUMIDITY_RATIO = 0.005

  def initialize
    super()
    self.name = "Thermal Zone"
    self.references = []
    self.zone_hvac_equipment = []
  end

  def self.create_from_xml(model_manager, xml)
    zone = new
    zone.model_manager = model_manager
    zone.model = model_manager.model

    name = xml.elements['Name']
    zone.set_name(name.text) unless name.nil?
    zone.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    zone.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    xml.get_elements('ZoneHVACEquipmentId').each do |zone_hvac_equipment_id|
      zone.references << zone_hvac_equipment_id.attributes['zoneHVACEquipmentIdRef']
    end

    zone.use_ideal_air_loads = true if xml.get_elements('ZoneHVACEquipmentId').count == 0

    zone.thermal_zone = Helpers.get_thermal_zone_by_cad_object_id(zone.model, zone.cad_object_id)

    zone
  end

  def resolve_references
    self.references.each do |reference|
      equipment = self.model_manager.zone_hvac_equipments[reference]
      equipment.add_zone(self) if equipment
      self.zone_hvac_equipment << equipment if equipment
    end
  end

  def build
    # @type sizing_zone [OpenStudio::Model::SizingZone]
    sizing_zone = self.thermal_zone.sizingZone
    sizing_zone.setZoneCoolingDesignSupplyAirTemperatureInputMethod("SupplyAirTemperature")
    sizing_zone.setZoneHeatingDesignSupplyAirTemperatureInputMethod("SupplyAirTemperature")
    sizing_zone.setZoneCoolingDesignSupplyAirTemperature(self.design_clg_temp) if self.design_clg_temp
    sizing_zone.setZoneHeatingDesignSupplyAirTemperature(self.design_htg_temp) if self.design_htg_temp
    sizing_zone.setZoneCoolingDesignSupplyAirHumidityRatio(COOLING_DESIGN_HUMIDITY_RATIO)
    sizing_zone.setZoneHeatingDesignSupplyAirHumidityRatio(HEATING_DESIGN_HUMIDITY_RATIO)
    sizing_zone.setAccountforDedicatedOutdoorAirSystem(true) if self.account_for_doas
    sizing_zone.setDedicatedOutdoorAirSystemControlStrategy(self.doas_control_strategy) if self.doas_control_strategy
    sizing_zone.setDedicatedOutdoorAirLowSetpointTemperatureforDesign(self.doas_low_setpoint) if self.doas_low_setpoint
    sizing_zone.setDedicatedOutdoorAirHighSetpointTemperatureforDesign(self.doas_high_setpoint) if self.doas_high_setpoint

    @thermal_zone.setUseIdealAirLoads(true) if use_ideal_air_loads

    self.thermal_zone.additionalProperties.setFeature('id', self.id) unless self.id.nil?

    self.thermal_zone
  end
end
