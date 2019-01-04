require_relative '../minitest_helper'

class TestBaseboardConvective < MiniTest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = TestConfig::GBXML_FILES + '/BaseboardConvectiveAllVariations.xml'
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

    assert(baseboard_elec.is_a?(OpenStudio::Model::ZoneHVACBaseboardConvectiveElectric))

    assert(baseboard_hw.heatingCoil.to_CoilHeatingWaterBaseboard.is_initialized)
    assert(baseboard_hw.is_a?(OpenStudio::Model::ZoneHVACBaseboardConvectiveWater))

    assert(baseboard_elec.name.get == 'Baseboard Elec')
    assert(baseboard_elec.additionalProperties.getFeatureAsString('id').get == 'aim0824')
    assert(baseboard_elec.additionalProperties.getFeatureAsString('CADObjectId').get == '280066-1')
  end

  def test_create_osw
    osw = TestConfig.create_gbxml_test_osw
    osw = TestConfig.add_gbxml_test_measure_steps(osw, 'BaseboardConvectiveAllVariations.xml')

    old_model_measure_steps = osw.getMeasureSteps(OpenStudio::MeasureType.new("ModelMeasure"))
    osw.resetWorkflowSteps
    new_model_measure_steps = []
    old_model_measure_steps.each { |step| new_model_measure_steps << step }

    m = OpenStudio::MeasureStep.new("gbxml_to_openstudio_cleanup")
    m.setName('gbxml_to_openstudio_cleanup')
    new_model_measure_steps << m

    eplus_measures = []
    m = OpenStudio::MeasureStep.new("add_xml_output_control_style")
    m.setName('Add XML Output Control Style')
    eplus_measures << m
    osw = TestConfig.add_osw_measure_steps(osw, model_measure_steps: new_model_measure_steps, energyplus_measure_steps: eplus_measures)

    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/baseboard_convective/in.osw'
    osw.saveAs(osw_in_path)
  end

  def test_simulation
    # set osw_path to find location of osw to run
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/baseboard_convective/in.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = TestConfig::TEST_OUTPUT_PATH + '/baseboard_convective/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end
end