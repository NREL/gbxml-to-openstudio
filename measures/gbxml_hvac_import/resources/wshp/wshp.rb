require_relative '../hvac_object/hvac_object'

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
    OpenStudio::Model::FanOnOff.new(self.model)
  end

  def add_heating_coil
    OpenStudio::Model::CoilHeatingWaterToAirHeatPumpEquationFit.new(self.model)
  end

  def add_cooling_coil
    OpenStudio::Model::CoilCoolingWaterToAirHeatPumpEquationFit.new(self.model)
  end

  def add_supplemental_heating_coil
    OpenStudio::Model::CoilHeatingElectric.new(self.model)
  end

  def resolve_dependencies
    unless self.condenser_loop_ref.nil?
      condenser_loop = self.model_manager.cw_loops[self.heating_loop_ref]
      condenser_loop.plant_loop.addDemandBranchForComponent(self.heating_coil)
      condenser_loop.plant_loop.addDemandBranchForComponent(self.cooling_coil)
    end
  end

  def build(model_manager)
    # Object dependency resolution needs to happen before the object is built
    self.model_manager = model_manager
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.supply_fan = add_supply_fan
    self.cooling_coil = add_cooling_coil
    self.supplemental_heating_coil = add_supplemental_heating_coil
    self.wshp = add_wshp
    resolve_dependencies

    self.built = true
    self.pthp
  end

  def self.create_from_xml(xml)
    equipment = new

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