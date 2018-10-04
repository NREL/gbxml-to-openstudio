require_relative '../minitest_helper'

class TestACB < MiniTest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = TestConfig::GBXML_FILES + '/ACBAllVariations.xml'
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    self.model = translator.loadModel(self.gbxml_path).get
    self.model_manager = ModelManager.new(self.model, self.gbxml_path)
    self.model_manager.load_gbxml
  end

  def test_xml_creation
    equipment = self.model_manager.zone_hvac_equipments.values[0]
    xml_element = self.model_manager.gbxml_parser.zone_hvac_equipments[0]
    name = xml_element.elements['Name'].text
    id = xml_element.attributes['id']
    cad_object_id = xml_element.elements['CADObjectId'].text

    assert(equipment.name == name)
    assert(equipment.cad_object_id == cad_object_id)
    assert(equipment.id == id)
  end

  def test_build
    self.model_manager.build
    acb = self.model_manager.zone_hvac_equipments.values[0].acb

    assert(acb.heatingCoil.to_CoilHeatingWater.is_initialized)
    assert(acb.coolingCoil.get.to_CoilCoolingWater.is_initialized)
    assert(acb.is_a?(OpenStudio::Model::AirTerminalSingleDuctConstantVolumeFourPipeInduction))

    # only need to test one object for this mapping
    assert(acb.name.get == 'ACBs')
    assert(acb.additionalProperties.getFeatureAsString('id').get == 'aim0831')
    assert(acb.additionalProperties.getFeatureAsString('CADObjectId').get == '280066-1')
  end

  def test_simulation
    # set osw_path to find location of osw to run
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/acb/in.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" run -w \"#{osw_in_path}\""
    system(cmd)

    osw_out_path = TestConfig::TEST_OUTPUT_PATH + '/acb/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end
end