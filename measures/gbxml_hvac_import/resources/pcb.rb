class PCB < ZoneHVACEquipment
  attr_accessor :pcb, :supply_fan, :cooling_coil, :cooling_loop_ref, :cooling_loop, :heating_coil, :heating_loop_ref,
                :heating_loop

  COOLING_DESIGN_TEMP = 17
  HEATING_DESIGN_TEMP = 29.44444

  def initialize
    self.name = "PCB"
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

  def design_htg_temp
    HEATING_DESIGN_TEMP
  end

  def design_clg_temp
    COOLING_DESIGN_TEMP
  end

  def resolve_references
    if self.heating_loop_ref
      hw_loop = self.model_manager.hw_loops[self.heating_loop_ref]
      self.heating_loop = hw_loop if hw_loop
    end

    if self.cooling_loop_ref
      chw_loop = self.model_manager.chw_loops[self.cooling_loop_ref]
      self.cooling_loop = chw_loop if chw_loop
    end
  end

  def resolve_read_relationships
    self.zone.design_clg_temp = design_clg_temp
    self.zone.design_htg_temp = design_htg_temp
  end

  def build
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.supply_fan = add_supply_fan
    self.cooling_coil = add_cooling_coil
    self.pcb = add_pcb
  end

  def connect
    self.heating_loop.plant_loop.addDemandBranchForComponent(self.heating_coil) if self.heating_loop
    self.cooling_loop.plant_loop.addDemandBranchForComponent(self.cooling_coil) if self.cooling_loop

    self.pcb.addToThermalZone(self.zone.thermal_zone) if self.zone.thermal_zone
  end

  def post_build
    self.zone.thermal_zone.setCoolingPriority(self.pcb, 0)
    self.zone.thermal_zone.setHeatingPriority(self.pcb, 0)
  end

  private

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
    fan.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    fan.setPressureRise(0)
    fan
  end

  def add_heating_coil
    heating_coil = OpenStudio::Model::CoilHeatingWater.new(self.model)
    heating_coil.setName("#{self.name} Heating Coil")
    heating_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    heating_coil.additionalProperties.setFeature('coil_type', 'primary_heating')
    heating_coil.setRatedInletWaterTemperature(self.heating_loop.design_loop_exit_temp)
    heating_coil.setRatedOutletWaterTemperature(self.heating_loop.design_loop_return_temp)
    # heating_coil.setRatedInletAirTemperature(self.heating_coil_rated_inlet_air_temperature)
    heating_coil.setRatedOutletAirTemperature(self.design_htg_temp)
    heating_coil
  end

  def add_cooling_coil
    cooling_coil = OpenStudio::Model::CoilCoolingWater.new(self.model)
    cooling_coil.setName("#{self.name} Cooling Coil")
    cooling_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    cooling_coil.additionalProperties.setFeature('coil_type', 'primary_cooling')
    cooling_coil
  end
end