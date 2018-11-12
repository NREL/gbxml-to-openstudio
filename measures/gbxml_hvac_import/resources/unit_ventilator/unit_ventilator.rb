class UnitVentilator < HVACObject
  attr_accessor :unit_ventilator, :supply_fan, :cooling_coil, :cooling_coil_type, :cooling_loop_ref, :heating_coil, :heating_coil_type, :heating_loop_ref

  def initialize
    self.name = "Unit Ventilator"
  end

  def connect_thermal_zone(thermal_zone)
    self.unit_ventilator.addToThermalZone(thermal_zone)
  end

  def add_unit_ventilator
    unit_ventilator = OpenStudio::Model::ZoneHVACUnitVentilator.new(self.model, self.supply_fan)
    unit_ventilator.setName(self.name) unless self.name.nil?
    unit_ventilator.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    unit_ventilator.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    unit_ventilator
  end

  def add_supply_fan
    OpenStudio::Model::FanConstantVolume.new(self.model)
  end

  def add_heating_coil
    if self.heating_coil_type == "ElectricResistance"
      heating_coil = OpenStudio::Model::CoilHeatingElectric.new(self.model)
    elsif self.heating_coil_type == "Furnace"
      heating_coil = OpenStudio::Model::CoilHeatingGas.new(self.model)
    elsif self.heating_coil_type == "HotWater"
      heating_coil = OpenStudio::Model::CoilHeatingWater.new(self.model)
    end

    heating_coil
  end

  def add_cooling_coil
    cooling_coil = nil

    if self.cooling_coil_type == "ChilledWater"
      cooling_coil = OpenStudio::Model::CoilCoolingWater.new(self.model)
    end

    cooling_coil
  end

  def resolve_read_relationships
    unless self.cooling_loop_ref.nil?
      cooling_loop = self.model_manager.chw_loops[self.cooling_loop_ref]
      cooling_loop.is_low_temperature = true
    end
  end

  def resolve_dependencies
    unless self.heating_loop_ref.nil?
      heating_loop = self.model_manager.hw_loops[self.heating_loop_ref]
      puts heating_loop
      heating_loop.plant_loop.addDemandBranchForComponent(self.heating_coil)
    end

    unless self.cooling_loop_ref.nil?
      cooling_loop = self.model_manager.chw_loops[self.cooling_loop_ref]
      puts cooling_loop
      cooling_loop.plant_loop.addDemandBranchForComponent(self.cooling_coil)
    end
  end

  def build
    # Object dependency resolution needs to happen before the object is built
    self.model_manager = model_manager
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.supply_fan = add_supply_fan
    self.cooling_coil = add_cooling_coil
    self.unit_ventilator = add_unit_ventilator
    # self.unit_ventilator.setFanControlType('OnOff')

    self.unit_ventilator.setHeatingCoil(self.heating_coil) unless self.heating_coil.nil?
    self.unit_ventilator.setCoolingCoil(self.cooling_coil) unless self.cooling_coil.nil?

    resolve_dependencies

    self.built = true
    self.unit_ventilator
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
        hydronic_loop_id = xml.elements['HydronicLoopId[@hydronicLoopType="HotWater"]']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            equipment.heating_loop_ref = hydronic_loop_id_ref
          end
        end
      end
    end

    unless xml.attributes['coolingCoilType'].nil? or xml.attributes['coolingCoilType'] == "None"
      equipment.cooling_coil_type = xml.attributes['coolingCoilType']

      if equipment.cooling_coil_type == 'ChilledWater'
        hydronic_loop_id = xml.elements['HydronicLoopId[@hydronicLoopType="PrimaryChilledWater"]']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            equipment.cooling_loop_ref = hydronic_loop_id_ref
          end
        end
      end
    end

    equipment
  end
end