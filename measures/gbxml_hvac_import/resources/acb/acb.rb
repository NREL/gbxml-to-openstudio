require_relative '../hvac_object/hvac_object'

class ACB < HVACObject
  attr_accessor :acb, :supply_fan, :cooling_coil, :cooling_loop_ref, :heating_coil, :heating_loop_ref, :air_loop_ref, :air_loop

  def initialize
    self.name = "ACB"
  end

  def connect_thermal_zone(thermal_zone)
    induced_air_node = OpenStudio::Model::Node.new(model)
    exhaust_port_list = thermal_zone.exhaustPortList

    model.connect(exhaust_port_list, exhaust_port_list.nextPort, induced_air_node, induced_air_node.inletPort)
    model.connect(induced_air_node, induced_air_node.outletPort, self.acb, self.acb.inducedAirInletPort)

    # thermal_zone.addEquipment(self.acb)

    outlet_node = self.acb.outletModelObject.get.to_Node.get
    thermal_zone.addToNode(outlet_node)
    # # self.acb.addToNode(thermal_zone.zoneAirNode)
    # thermal_zone.addEquipment(self.acb)
  end

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
    heating_coil
  end

  def add_cooling_coil
    cooling_coil = OpenStudio::Model::CoilCoolingWater.new(self.model)
    cooling_coil.setName(self.name + " Cooling Coil") unless self.name.nil?
    cooling_coil
  end

  def resolve_dependencies
    unless self.heating_loop_ref.nil?
      heating_loop = self.model_manager.hw_loops[self.heating_loop_ref]
      heating_loop.plant_loop.addDemandBranchForComponent(self.heating_coil)
    end

    unless self.cooling_loop_ref.nil?
      cooling_loop = self.model_manager.chw_loops[self.cooling_loop_ref]
      cooling_loop.plant_loop.addDemandBranchForComponent(self.cooling_coil)
    end

    unless self.air_loop_ref.nil?
      air_loop = self.model_manager.air_systems[self.air_loop_ref]
      air_loop.air_loop_hvac.addBranchForHVACComponent(self.acb)
    end
  end

  def build
    # Object dependency resolution needs to happen before the object is built
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.cooling_coil = add_cooling_coil
    self.acb = add_acb

    self.acb.setHeatingCoil(self.heating_coil) unless self.heating_coil.nil?
    self.acb.setCoolingCoil(self.cooling_coil) unless self.cooling_coil.nil?

    resolve_dependencies

    self.built = true
    self.acb
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
end