require_relative '../hvac_object/hvac_object'

class VRFCondenser < HVACObject
  attr_accessor :condenser, :condenser_loop_ref

  def initialize
    self.name = "VRF Condenser"
  end

  def add_condenser
    condenser = OpenStudio::Model::AirConditionerVariableRefrigerantFlow.new(model)
    condenser.setName(self.name) unless self.name.nil?
    condenser.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    condenser.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?

    condenser
  end

  def resolve_dependencies
    if self.condenser_loop_ref
      condenser_loop = self.model_manager.cw_loops[self.condenser_loop_ref]
      condenser_loop.plant_loop.addDemandBranchForComponent(self.condenser)
      # self.condenser.setCondenserType('WaterCooled')
      # get object from ModelManager and build that object
    end
  end

  def build
    # Object dependency resolution needs to happen before the object is built
    self.model_manager = model_manager
    self.model = model_manager.model
    self.condenser = add_condenser

    resolve_dependencies

    self.condenser.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    self.condenser.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?

    self.built = true
    self.condenser
  end

  def self.create_from_xml(model_manager, xml)
    vrf_condenser = new
    vrf_condenser.model_manager = model_manager

    name = xml.elements['Name']
    vrf_condenser.set_name(xml.elements['Name'].text) unless name.nil?
    vrf_condenser.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    vrf_condenser.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    cw_loop_ref = xml.elements['HydronicLoopId[@hydronicLoopType="CondenserWater"]']
    unless cw_loop_ref.nil?
      vrf_condenser.condenser_loop_ref = xml.elements['HydronicLoopId'].attributes['hydronicLoopIdRef']
    end

    vrf_condenser
  end
end