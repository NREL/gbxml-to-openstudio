class PTHP < HVACObject
  attr_accessor :pthp, :supply_fan, :cooling_coil, :heating_coil, :supplemental_heating_coil

  def initialize
    self.name = "PTHP"
  end

  def connect_thermal_zone(thermal_zone)
    self.pthp.addToThermalZone(thermal_zone)
  end

  def add_pthp
    pthp = OpenStudio::Model::ZoneHVACPackagedTerminalHeatPump.new(self.model, self.model.alwaysOnDiscreteSchedule, self.supply_fan, self.heating_coil, self.cooling_coil, self.supplemental_heating_coil)
    pthp.setName(self.name) unless self.name.nil?
    pthp.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    pthp.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    pthp
  end

  def add_supply_fan
    fan = OpenStudio::Model::FanOnOff.new(self.model)
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

  def resolve_dependencies

  end

  def build
    # Object dependency resolution needs to happen before the object is built
    self.model_manager = model_manager
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.supply_fan = add_supply_fan
    self.cooling_coil = add_cooling_coil
    self.supplemental_heating_coil = add_supplemental_heating_coil
    self.pthp = add_pthp
    resolve_dependencies

    self.built = true
    self.pthp
  end

  def self.create_from_xml(model_manager, xml)
    equipment = new
    equipment.model_manager = model_manager

    name = xml.elements['Name']
    equipment.set_name(xml.elements['Name'].text) unless name.nil?
    equipment.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    equipment.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    equipment
  end
end