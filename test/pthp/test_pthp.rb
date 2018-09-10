require 'minitest/autorun'
require 'openstudio'
require_relative '../../measures/gbxml_hvac_import/resources/pthp/pthp'
require_relative '../../measures/gbxml_hvac_import/resources/gbxml_parser/gbxml_parser'
require_relative '../../measures/gbxml_hvac_import/resources/model_manager/model_manager'

class TestPTHP < MiniTest::Test
  def test_xml_creation
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/pthp.xml'))
    gbxml_parser = GBXMLParser.new(gbxml_path)
    equipment_xml = gbxml_parser.zone_hvac_equipments[0]
    equipment = PTHP.create_from_xml(equipment_xml)

    assert(equipment.name == 'ZE2')
    assert(equipment.cad_object_id == '355592-24')
    assert(equipment.id = 'aim19166')
  end

  def test_build
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/pthp.xml'))
    model = OpenStudio::Model::Model.new
    model_manager = ModelManager.new(model, gbxml_path)

    equipment = model_manager.zone_hvac_equipments.values[0].pthp
    assert(equipment.name.get == 'ZE2')
    assert(equipment.additionalProperties.getFeatureAsString('id').get == 'aim19166')
    assert(equipment.additionalProperties.getFeatureAsString('CADObjectId').get == '355592-24')

    path = OpenStudio::Path.new(File.expand_path(File.join(File.dirname(__FILE__), '/pthp.osm')))
    model.save(path, true)
  end
end