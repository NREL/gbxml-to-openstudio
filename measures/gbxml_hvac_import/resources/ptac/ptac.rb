require_relative '../hvac_object/hvac_object'

class PTAC < HVACObject
  attr_accessor :ptac, :supply_fan, :cooling_coil, :heating_coil, :heating_coil_type, :heating_loop_ref

  def initialize
    self.name = "PTAC"
  end

  def connect_thermal_zone(thermal_zone)
    self.ptac.addToThermalZone(thermal_zone)
  end

  def add_ptac
    ptac = OpenStudio::Model::ZoneHVACPackagedTerminalAirConditioner.new(self.model, self.model.alwaysOnDiscreteSchedule, self.supply_fan, self.heating_coil, self.cooling_coil)
    ptac.setName(self.name) unless self.name.nil?
    ptac.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    ptac.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    ptac
  end

  def add_supply_fan
    OpenStudio::Model::FanOnOff.new(self.model)
  end

  def add_heating_coil
    # temporary hold while the gbXML file is missing the heating coil info
    heating_coil = OpenStudio::Model::CoilHeatingGas.new(self.model)

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
    OpenStudio::Model::CoilCoolingDXSingleSpeed.new(self.model)
  end

  def resolve_dependencies
    unless self.heating_loop_ref.nil?
      heating_loop = self.model_manager.hw_loops[self.heating_loop_ref]
      heating_loop.plant_loop.addDemandBranchForComponent(self.heating_coil)
    end
  end

  def build(model_manager)
    # Object dependency resolution needs to happen before the object is built
    self.model_manager = model_manager
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.supply_fan = add_supply_fan
    self.cooling_coil = add_cooling_coil
    self.ptac = add_ptac
    resolve_dependencies

    self.built = true
    self.ptac
  end

  def self.create_from_xml(xml)
    equipment = new

    name = xml.elements['Name']
    equipment.set_name(xml.elements['Name'].text) unless name.nil?
    equipment.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    equipment.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    # unless xml.attributes['heatingCoilType'].nil? or xml.attributes['heatingCoilType'] == "None"
    #   equipment.heating_coil_type = xml.attributes['heatingCoilType']
    #
    #   if equipment.heating_coil_type == 'HotWater'
        hydronic_loop_id = xml.elements['HydronicLoopId']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            equipment.heating_coil_type = 'HotWater'
            equipment.heating_loop_ref = hydronic_loop_id_ref
          end
        end
    #   end
    # end

    equipment
  end
end