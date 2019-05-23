class PFPB < ZoneHVACEquipment
  attr_accessor :air_terminal, :air_terminal_type, :supply_fan, :heating_coil, :heating_coil_type, :heating_loop_ref,
                :air_system, :air_system_ref, :heating_loop

  HEATING_DESIGN_TEMP = 40

  def initialize
    super()
    self.name = "PFPB"
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

    unless xml.attributes['heatingCoilType'].nil? or xml.attributes['heatingCoilType'] == "None"
      equipment.heating_coil_type = xml.attributes['heatingCoilType']

      if equipment.heating_coil_type == 'HotWater'
        hydronic_loop_id = xml.elements['HydronicLoopId']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            equipment.heating_loop_ref = hydronic_loop_id_ref
          end
        end
      end

      if ['HotWater', 'Furnace', 'ElectricResistance'].include? equipment.heating_coil_type
        equipment.air_terminal_type = 'Reheat'
      else
        equipment.air_terminal_type = 'NoReheat'
      end
    end

    equipment
  end

  def design_htg_temp
    HEATING_DESIGN_TEMP
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
  end

  def resolve_read_relationships
    if self.air_system.is_doas
      self.zone.account_for_doas = true
      self.zone.doas_control_strategy = "ColdSupplyAir"
      self.zone.doas_low_setpoint = self.air_system.design_clg_temp
      self.zone.doas_high_setpoint = self.air_system.design_htg_temp
    else
      self.zone.design_clg_temp = self.air_system.design_clg_temp
      self.zone.design_htg_temp = self.design_htg_temp
    end
  end

  def build
    self.model = model_manager.model
    self.supply_fan = add_supply_fan
    self.heating_coil = add_heating_coil
    self.air_terminal = add_air_terminal
  end

  def connect
    self.heating_loop.plant_loop.addDemandBranchForComponent(self.heating_coil) if self.heating_loop
    self.air_system.air_loop_hvac.addBranchForZone(self.zone.thermal_zone, self.air_terminal.to_StraightComponent) if self.zone.thermal_zone
  end

  def post_build
    self.zone.thermal_zone.setCoolingPriority(self.air_terminal, 0) unless self.air_system.is_doas
    self.zone.thermal_zone.setHeatingPriority(self.air_terminal, 0) unless self.air_system.is_doas
  end

  private

  def add_air_terminal
    if self.air_terminal_type == 'Reheat'
      pfpb = OpenStudio::Model::AirTerminalSingleDuctParallelPIUReheat.new(self.model, self.model.alwaysOnDiscreteSchedule, self.supply_fan, self.heating_coil)
    else
      pfpb = OpenStudio::Model::AirTerminalSingleDuctParallelPIUReheat.new(self.model, self.model.alwaysOnDiscreteSchedule, self.supply_fan, self.heating_coil)
    end

    pfpb.setName(self.name) unless self.name.nil?
    pfpb.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    pfpb.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    pfpb
  end

  def add_supply_fan
    fan = OpenStudio::Model::FanConstantVolume.new(self.model)
    fan.setName("#{self.name} + Fan")
    fan.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    fan
  end

  def add_heating_coil
    heating_coil = OpenStudio::Model::CoilHeatingElectric.new(self.model)
    heating_coil.setNominalCapacity(0)

    if self.heating_coil_type == "ElectricResistance"
      heating_coil = OpenStudio::Model::CoilHeatingElectric.new(self.model)
    elsif self.heating_coil_type == "Furnace"
      heating_coil = OpenStudio::Model::CoilHeatingGas.new(self.model)
    elsif self.heating_coil_type == "HotWater"
      heating_coil = OpenStudio::Model::CoilHeatingWater.new(self.model)
      heating_coil.setRatedInletWaterTemperature(self.heating_loop.design_loop_exit_temp)
      heating_coil.setRatedOutletWaterTemperature(self.heating_loop.design_loop_return_temp)
      # heating_coil.setRatedInletAirTemperature(self.heating_coil_rated_inlet_air_temperature)
      heating_coil.setRatedOutletAirTemperature(self.design_htg_temp)
    end

    if heating_coil
      heating_coil.setName(self.name + " Heating Coil") unless self.name.nil?
      heating_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
      heating_coil.additionalProperties.setFeature('coil_type', 'primary_heating')
    end

    heating_coil
  end
end