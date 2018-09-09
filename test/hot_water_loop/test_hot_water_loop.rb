require 'minitest/autorun'
require 'openstudio'
require_relative '../../measures/gbxml_hvac_import/resources/hot_water_loop/hot_water_loop'
require_relative '../../measures/gbxml_hvac_import/resources/gbxml_parser/gbxml_parser'
require_relative '../../measures/gbxml_hvac_import/resources/model_manager/model_manager'

class TestHotWaterLoop < MiniTest::Test
  def test_xml_creation
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/hot_water_loop.xml'))
    gbxml_parser = GBXMLParser.new(gbxml_path)
    hw_loop = gbxml_parser.hw_loops[0]
    hot_water_loop = HotWaterLoop.create_from_xml(hw_loop)

    assert(hot_water_loop.name == 'HW-01')
    assert(hot_water_loop.cad_object_id == '364631')
    assert(hot_water_loop.id = 'aim72791')
  end

  def test_build
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/hot_water_loop.xml'))
    model = OpenStudio::Model::Model.new
    model_manager = ModelManager.new(model, gbxml_path)

    os_loop = model_manager.hw_loops.values[0].plant_loop
    assert(os_loop.name.get == 'HW-01')
    assert(os_loop.additionalProperties.getFeatureAsString('id').get == 'aim72791')
    assert(os_loop.additionalProperties.getFeatureAsString('CADObjectId').get == '364631')
  end
end