require_relative '../minitest_helper'

class TestChilledWaterLoop < MiniTest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = TestConfig::GBXML_FILES + '/AirSystemAllVariations.xml'
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    self.model = translator.loadModel(self.gbxml_path).get
    self.model_manager = ModelManager.new(self.model, self.gbxml_path)
    self.model_manager.load_gbxml
  end

  def test_xml_creation
    equipment = self.model_manager.chw_loops.values[0]
    xml_element = self.model_manager.gbxml_parser.chw_loops[0]
    name = xml_element.elements['Name'].text
    id = xml_element.attributes['id']
    cad_object_id = xml_element.elements['CADObjectId'].text

    assert(equipment.name == name)
    assert(equipment.cad_object_id == cad_object_id)
    assert(equipment.id == id)
  end

  def test_build
    self.model_manager.build
    equipment = self.model_manager.chw_loops.values[0].plant_loop

    assert(equipment.supplySplitter.outletModelObject(0).get.to_Node.get.outletModelObject.get.to_ChillerElectricEIR.is_initialized)
    assert(equipment.supplyInletNode.outletModelObject.get.to_PumpVariableSpeed.is_initialized)
    assert(equipment.name.get == 'CHW Loop')
    assert(equipment.additionalProperties.getFeatureAsString('id').get == 'aim0824')
    assert(equipment.additionalProperties.getFeatureAsString('CADObjectId').get == '280687')
  end
end