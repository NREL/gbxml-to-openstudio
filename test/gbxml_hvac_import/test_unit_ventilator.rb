require_relative 'minitest_helper'

class TestUnitVentilator < MiniTest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = Config::GBXML_FILES + '/UnitVentilatorAllVariations.xml'
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
    uv_elec_chw = self.model_manager.zone_hvac_equipments.values[0].unit_ventilator
    uv_furn_none = self.model_manager.zone_hvac_equipments.values[1].unit_ventilator
    uv_hw_none = self.model_manager.zone_hvac_equipments.values[2].unit_ventilator
    uv_all_none = self.model_manager.zone_hvac_equipments.values[3].unit_ventilator

    assert(uv_elec_chw.coolingCoil.get.to_CoilCoolingWater.is_initialized)
    assert(uv_elec_chw.heatingCoil.get.to_CoilHeatingElectric.is_initialized)
    assert(uv_elec_chw.supplyAirFan.to_FanConstantVolume.is_initialized)
    assert(uv_elec_chw.is_a?(OpenStudio::Model::ZoneHVACUnitVentilator))

    assert(uv_furn_none.heatingCoil.get.to_CoilHeatingGas.is_initialized)
    assert(!uv_furn_none.coolingCoil.is_initialized)
    assert(uv_hw_none.heatingCoil.get.to_CoilHeatingWater.is_initialized)
    assert(!uv_hw_none.coolingCoil.is_initialized)
    assert(!uv_all_none.heatingCoil.is_initialized)
    assert(!uv_all_none.coolingCoil.is_initialized)

    # only need to test one object for this mapping
    assert(uv_elec_chw.name.get == 'UV Electric CHW')
    assert(uv_elec_chw.additionalProperties.getFeatureAsString('id').get == 'aim0826')
    assert(uv_elec_chw.additionalProperties.getFeatureAsString('CADObjectId').get == '280066-1')
  end

  def test_create_osw
    osw = create_gbxml_test_osw
    osw = add_gbxml_test_measure_steps(osw, 'UnitVentilatorAllVariations.xml')
    osw_in_path = Config::TEST_OUTPUT_PATH + '/unit_ventilator/in.osw'
    osw.saveAs(osw_in_path)
  end

  def test_simulation
    # set osw_path to find location of osw to run
    osw_in_path = Config::TEST_OUTPUT_PATH + '/unit_ventilator/in.osw'
    cmd = "\"#{Config::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = Config::TEST_OUTPUT_PATH + '/unit_ventilator/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end
end