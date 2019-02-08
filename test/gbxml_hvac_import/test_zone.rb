require_relative 'minitest_helper'

class TestZone < MiniTest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = Config::GBXML_FILES + '/zone.xml'
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    self.model = translator.loadModel(self.gbxml_path).get
    self.model_manager = ModelManager.new(self.model, self.gbxml_path)
    self.model_manager.load_gbxml
  end

  def test_xml_creation
    equipment = self.model_manager.zones.values[0]
    xml_element = self.model_manager.gbxml_parser.zones[0]
    name = xml_element.elements['Name'].text
    id = xml_element.attributes['id']

    assert(equipment.name == name)
    assert(equipment.id == id)
  end

  def test_build
    self.model_manager.build
    zone = model_manager.zones.values[0].thermal_zone

    assert(zone.name.get == 'ZE2-25')
    assert(zone.additionalProperties.getFeatureAsString('id').get == 'aim19287')
  end
end
