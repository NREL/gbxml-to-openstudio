require_relative '../hvac_object/hvac_object'

class VRFFanCoilUnit < HVACObject
  attr_accessor :fcu, :supply_fan, :cooling_coil, :heating_coil, :vrf_loop_ref

  def initialize
    self.name = "VRF Fan Coil Unit"
  end

  def connect_thermal_zone(thermal_zone)
    self.fcu.addToThermalZone(thermal_zone)
  end

  def add_vrf_fcu
    fcu = OpenStudio::Model::ZoneHVACTerminalUnitVariableRefrigerantFlow.new(self.model, self.cooling_coil, self.heating_coil, self.supply_fan)
    fcu.setName(self.name) unless self.name.nil?
    fcu.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    fcu.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    fcu
  end

  def add_supply_fan
    fan = OpenStudio::Model::FanOnOff.new(self.model)
    fan.setName("#{self.name} Fan")
    fan
  end

  def add_heating_coil
    heating_coil = OpenStudio::Model::CoilHeatingDXVariableRefrigerantFlow.new(self.model)
    heating_coil.setName("#{self.name} Heating Coil")
    heating_coil
  end

  def add_cooling_coil
    cooling_coil = OpenStudio::Model::CoilCoolingDXVariableRefrigerantFlow.new(self.model)
    cooling_coil.setName("#{self.name} Cooling Coil")
    cooling_coil
  end

  def resolve_dependencies
    unless self.vrf_loop_ref.nil?
      vrf_loop = self.model_manager.vrf_loops[self.vrf_loop_ref]
      vrf_loop.condenser.addTerminal(self.fcu)
    end
  end

  def build
    # Object dependency resolution needs to happen before the object is built
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.supply_fan = add_supply_fan
    self.cooling_coil = add_cooling_coil
    self.fcu = add_vrf_fcu

    # VRF FCU has no setSupplyAirFan method so the add_vrf_fcu needs to create a fully populated FCU
    # self.fcu.setHeatingCoil(self.heating_coil) unless self.heating_coil.nil?
    # self.fcu.setCoolingCoil(self.cooling_coil) unless self.cooling_coil.nil?

    resolve_dependencies

    self.built = true
    self.fcu
  end

  def self.create_from_xml(model_manager, xml)
    equipment = new
    equipment.model_manager = model_manager

    name = xml.elements['Name']
    equipment.set_name(xml.elements['Name'].text) unless name.nil?
    equipment.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    equipment.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    hydronic_loop_id = xml.elements['HydronicLoopId[@hydronicLoopType="VRFLoop"]']
    unless hydronic_loop_id.nil?
      hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
      unless hydronic_loop_id_ref.nil?
        equipment.vrf_loop_ref = hydronic_loop_id_ref
      end
    end

    equipment
  end
end