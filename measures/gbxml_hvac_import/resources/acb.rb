class ACB < ZoneHVACEquipment
  attr_accessor :acb, :supply_fan, :cooling_coil, :cooling_loop_ref, :cooling_loop, :heating_coil, :heating_loop_ref,
                :heating_loop, :air_system_ref, :air_system

  COOLING_DESIGN_TEMP = 17
  HEATING_DESIGN_TEMP = 29.44444

  def initialize
    super()
    self.name = "ACB"
  end

  def self.create_from_xml(model_manager, xml)
    equipment = new
    equipment.model_manager = model_manager

    name = xml.elements['Name']
    equipment.set_name(xml.elements['Name'].text) unless name.nil?
    equipment.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    equipment.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    air_system_ref = xml.elements['AirSystemId']
    unless air_system_ref.nil?
      equipment.air_system_ref = xml.elements['AirSystemId'].attributes['airSystemIdRef']
    end

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
    if self.air_system_ref
      air_system = self.model_manager.air_systems[self.air_system_ref]
      air_system.add_zone_hvac_equipment(self) if air_system
      self.air_system = air_system if air_system
    end

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
    if self.air_system.is_doas
      self.zone.account_for_doas = true
      self.zone.doas_control_strategy = "ColdSupplyAir"
      self.zone.doas_low_setpoint = self.air_system.design_clg_temp
      self.zone.doas_high_setpoint = self.air_system.design_htg_temp
    else
      self.zone.design_clg_temp = self.design_clg_temp
      self.zone.design_htg_temp = self.design_htg_temp
    end
  end

  def build
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.cooling_coil = add_cooling_coil
    self.acb = add_acb

    self.acb.setCoolingCoil(self.cooling_coil) unless self.cooling_coil.nil?
  end

  def connect
    self.heating_loop.plant_loop.addDemandBranchForComponent(self.heating_coil) if self.heating_loop
    self.cooling_loop.plant_loop.addDemandBranchForComponent(self.cooling_coil) if self.cooling_loop

    self.air_system.air_loop_hvac.addBranchForZone(self.zone.thermal_zone, self.acb) if self.zone.thermal_zone
  end

  def post_build
    self.zone.thermal_zone.setCoolingPriority(self.acb, 0) unless self.air_system.is_doas
    self.zone.thermal_zone.setHeatingPriority(self.acb, 0) unless self.air_system.is_doas
  end

  private

  def add_acb
    acb = OpenStudio::Model::AirTerminalSingleDuctConstantVolumeFourPipeInduction.new(self.model, self.heating_coil)
    acb.setName(self.name) unless self.name.nil?
    acb.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    acb.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    acb
  end

  def add_heating_coil
    heating_coil = OpenStudio::Model::CoilHeatingWater.new(self.model)
    heating_coil.setName(self.name + " Heating Coil") unless self.name.nil?
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
    cooling_coil.setName(self.name + " Cooling Coil") unless self.name.nil?
    cooling_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    cooling_coil.additionalProperties.setFeature('coil_type', 'primary_cooling')
    cooling_coil
  end
end