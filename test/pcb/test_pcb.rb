require_relative '../minitest_helper'

class TestPCB < MiniTest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = TestConfig::GBXML_FILES + '/PCBAllVariations.xml'
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
    pcb = self.model_manager.zone_hvac_equipments.values[0].pcb

    assert(pcb.heatingCoil.to_CoilHeatingWater.is_initialized)
    assert(pcb.coolingCoil.to_CoilCoolingWater.is_initialized)
    assert(pcb.is_a?(OpenStudio::Model::ZoneHVACFourPipeFanCoil))

    # only need to test one object for this mapping
    assert(pcb.name.get == 'PCBs')
    assert(pcb.additionalProperties.getFeatureAsString('id').get == 'aim0827')
    assert(pcb.additionalProperties.getFeatureAsString('CADObjectId').get == '280066-1')
  end

  def test_create_osw
    osw = create_gbxml_test_osw
    osw = add_gbxml_test_measure_steps(osw, 'PCBAllVariations.xml')
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/pcb/in.osw'
    osw.saveAs(osw_in_path)
  end

  def test_simulation
    # set osw_path to find location of osw to run
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/pcb/in.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = TestConfig::TEST_OUTPUT_PATH + '/pcb/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end
end