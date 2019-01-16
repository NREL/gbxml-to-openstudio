require_relative '../hvac_object/hvac_object'

class PFPB < HVACObject
  attr_accessor :air_terminal, :air_terminal_type, :supply_fan, :heating_coil, :heating_coil_type, :heating_loop_ref, :air_loop, :air_loop_ref

  def initialize
    self.name = "PFPB"
  end

  def connect_thermal_zone(thermal_zone)
    outlet_node = self.air_terminal.outletModelObject.get.to_Node.get
    thermal_zone.addToNode(outlet_node)
  end

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
    OpenStudio::Model::FanConstantVolume.new(self.model)
  end

  def add_heating_coil
    heating_coil = OpenStudio::Model::CoilHeatingElectric.new(self.model)
    heating_coil.setNominalCapacity(0)

    if self.heating_coil_type == "ElectricResistance"
      heating_coil = OpenStudio::Model::CoilHeatingElectric.new(self.model)
      heating_coil.setNominalCapacity(0) if self.air_terminal_type == 'NoReheat'
    elsif self.heating_coil_type == "Furnace"
      heating_coil = OpenStudio::Model::CoilHeatingGas.new(self.model)
      heating_coil.setNominalCapacity(0) if self.air_terminal_type == 'NoReheat'
    elsif self.heating_coil_type == "HotWater"
      heating_coil = OpenStudio::Model::CoilHeatingWater.new(self.model)
      heating_coil.setRatedCapacity(0) if self.air_terminal_type == 'NoReheat'
    end

    if heating_coil
      heating_coil.setName(self.name + " Heating Coil") unless self.name.nil?
    end

    heating_coil
  end

  def resolve_dependencies
    unless self.heating_loop_ref.nil?
      heating_loop = self.model_manager.hw_loops[self.heating_loop_ref]
      heating_loop.plant_loop.addDemandBranchForComponent(self.heating_coil)
    end

    unless self.air_loop_ref.nil?
      air_loop = self.model_manager.air_systems[self.air_loop_ref]
      air_loop.air_loop_hvac.addBranchForHVACComponent(self.air_terminal)
    end
  end

  def build
    # Object dependency resolution needs to happen before the object is built
    self.model_manager = model_manager
    self.model = model_manager.model
    self.supply_fan = add_supply_fan
    self.heating_coil = add_heating_coil
    self.air_terminal = add_air_terminal
    resolve_dependencies

    self.built = true
    self.air_terminal
  end

  def self.create_from_xml(model_manager, xml)
    equipment = new
    equipment.model_manager = model_manager

    name = xml.elements['Name']
    equipment.set_name(xml.elements['Name'].text) unless name.nil?
    equipment.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    equipment.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    air_loop_ref = xml.elements['AirSystemId']
    unless air_loop_ref.nil?
      equipment.air_loop_ref = xml.elements['AirSystemId'].attributes['airSystemIdRef']
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
end