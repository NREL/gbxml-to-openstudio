require 'minitest/autorun'
require 'openstudio'
require_relative '../../measures/gbxml_hvac_import/resources/chilled_water_loop/chilled_water_loop'
require_relative '../../measures/gbxml_hvac_import/resources/gbxml_parser/gbxml_parser'
require_relative '../../measures/gbxml_hvac_import/resources/model_manager/model_manager'

class TestChilledWaterLoop < MiniTest::Test
  def test_air_cooled_xml_creation
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/ac_chw_loop.xml'))
    gbxml_parser = GBXMLParser.new(gbxml_path)
    chw_loop = gbxml_parser.chw_loops[0]
    chilled_water_loop = ChilledWaterLoop.create_from_xml(chw_loop)

    assert(chilled_water_loop.name == 'CHW-01')
    assert(chilled_water_loop.cad_object_id == '364632')
    assert(chilled_water_loop.id == 'aim72792')
  end

  def test_air_cooled_build
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/ac_chw_loop.xml'))
    model = OpenStudio::Model::Model.new
    model_manager = ModelManager.new(model, gbxml_path)

    os_loop = model_manager.chw_loops.values[0].plant_loop
    assert(os_loop.name.get == 'CHW-01')
    assert(os_loop.additionalProperties.getFeatureAsString('id').get == 'aim72792')
    assert(os_loop.additionalProperties.getFeatureAsString('CADObjectId').get == '364632')
  end

  def test_water_cooled_xml_creation
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/wc_chw_loop.xml'))
    gbxml_parser = GBXMLParser.new(gbxml_path)
    chw_loop = gbxml_parser.chw_loops[0]
    chilled_water_loop = ChilledWaterLoop.create_from_xml(chw_loop)

    assert(chilled_water_loop.name == 'CHW-01')
    assert(chilled_water_loop.cad_object_id == '364632')
    assert(chilled_water_loop.id == 'aim72792')
    assert(chilled_water_loop.condenser_loop_ref == 'aim72793')
  end

  def test_water_cooled_build
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/wc_chw_loop.xml'))
    model = OpenStudio::Model::Model.new
    model_manager = ModelManager.new(model, gbxml_path)

    chilled_water_loop = model_manager.chw_loops.values[0]
    os_chw_loop = chilled_water_loop.plant_loop
    assert(os_chw_loop.name.get == 'CHW-01')
    assert(os_chw_loop.additionalProperties.getFeatureAsString('id').get == 'aim72792')
    assert(os_chw_loop.additionalProperties.getFeatureAsString('CADObjectId').get == '364632')
    assert( chilled_water_loop.chiller.secondaryPlantLoop.get.name.get == 'CDW-01')
  end
end