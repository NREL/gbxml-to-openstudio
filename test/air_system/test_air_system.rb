require 'minitest/autorun'
require 'openstudio'
require_relative '../../measures/gbxml_hvac_import/resources/air_system/air_system'
require_relative '../../measures/gbxml_hvac_import/resources/gbxml_parser/gbxml_parser'
require_relative '../../measures/gbxml_hvac_import/resources/model_manager/model_manager'

class TestAirSystem < Minitest::Test
  def test_air_system_xml_creation
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/air_system.xml'))
    gbxml_parser = GBXMLParser.new(gbxml_path)
    air_system_xml = gbxml_parser.air_systems[0]
    air_system = AirSystem.create_from_xml(air_system_xml)

    assert(air_system.name == 'AHU2')
    assert(air_system.cad_object_id == '355590')
    assert(air_system.id == 'aim19101')
  end

  def test_air_system_build
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/air_system.xml'))
    model = OpenStudio::Model::Model.new
    model_manager = ModelManager.new(model, gbxml_path)

    air_loop_hvac = model_manager.air_systems.values[0].air_loop_hvac
    assert(air_loop_hvac.name.get == 'AHU1')
    assert(air_loop_hvac.additionalProperties.getFeatureAsString('id').get == 'aim19100')
    assert(air_loop_hvac.additionalProperties.getFeatureAsString('CADObjectId').get == '355590')

    path = OpenStudio::Path.new(File.expand_path(File.join(File.dirname(__FILE__), '/air_system.osm')))
    model.save(path, true)
  end
end