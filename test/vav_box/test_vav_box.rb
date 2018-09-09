require 'minitest/autorun'
require 'openstudio'
require_relative '../../measures/gbxml_hvac_import/resources/vav_box/vav_box'
require_relative '../../measures/gbxml_hvac_import/resources/gbxml_parser/gbxml_parser'
require_relative '../../measures/gbxml_hvac_import/resources/model_manager/model_manager'

class TestVAVBox < MiniTest::Test
  def test_xml_creation
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/vav_box.xml'))
    gbxml_parser = GBXMLParser.new(gbxml_path)
    vav_box_xml = gbxml_parser.zone_hvac_equipments[0]
    vav_box = VAVBox.create_from_xml(vav_box_xml)

    assert(vav_box.name == 'ZE1')
    assert(vav_box.cad_object_id == '355591')
    assert(vav_box.id = 'aim19105')
  end

  def test_build
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/vav_box.xml'))
    model = OpenStudio::Model::Model.new
    model_manager = ModelManager.new(model, gbxml_path)

    vav_box = model_manager.zone_hvac_equipments.values[0].air_terminal
    assert(vav_box.name.get == 'ZE1')
    assert(vav_box.additionalProperties.getFeatureAsString('id').get == 'aim19105')
    assert(vav_box.additionalProperties.getFeatureAsString('CADObjectId').get == '355591')

    path = OpenStudio::Path.new(File.expand_path(File.join(File.dirname(__FILE__), '/vav_box.osm')))
    model.save(path, true)
  end
end