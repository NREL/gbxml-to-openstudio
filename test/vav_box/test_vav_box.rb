require_relative '../minitest_helper'

class TestVAVBox < MiniTest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = TestConfig::GBXML_FILES + '/VAVBoxAllVariations.xml'
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
    vav_box_elec = self.model_manager.zone_hvac_equipments.values[0].air_terminal
    vav_box_furn = self.model_manager.zone_hvac_equipments.values[1].air_terminal
    vav_box_hw = self.model_manager.zone_hvac_equipments.values[2].air_terminal
    vav_box_no_rh = self.model_manager.zone_hvac_equipments.values[3].air_terminal

    assert(vav_box_elec.reheatCoil.to_CoilHeatingElectric.is_initialized)
    assert(vav_box_elec.is_a?(OpenStudio::Model::AirTerminalSingleDuctVAVReheat))

    assert(vav_box_furn.reheatCoil.to_CoilHeatingGas.is_initialized)
    assert(vav_box_hw.reheatCoil.to_CoilHeatingWater.is_initialized)
    assert(vav_box_no_rh.is_a?(OpenStudio::Model::AirTerminalSingleDuctVAVNoReheat))


    # only need to test one object for this mapping
    assert(vav_box_elec.name.get == 'VAV Box Electric')
    assert(vav_box_elec.additionalProperties.getFeatureAsString('id').get == 'aim0828')
    assert(vav_box_elec.additionalProperties.getFeatureAsString('CADObjectId').get == '280066-1')
  end

  def test_create_osw
    osw = TestConfig.create_gbxml_test_osw
    osw = TestConfig.add_gbxml_test_measure_steps(osw, 'VAVBoxAllVariations.xml')
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/vav_box/in.osw'
    osw.saveAs(osw_in_path)
  end

  def test_simulation
    # set osw_path to find location of osw to run
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/vav_box/in.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = TestConfig::TEST_OUTPUT_PATH + '/vav_box/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end
end