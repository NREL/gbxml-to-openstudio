require_relative 'minitest_helper'

class TestPTHP < MiniTest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = Config::GBXML_FILES + '/PTHPAllVariations.xml'
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
    equipment = self.model_manager.zone_hvac_equipments.values[0].pthp

    assert(equipment.coolingCoil.to_CoilCoolingDXSingleSpeed.is_initialized)
    assert(equipment.heatingCoil.to_CoilHeatingDXSingleSpeed.is_initialized)
    assert(equipment.supplyAirFan.to_FanOnOff.is_initialized)
    assert(equipment.supplementalHeatingCoil.to_CoilHeatingElectric.is_initialized)
    assert(equipment.is_a?(OpenStudio::Model::ZoneHVACPackagedTerminalHeatPump))

    assert(equipment.name.get == 'PTHP')
    assert(equipment.additionalProperties.getFeatureAsString('id').get == 'aim0823')
    assert(equipment.additionalProperties.getFeatureAsString('CADObjectId').get == '280066-1')
  end

  def create_osw
    osw = create_test_sizing_osw
    osw = adjust_gbxml_paths(osw, 'PTHPAllVariations.xml')
    osw_in_path = Config::TEST_OUTPUT_PATH + '/pthp/in.osw'
    osw.saveAs(osw_in_path)
  end

  def test_simulation
    create_osw
    # set osw_path to find location of osw to run
    osw_in_path = Config::TEST_OUTPUT_PATH + '/pthp/in.osw'
    cmd = "\"#{Config::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = Config::TEST_OUTPUT_PATH + '/pthp/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end
end