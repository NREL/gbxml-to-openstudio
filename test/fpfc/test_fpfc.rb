require_relative '../minitest_helper'

class TestFPFC < MiniTest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = TestConfig::GBXML_FILES + '/FPFCAllVariations.xml'
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    self.model = translator.loadModel(self.gbxml_path).get
    self.model_manager = ModelManager.new(self.model, self.gbxml_path)
    self.model_manager.load_gbxml
    self.model_manager.resolve_read_relationships
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
    fpfc = self.model_manager.zone_hvac_equipments.values[0].fpfc

    assert(fpfc.coolingCoil.to_CoilCoolingWater.is_initialized)
    assert(fpfc.heatingCoil.to_CoilHeatingWater.is_initialized)
    assert(fpfc.supplyAirFan.to_FanOnOff.is_initialized)
    assert(fpfc.is_a?(OpenStudio::Model::ZoneHVACFourPipeFanCoil))

    # only need to test one object for this mapping
    assert(fpfc.name.get == 'FPFC')
    assert(fpfc.additionalProperties.getFeatureAsString('id').get == 'aim0829')
    assert(fpfc.additionalProperties.getFeatureAsString('CADObjectId').get == '280595-1')
  end

  def test_create_osw
    osw = TestConfig.create_gbxml_test_osw
    osw = TestConfig.add_gbxml_test_measure_steps(osw, 'FPFCAllVariations.xml')
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/fpfc/in.osw'
    osw.saveAs(osw_in_path)
  end

  def test_simulation
    # set osw_path to find location of osw to run
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/fpfc/in.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = TestConfig::TEST_OUTPUT_PATH + '/fpfc/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end
end