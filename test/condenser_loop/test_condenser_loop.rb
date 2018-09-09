require 'minitest/autorun'
require 'openstudio'
require_relative '../../measures/gbxml_hvac_import/resources/condenser_loop/condenser_loop'
require_relative '../../measures/gbxml_hvac_import/resources/gbxml_parser/gbxml_parser'
require_relative '../../measures/gbxml_hvac_import/resources/model_manager/model_manager'


class TestCondenserLoop < MiniTest::Test
  def test_xml_creation
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/condenser_loop.xml'))
    gbxml_parser = GBXMLParser.new(gbxml_path)
    cw_loop = gbxml_parser.cw_loops[0]
    condenser_loop = CondenserLoop.create_from_xml(cw_loop)

    assert(condenser_loop.name == 'CDW-01')
    assert(condenser_loop.cad_object_id == '364633')
    assert(condenser_loop.id = 'aim72793')
  end

  def test_build
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/condenser_loop.xml'))
    model = OpenStudio::Model::Model.new
    model_manager = ModelManager.new(model, gbxml_path)

    os_loop = model_manager.cw_loops.values[0].plant_loop
    assert(os_loop.name.get == 'CDW-01')
    assert(os_loop.additionalProperties.getFeatureAsString('id').get == 'aim72793')
    assert(os_loop.additionalProperties.getFeatureAsString('CADObjectId').get == '364633')
  end
end