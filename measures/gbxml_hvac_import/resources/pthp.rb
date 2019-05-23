class PTHP < ZoneHVACEquipment
  attr_accessor :pthp, :supply_fan, :cooling_coil, :heating_coil, :supplemental_heating_coil, :draw_ventilation
  COOLING_DESIGN_TEMP = 12.777778
  HEATING_DESIGN_TEMP = 40

  def initialize
    super()
    self.name = "PTHP"
  end

  def self.create_from_xml(model_manager, xml)
    equipment = new
    equipment.model_manager = model_manager

    name = xml.elements['Name']
    equipment.set_name(xml.elements['Name'].text) unless name.nil?
    equipment.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    equipment.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?
    equipment.draw_ventilation = xml.attributes['DrawVentilation'] == "True" ? true : false

    equipment
  end

  def design_htg_temp
    HEATING_DESIGN_TEMP
  end

  def design_clg_temp
    COOLING_DESIGN_TEMP
  end

  def resolve_read_relationships
    self.zone.design_clg_temp = design_clg_temp
    self.zone.design_htg_temp = design_htg_temp
  end

  def build
    self.model_manager = model_manager
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.supply_fan = add_supply_fan
    self.cooling_coil = add_cooling_coil
    self.supplemental_heating_coil = add_supplemental_heating_coil
    self.pthp = add_pthp
  end

  def connect
    self.pthp.addToThermalZone(self.zone.thermal_zone) if self.zone.thermal_zone
  end

  def post_build
    self.zone.thermal_zone.setCoolingPriority(self.pthp, 0)
    self.zone.thermal_zone.setHeatingPriority(self.pthp, 0)
  end

  private

  def add_pthp
    pthp = OpenStudio::Model::ZoneHVACPackagedTerminalHeatPump.new(self.model, self.model.alwaysOnDiscreteSchedule, self.supply_fan, self.heating_coil, self.cooling_coil, self.supplemental_heating_coil)
    pthp.setName(self.name) unless self.name.nil?
    pthp.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    pthp.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?

    pthp.setOutdoorAirFlowRateDuringCoolingOperation(0) unless self.draw_ventilation
    pthp.setOutdoorAirFlowRateDuringHeatingOperation(0) unless self.draw_ventilation
    pthp.setOutdoorAirFlowRateWhenNoCoolingorHeatingisNeeded(0) unless self.draw_ventilation

    pthp
  end

  def add_supply_fan
    if self.draw_ventilation
      fan = OpenStudio::Model::FanConstantVolume.new(self.model)
    else
      fan = OpenStudio::Model::FanOnOff.new(self.model)
    end

    fan.setName("#{self.name} + Fan")
    fan.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    fan
  end

  def add_heating_coil
    heating_coil = OpenStudio::Model::CoilHeatingDXSingleSpeed.new(self.model)
    heating_coil.setName("#{self.name} + Heating Coil")
    heating_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    heating_coil.additionalProperties.setFeature('coil_type', 'primary_heating')
    heating_coil
  end

  def add_cooling_coil
    cooling_coil = OpenStudio::Model::CoilCoolingDXSingleSpeed.new(self.model)
    cooling_coil.setName("#{self.name} + Cooling Coil")
    cooling_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    cooling_coil.additionalProperties.setFeature('coil_type', 'primary_cooling')
    cooling_coil
  end

  def add_supplemental_heating_coil
    heating_coil = OpenStudio::Model::CoilHeatingElectric.new(self.model)
    heating_coil.setName("#{self.name} + Supplemental Heating Coil")
    heating_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    heating_coil.additionalProperties.setFeature('coil_type', 'supplemental_heating')
    heating_coil
  end
end