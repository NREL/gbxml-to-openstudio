require_relative 'minitest_helper'

class TestBaseboardRadiant < MiniTest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = Config::GBXML_FILES + '/BaseboardRadiantConvectiveAllVariations.xml'
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
    baseboard_elec = self.model_manager.zone_hvac_equipments.values[0].baseboard
    baseboard_hw = self.model_manager.zone_hvac_equipments.values[1].baseboard

    assert(baseboard_elec.is_a?(OpenStudio::Model::ZoneHVACBaseboardRadiantConvectiveElectric))

    assert(baseboard_hw.heatingCoil.to_CoilHeatingWaterBaseboardRadiant.is_initialized)
    assert(baseboard_hw.is_a?(OpenStudio::Model::ZoneHVACBaseboardRadiantConvectiveWater))

    assert(baseboard_elec.name.get == 'Baseboard Elec')
    assert(baseboard_elec.additionalProperties.getFeatureAsString('id').get == 'aim0824')
    assert(baseboard_elec.additionalProperties.getFeatureAsString('CADObjectId').get == '280066-1')
  end

  def test_create_osw
    osw = create_gbxml_test_osw
    osw = add_gbxml_test_measure_steps(osw, 'BaseboardRadiantConvectiveAllVariations.xml')
    osw_in_path = Config::TEST_OUTPUT_PATH + '/baseboard_radiant/in.osw'
    osw.saveAs(osw_in_path)
  end

  def test_simulation
    # set osw_path to find location of osw to run
    osw_in_path = Config::TEST_OUTPUT_PATH + '/baseboard_radiant/in.osw'
    cmd = "\"#{Config::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = Config::TEST_OUTPUT_PATH + '/baseboard_radiant/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end
end