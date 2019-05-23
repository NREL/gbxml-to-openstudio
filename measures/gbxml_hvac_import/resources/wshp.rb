class WSHP < ZoneHVACEquipment
  attr_accessor :wshp, :supply_fan, :cooling_coil, :heating_coil, :condenser_loop_ref, :condenser_loop,
                :supplemental_heating_coil, :draw_ventilation

  COOLING_DESIGN_TEMP = 12.777778
  HEATING_DESIGN_TEMP = 40

  def initialize
    super()
    self.name = "WSHP"
  end

  def self.create_from_xml(model_manager, xml)
    equipment = new
    equipment.model_manager = model_manager

    name = xml.elements['Name']
    equipment.set_name(xml.elements['Name'].text) unless name.nil?
    equipment.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    equipment.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?
    equipment.draw_ventilation = xml.attributes['DrawVentilation'] == "True" ? true : false

    hydronic_loop_id = xml.elements['HydronicLoopId']
    unless hydronic_loop_id.nil?
      hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
      unless hydronic_loop_id_ref.nil?
        equipment.condenser_loop_ref = hydronic_loop_id_ref
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
    if self.condenser_loop_ref
      cw_loop = self.model_manager.cw_loops[self.condenser_loop_ref]
      self.condenser_loop = cw_loop if cw_loop
    end
  end

  def resolve_read_relationships
    cw_loop = model_manager.cw_loops[self.condenser_loop_ref]

    if cw_loop
      cw_loop.set_has_heating(true)
    end

    self.zone.design_clg_temp = design_clg_temp
    self.zone.design_htg_temp = design_htg_temp
  end

  def resolve_dependencies
    unless self.condenser_loop_ref.nil?
      condenser_loop = self.model_manager.cw_loops[self.condenser_loop_ref]
      self.condenser_loop = condenser_loop if condenser_loop
    end
  end

  def build
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.supply_fan = add_supply_fan
    self.cooling_coil = add_cooling_coil
    self.supplemental_heating_coil = add_supplemental_heating_coil
    self.wshp = add_wshp
  end

  def connect
    self.condenser_loop.plant_loop.addDemandBranchForComponent(self.heating_coil) if self.condenser_loop
    self.condenser_loop.plant_loop.addDemandBranchForComponent(self.cooling_coil) if self.condenser_loop

    self.wshp.addToThermalZone(self.zone.thermal_zone) if self.zone.thermal_zone
  end

  def post_build
    self.zone.thermal_zone.setCoolingPriority(self.wshp, 0)
    self.zone.thermal_zone.setHeatingPriority(self.wshp, 0)
  end

  private

  def add_wshp
    wshp = OpenStudio::Model::ZoneHVACWaterToAirHeatPump.new(self.model, self.model.alwaysOnDiscreteSchedule, self.supply_fan, self.heating_coil, self.cooling_coil, self.supplemental_heating_coil)
    wshp.setName(self.name) unless self.name.nil?
    wshp.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    wshp.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    wshp.setOutdoorAirFlowRateDuringCoolingOperation(0) unless self.draw_ventilation
    wshp.setOutdoorAirFlowRateDuringHeatingOperation(0) unless self.draw_ventilation
    wshp.setOutdoorAirFlowRateWhenNoCoolingorHeatingisNeeded(0) unless self.draw_ventilation

    wshp
  end

  def add_supply_fan
    fan = OpenStudio::Model::FanOnOff.new(self.model)

    fan.setName("#{self.name} + Fan")
    fan.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    fan
  end

  def add_heating_coil
    heating_coil = OpenStudio::Model::CoilHeatingWaterToAirHeatPumpEquationFit.new(self.model)
    heating_coil.setName("#{self.name} Heating Coil")
    heating_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    heating_coil.additionalProperties.setFeature('coil_type', 'primary_heating')
    heating_coil
  end

  def add_cooling_coil
    cooling_coil = OpenStudio::Model::CoilCoolingWaterToAirHeatPumpEquationFit.new(self.model)
    cooling_coil.setName("#{self.name} Cooling Coil")
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