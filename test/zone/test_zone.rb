require 'minitest/autorun'
require 'openstudio'
require_relative '../../measures/gbxml_hvac_import/resources/zone/zone'
require_relative '../../measures/gbxml_hvac_import/resources/gbxml_parser/gbxml_parser'
require_relative '../../measures/gbxml_hvac_import/resources/model_manager/model_manager'

class TestZone < MiniTest::Test
  def test_xml_creation
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/zone.xml'))
    gbxml_parser = GBXMLParser.new(gbxml_path)
    zone_xml = gbxml_parser.zones[0]
    zone = Zone.create_from_xml(zone_xml)

    assert(zone.name == 'ZE2-25')
    assert(zone.id == 'aim19287')
  end

  def test_build
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '/zone.xml'))
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    model = translator.loadModel(gbxml_path)
    if model.empty?
      runner.registerError("Could not translate gbXML filename '#{gbxml_path}' to OSM.")
      return false
    end
    model = model.get
    model_manager = ModelManager.new(model, gbxml_path)

    zone = model_manager.zones.values[0].thermal_zone
    assert(zone.name.get == 'ZE2-25')
    assert(zone.additionalProperties.getFeatureAsString('id').get == 'aim19287')

    path = OpenStudio::Path.new(File.expand_path(File.join(File.dirname(__FILE__), '/zone.osm')))
    model.save(path, true)
  end
end