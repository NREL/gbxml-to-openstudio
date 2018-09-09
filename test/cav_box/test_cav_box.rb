require 'minitest/autorun'
require 'openstudio'
require_relative '../../measures/gbxml_hvac_import/resources/cav_box/cav_box'
require_relative '../../measures/gbxml_hvac_import/resources/gbxml_parser/gbxml_parser'
require_relative '../../measures/gbxml_hvac_import/resources/model_manager/model_manager'

class TestCAVBox < MiniTest::Test
  def test_xml_creation
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/cav_box.xml'))
    gbxml_parser = GBXMLParser.new(gbxml_path)
    cav_box_xml = gbxml_parser.zone_hvac_equipments[0]
    cav_box = CAVBox.create_from_xml(cav_box_xml)

    assert(cav_box.name == 'ZE1')
    assert(cav_box.cad_object_id == '355591')
    assert(cav_box.id = 'aim19105')
  end

  def test_build
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/cav_box.xml'))
    model = OpenStudio::Model::Model.new
    model_manager = ModelManager.new(model, gbxml_path)

    cav_box = model_manager.zone_hvac_equipments.values[0].air_terminal
    assert(cav_box.name.get == 'ZE1')
    assert(cav_box.additionalProperties.getFeatureAsString('id').get == 'aim19105')
    assert(cav_box.additionalProperties.getFeatureAsString('CADObjectId').get == '355591')

    path = OpenStudio::Path.new(File.expand_path(File.join(File.dirname(__FILE__), '/cav_box.osm')))
    model.save(path, true)
  end
end