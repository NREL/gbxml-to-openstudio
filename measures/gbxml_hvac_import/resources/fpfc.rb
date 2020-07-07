class FPFC < ZoneHVACEquipment
  attr_accessor :fpfc, :supply_fan, :cooling_coil, :cooling_loop_ref, :cooling_loop, :heating_coil, :heating_loop_ref,
                :heating_loop, :heating_inlet_water_temp, :heating_outlet_water_temp, :draw_ventilation

  COOLING_DESIGN_TEMP = 12.777778
  HEATING_DESIGN_TEMP = 40

  def initialize
    super()
    self.name = "FPFC"
  end

  def self.create_from_xml(model_manager, xml)
    equipment = new
    equipment.model_manager = model_manager

    name = xml.elements['Name']
    equipment.set_name(xml.elements['Name'].text) unless name.nil?
    equipment.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    equipment.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?
    equipment.draw_ventilation = xml.attributes['DrawVentilation'] == "True" ? true : false

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
    unless self.cooling_loop.nil?
      cooling_loop.is_low_temperature = true
    end

    self.zone.design_clg_temp = design_clg_temp
    self.zone.design_htg_temp = design_htg_temp

    if self.heating_loop
      self.heating_inlet_water_temp = self.heating_loop.design_loop_exit_temp
      self.heating_outlet_water_temp = self.heating_loop.design_loop_return_temp
    end
  end

  def build
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.supply_fan = add_supply_fan
    self.cooling_coil = add_cooling_coil
    self.fpfc = add_fpfc
  end

  def connect
    self.heating_loop.plant_loop.addDemandBranchForComponent(self.heating_coil) if self.heating_loop
    self.cooling_loop.plant_loop.addDemandBranchForComponent(self.cooling_coil) if self.cooling_loop

    self.fpfc.addToThermalZone(self.zone.thermal_zone) if self.zone.thermal_zone
  end

  def post_build
    self.zone.thermal_zone.setCoolingPriority(self.fpfc, 0)
    self.zone.thermal_zone.setHeatingPriority(self.fpfc, 0)
  end

  private

  def add_fpfc
    fpfc = OpenStudio::Model::ZoneHVACFourPipeFanCoil.new(self.model, self.model.alwaysOnDiscreteSchedule, self.supply_fan, self.cooling_coil, self.heating_coil)
    fpfc.setName(self.name) unless self.name.nil?
    fpfc.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    fpfc.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    fpfc.setMaximumOutdoorAirFlowRate(0) unless self.draw_ventilation

    fpfc
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
    heating_coil = OpenStudio::Model::CoilHeatingWater.new(self.model)
    heating_coil.setName("#{self.name} + Heating Coil")
    heating_coil.setRatedInletWaterTemperature(self.heating_inlet_water_temp) if self.heating_inlet_water_temp
    heating_coil.setRatedOutletWaterTemperature(self.heating_outlet_water_temp) if self.heating_outlet_water_temp
    heating_coil.setRatedOutletAirTemperature(self.design_htg_temp)
    heating_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    heating_coil.additionalProperties.setFeature('coil_type', 'primary_heating')
    heating_coil
  end

  def add_cooling_coil
    cooling_coil = OpenStudio::Model::CoilCoolingWater.new(self.model)
    cooling_coil.setName("#{self.name} + Cooling Coil")
    cooling_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    cooling_coil.additionalProperties.setFeature('coil_type', 'primary_cooling')
    cooling_coil
  end
end