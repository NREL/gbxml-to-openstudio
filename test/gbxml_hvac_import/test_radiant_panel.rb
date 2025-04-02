require_relative 'minitest_helper'

class TestRadiantPanel < MiniTest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = Config::GBXML_FILES + '/RadiantPanelAllVariations.xml'
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    self.model = translator.loadModel(self.gbxml_path).get
    self.model_manager = ModelManager.new(self.model, self.gbxml_path)
    self.model_manager.load_gbxml
  end

  def test_xml_creation
    puts "\n######\nTEST:#{__method__}\n######\n"
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
    puts "\n######\nTEST:#{__method__}\n######\n"
    self.model_manager.resolve_references
    self.model_manager.resolve_read_relationships
    self.model_manager.build
    radiant_panel_hw = self.model_manager.zone_hvac_equipments.values[0].radiant_panel
    radiant_panel_hw2 = self.model_manager.zone_hvac_equipments.values[1].radiant_panel
    radiant_panel_elec = self.model_manager.zone_hvac_equipments.values[2].radiant_panel

    assert(radiant_panel_hw.heatingCoil.to_CoilHeatingWater.is_initialized)
    assert(radiant_panel_hw2.heatingCoil.to_CoilHeatingWater.is_initialized)
    assert(radiant_panel_elec.heatingCoil.to_CoilHeatingElectric.is_initialized)
    assert(radiant_panel_elec.coolingCoil.to_CoilCoolingWater.is_initialized)
    assert(radiant_panel_elec.supplyAirFan.to_FanOnOff.is_initialized)
    assert(radiant_panel_elec.is_a?(OpenStudio::Model::ZoneHVACFourPipeFanCoil))

    # only need to test one object for this mapping
    assert(radiant_panel_elec.name.get == 'Radiant Panel Elec-1')
    assert(radiant_panel_elec.additionalProperties.getFeatureAsString('id').get == 'aim0943')
    assert(radiant_panel_elec.additionalProperties.getFeatureAsString('CADObjectId').get == '280066-1')
  end

  def create_osw
    osw = create_test_sizing_osw
    osw = adjust_gbxml_paths(osw, 'RadiantPanelAllVariations.xml')
    osw_in_path = Config::TEST_OUTPUT_PATH + '/radiant_panel/in.osw'
    osw.saveAs(osw_in_path)
  end

  def test_simulation
    puts "\n######\nTEST:#{__method__}\n######\n"
    create_osw
    # set osw_path to find location of osw to run
    osw_in_path = Config::TEST_OUTPUT_PATH + '/radiant_panel/in.osw'
    cmd = "\"#{Config::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = Config::TEST_OUTPUT_PATH + '/radiant_panel/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end
end