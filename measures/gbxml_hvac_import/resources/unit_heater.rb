class UnitHeater < ZoneHVACEquipment
  attr_accessor :unit_heater, :supply_fan, :heating_coil, :heating_coil_type, :heating_loop_ref, :heating_loop,
                :heating_inlet_water_temp, :heating_outlet_water_temp

  HEATING_DESIGN_TEMP = 40

  def initialize
    super()
    self.name = "Unit Heater"
  end

  def self.create_from_xml(model_manager, xml)
    equipment = new
    equipment.model_manager = model_manager

    name = xml.elements['Name']
    equipment.set_name(xml.elements['Name'].text) unless name.nil?
    equipment.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    equipment.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

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
    end

    equipment
  end

  def design_htg_temp
    HEATING_DESIGN_TEMP
  end

  def connect_thermal_zone(thermal_zone)
    self.unit_heater.addToThermalZone(thermal_zone)
  end

  def resolve_references
    if self.heating_loop_ref
      hw_loop = self.model_manager.hw_loops[self.heating_loop_ref]
      self.heating_loop = hw_loop if hw_loop
    end
  end

  def resolve_read_relationships
    self.zone.design_htg_temp = design_htg_temp

    if self.heating_loop
      self.heating_inlet_water_temp = self.heating_loop.design_loop_exit_temp
      self.heating_outlet_water_temp = self.heating_loop.design_loop_return_temp
    end
  end

  def build
    self.model_manager = model_manager
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.supply_fan = add_supply_fan
    self.unit_heater = add_unit_heater
  end

  def connect
    self.heating_loop.plant_loop.addDemandBranchForComponent(self.heating_coil) if self.heating_loop
    self.unit_heater.addToThermalZone(self.zone.thermal_zone) if self.zone.thermal_zone
  end

  def post_build
    self.zone.thermal_zone.setHeatingPriority(self.unit_heater, 0)
  end

  private

  def add_unit_heater
    unit_heater = OpenStudio::Model::ZoneHVACUnitHeater.new(self.model, self.model.alwaysOnDiscreteSchedule, self.supply_fan, self.heating_coil)
    unit_heater.setName(self.name) unless self.name.nil?
    unit_heater.autosizeMaximumHotWaterFlowRate
    unit_heater.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    unit_heater.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    unit_heater
  end

  def add_supply_fan
    fan = OpenStudio::Model::FanConstantVolume.new(self.model)
    fan.setName("#{self.name} + Fan")
    fan.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
    fan
  end

  def add_heating_coil

    if self.heating_coil_type == "ElectricResistance"
      heating_coil = OpenStudio::Model::CoilHeatingElectric.new(self.model)
    elsif self.heating_coil_type == "Furnace"
      heating_coil = OpenStudio::Model::CoilHeatingGas.new(self.model)
    elsif self.heating_coil_type == "HotWater"
      heating_coil = OpenStudio::Model::CoilHeatingWater.new(self.model)
      heating_coil.setRatedInletWaterTemperature(self.heating_inlet_water_temp) if self.heating_inlet_water_temp
      heating_coil.setRatedOutletWaterTemperature(self.heating_outlet_water_temp) if self.heating_outlet_water_temp
      heating_coil.setRatedOutletAirTemperature(self.design_htg_temp)
    else
      heating_coil = OpenStudio::Model::CoilHeatingElectric.new(self.model)
      heating_coil.setNominalCapacity(0)
    end

    if heating_coil
      heating_coil.setName(self.name + " Heating Coil") unless self.name.nil?
      heating_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.cad_object_id.nil?
      heating_coil.additionalProperties.setFeature('coil_type', 'primary_heating')
    end

    heating_coil
  end
end