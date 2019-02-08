class WSHP < HVACObject
  attr_accessor :wshp, :supply_fan, :cooling_coil, :heating_coil, :condenser_loop_ref,:supplemental_heating_coil

  def initialize
    self.name = "WSHP"
  end

  def connect_thermal_zone(thermal_zone)
    self.wshp.addToThermalZone(thermal_zone)
  end

  def add_wshp
    wshp = OpenStudio::Model::ZoneHVACWaterToAirHeatPump.new(self.model, self.model.alwaysOnDiscreteSchedule, self.supply_fan, self.heating_coil, self.cooling_coil, self.supplemental_heating_coil)
    wshp.setName(self.name) unless self.name.nil?
    wshp.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    wshp.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    wshp
  end

  def add_supply_fan
    fan = OpenStudio::Model::FanOnOff.new(self.model)
    fan.setName("#{self.name} Fan")
    fan
  end

  def add_heating_coil
    heating_coil = OpenStudio::Model::CoilHeatingWaterToAirHeatPumpEquationFit.new(self.model)
    heating_coil.setName("#{self.name} Heating Coil")
    heating_coil
  end

  def add_cooling_coil
    cooling_coil = OpenStudio::Model::CoilCoolingWaterToAirHeatPumpEquationFit.new(self.model)
    cooling_coil.setName("#{self.name} Cooling Coil")
    cooling_coil
  end

  def add_supplemental_heating_coil
    heating_coil = OpenStudio::Model::CoilHeatingElectric.new(self.model)
    heating_coil.setName("#{self.name} Supplemental Heating Coil")
    heating_coil
  end

  def resolve_dependencies
    unless self.condenser_loop_ref.nil?
      condenser_loop = self.model_manager.cw_loops[self.condenser_loop_ref]
      condenser_loop.plant_loop.addDemandBranchForComponent(self.heating_coil)
      condenser_loop.plant_loop.addDemandBranchForComponent(self.cooling_coil)
    end
  end

  def resolve_read_relationships
    cw_loop = model_manager.cw_loops[self.condenser_loop_ref]

    if cw_loop
      cw_loop.set_has_heating(true)
    end

  end

  def build
    # Object dependency resolution needs to happen before the object is built
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.supply_fan = add_supply_fan
    self.cooling_coil = add_cooling_coil
    self.supplemental_heating_coil = add_supplemental_heating_coil
    self.wshp = add_wshp
    resolve_dependencies

    self.built = true
    self.wshp
  end

  def self.create_from_xml(model_manager, xml)
    equipment = new
    equipment.model_manager = model_manager

    name = xml.elements['Name']
    equipment.set_name(xml.elements['Name'].text) unless name.nil?
    equipment.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    equipment.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    hydronic_loop_id = xml.elements['HydronicLoopId']
    unless hydronic_loop_id.nil?
      hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
      unless hydronic_loop_id_ref.nil?
        equipment.condenser_loop_ref = hydronic_loop_id_ref
      end
    end

    equipment
  end
end