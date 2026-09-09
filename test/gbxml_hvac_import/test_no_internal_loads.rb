require_relative 'minitest_helper'

class TestOSResult < MiniTest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = Config::GBXML_FILES + '/Simple_Test_Model-internal-loads.xml'
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    self.model = translator.loadModel(self.gbxml_path).get
    self.model_manager = ModelManager.new(self.model, self.gbxml_path)
    self.model_manager.load_gbxml
    self.model_manager.resolve_references
    self.model_manager.resolve_read_relationships
  end

  def create_osw
    osw = create_test_annual_osw
    osw = adjust_gbxml_paths(osw, 'Simple_Test_Model-internal-loads.xml')
    osw_in_path = Config::TEST_OUTPUT_PATH + '/no_int_loads/in.osw'
    osw.saveAs(osw_in_path)
  end

  def test_simulation
    create_osw
    # set osw_path to find location of osw to run
    osw_in_path = Config::TEST_OUTPUT_PATH + '/no_int_loads/in.osw'
    cmd = "\"#{Config::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = Config::TEST_OUTPUT_PATH + '/no_int_loads/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end


end
