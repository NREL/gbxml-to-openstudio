class PCB < HVACObject
  attr_accessor :pcb, :supply_fan, :cooling_coil, :cooling_loop_ref, :heating_coil, :heating_loop_ref

  def initialize
    self.name = "PCB"
  end

  def connect_thermal_zone(thermal_zone)
    self.pcb.addToThermalZone(thermal_zone)
  end

  def add_pcb
    pcb = OpenStudio::Model::ZoneHVACFourPipeFanCoil.new(self.model, self.model.alwaysOnDiscreteSchedule, self.supply_fan, self.cooling_coil, self.heating_coil)
    pcb.setName(self.name) unless self.name.nil?
    pcb.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    pcb.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    pcb
  end

  def add_supply_fan
    fan = OpenStudio::Model::FanOnOff.new(self.model)
    fan.setName("#{self.name} Fan")
    fan
  end

  def add_heating_coil
    heating_coil = OpenStudio::Model::CoilHeatingWater.new(self.model)
    heating_coil.setName("#{self.name} Heating Coil")
    heating_coil
  end

  def add_cooling_coil
    cooling_coil = OpenStudio::Model::CoilCoolingWater.new(self.model)
    cooling_coil.setName("#{self.name} Cooling Coil")
    cooling_coil
  end

  def resolve_dependencies
    unless self.heating_loop_ref.nil?
      heating_loop = self.model_manager.hw_loops[self.heating_loop_ref]
      heating_loop.plant_loop.addDemandBranchForComponent(self.heating_coil)
    end

    unless self.cooling_loop_ref.nil?
      cooling_loop = self.model_manager.chw_loops[self.cooling_loop_ref]
      cooling_loop.plant_loop.addDemandBranchForComponent(self.cooling_coil)
    end
  end

  def build
    # Object dependency resolution needs to happen before the object is built
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.supply_fan = add_supply_fan
    self.cooling_coil = add_cooling_coil
    self.pcb = add_pcb

    self.pcb.setHeatingCoil(self.heating_coil) unless self.heating_coil.nil?
    self.pcb.setCoolingCoil(self.cooling_coil) unless self.cooling_coil.nil?

    resolve_dependencies

    self.built = true
    self.pcb
  end

  def self.create_from_xml(model_manager, xml)
    equipment = new
    equipment.model_manager = model_manager

    name = xml.elements['Name']
    equipment.set_name(xml.elements['Name'].text) unless name.nil?
    equipment.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    equipment.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    hydronic_loop_id = xml.elements['HydronicLoopId[@hydronicLoopType="HotWater"]']
    unless hydronic_loop_id.nil?
      hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
      unless hydronic_loop_id_ref.nil?
        equipment.heating_loop_ref = hydronic_loop_id_ref
      end
    end

    hydronic_loop_id = xml.elements['HydronicLoopId[@hydronicLoopType="PrimaryChilledWater"]']
    unless hydronic_loop_id.nil?
      hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
      unless hydronic_loop_id_ref.nil?
        equipment.cooling_loop_ref = hydronic_loop_id_ref
      end
    end

    equipment
  end
end