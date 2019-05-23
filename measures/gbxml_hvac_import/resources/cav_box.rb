class CAVBox < ZoneHVACEquipment
  attr_accessor :air_terminal, :air_terminal_type, :heating_coil, :heating_coil_type, :heating_loop_ref, :air_system,
                :air_system_ref, :heating_loop

  COOLING_DESIGN_TEMP = 12.77778
  HEATING_DESIGN_TEMP = 40

  def initialize
    super()
    self.name = "CAV Box"
  end

  def self.create_from_xml(model_manager, xml)
    cav_box = new
    cav_box.model_manager = model_manager
    cav_box.model = model_manager.model

    name = xml.elements['Name']
    cav_box.set_name(xml.elements['Name'].text) unless name.nil?
    cav_box.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    cav_box.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    air_system_ref = xml.elements['AirSystemId']
    unless air_system_ref.nil?
      cav_box.air_system_ref = xml.elements['AirSystemId'].attributes['airSystemIdRef']
    end

    unless xml.attributes['heatingCoilType'].nil? or xml.attributes['heatingCoilType'] == "None"
      cav_box.heating_coil_type = xml.attributes['heatingCoilType']

      if cav_box.heating_coil_type == 'HotWater'
        hydronic_loop_id = xml.elements['HydronicLoopId']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            cav_box.heating_loop_ref = hydronic_loop_id_ref
          end
        end
      end

      if ['HotWater', 'Furnace', 'ElectricResistance'].include? cav_box.heating_coil_type
        cav_box.air_terminal_type = 'Reheat'
      else
        cav_box.air_terminal_type = 'NoReheat'
      end
    end

    cav_box
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
    self.heating_coil = add_heating_coil
    self.air_terminal = add_air_terminal
  end

  def connect
    self.heating_loop.plant_loop.addDemandBranchForComponent(self.heating_coil) if self.heating_loop
    self.air_system.air_loop_hvac.addBranchForZone(self.zone.thermal_zone, self.air_terminal) if self.zone.thermal_zone
  end

  def post_build
    self.zone.thermal_zone.setCoolingPriority(self.air_terminal, 0) unless self.air_system.is_doas
    self.zone.thermal_zone.setHeatingPriority(self.air_terminal, 0) unless self.air_system.is_doas
  end

  private

  def add_air_terminal
    if self.air_terminal_type == 'Reheat'
      cav_box = OpenStudio::Model::AirTerminalSingleDuctConstantVolumeReheat.new(self.model, self.model.alwaysOnDiscreteSchedule, self.heating_coil)
      cav_box.setMaximumReheatAirTemperature(self.design_htg_temp)
    else
      cav_box = OpenStudio::Model::AirTerminalSingleDuctUncontrolled.new(self.model, self.model.alwaysOnDiscreteSchedule)
    end

    cav_box.setName(self.name) unless self.name.nil?
    cav_box.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    cav_box.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    cav_box
  end

  def add_heating_coil
    heating_coil = nil

    if self.heating_coil_type == "ElectricResistance"
      heating_coil = OpenStudio::Model::CoilHeatingElectric.new(self.model)
    elsif self.heating_coil_type == "Furnace"
      heating_coil = OpenStudio::Model::CoilHeatingGas.new(self.model)
    elsif self.heating_coil_type == "HotWater"
      heating_coil = OpenStudio::Model::CoilHeatingWater.new(self.model)
      heating_coil.setRatedInletWaterTemperature(self.heating_loop.design_loop_exit_temp)
      heating_coil.setRatedOutletWaterTemperature(self.heating_loop.design_loop_return_temp)
      heating_coil.setRatedInletAirTemperature(self.air_system.design_htg_temp)
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