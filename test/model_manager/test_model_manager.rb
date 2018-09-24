require_relative '../minitest_helper'

# TODO: Develop more substantial tests
class TestModelManager < MiniTest::Test
  def test_model_manager
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '../../gbxmls/Analytical Systems 01.xml'))
    model = OpenStudio::Model::Model.new
    model_manager = ModelManager.new(model, gbxml_path)
    model_manager.load_gbxml

    assert(model_manager.cw_loops.count == 1)
    assert(model_manager.hw_loops.count == 1)
    assert(model_manager.chw_loops.count == 1)
  end
end