class VRFFanCoilUnit < ZoneHVACEquipment
  attr_accessor :fcu, :supply_fan, :cooling_coil, :heating_coil, :vrf_loop_ref, :vrf_loop, :draw_ventilation

  COOLING_DESIGN_TEMP = 12.777778
  HEATING_DESIGN_TEMP = 40

  def initialize
    super()
    self.name = "VRF Fan Coil Unit"
  end

  def self.create_from_xml(model_manager, xml)
    equipment = new
    equipment.model_manager = model_manager

    name = xml.elements['Name']
    equipment.set_name(xml.elements['Name'].text) unless name.nil?
    equipment.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    equipment.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?
    equipment.draw_ventilation = xml.attributes['DrawVentilation'] == "True" ? true : false

    hydronic_loop_id = xml.elements['HydronicLoopId[@hydronicLoopType="VRFLoop"]']
    unless hydronic_loop_id.nil?
      hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
      unless hydronic_loop_id_ref.nil?
        equipment.vrf_loop_ref = hydronic_loop_id_ref
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
    if self.vrf_loop_ref
      vrf_loop = self.model_manager.vrf_loops[self.vrf_loop_ref]
      self.vrf_loop = vrf_loop if vrf_loop
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
    self.fcu = add_vrf_fcu
  end

  def connect
    self.vrf_loop.condenser.addTerminal(self.fcu) if self.vrf_loop
    self.fcu.addToThermalZone(self.zone.thermal_zone) if self.zone.thermal_zone
  end

  def post_build
    self.zone.thermal_zone.setCoolingPriority(self.fcu, 0)
    self.zone.thermal_zone.setHeatingPriority(self.fcu, 0)
  end

  private

  def add_vrf_fcu
    fcu = OpenStudio::Model::ZoneHVACTerminalUnitVariableRefrigerantFlow.new(self.model, self.cooling_coil, self.heating_coil, self.supply_fan)
    fcu.setName(self.name) unless self.name.nil?
    fcu.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    fcu.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    fcu.setOutdoorAirFlowRateWhenNoCoolingorHeatingisNeeded(0) unless self.draw_ventilation
    fcu.setOutdoorAirFlowRateDuringHeatingOperation(0) unless self.draw_ventilation
    fcu.setOutdoorAirFlowRateDuringCoolingOperation(0) unless self.draw_ventilation

    fcu
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
    heating_coil = OpenStudio::Model::CoilHeatingDXVariableRefrigerantFlow.new(self.model)
    heating_coil.setName("#{self.name} Heating Coil")
    heating_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    heating_coil.additionalProperties.setFeature('coil_type', 'primary_heating')
    heating_coil
  end

  def add_cooling_coil
    cooling_coil = OpenStudio::Model::CoilCoolingDXVariableRefrigerantFlow.new(self.model)
    cooling_coil.setName("#{self.name} Cooling Coil")
    cooling_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    cooling_coil.additionalProperties.setFeature('coil_type', 'primary_cooling')
    cooling_coil
  end
end