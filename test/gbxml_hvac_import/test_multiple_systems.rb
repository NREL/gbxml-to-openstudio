require_relative 'minitest_helper'

class TestMultipleSystems < Minitest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    # self.gbxml_path = Config::GBXML_FILES + '/MultipleZoneHVAC.xml'
    self.gbxml_path = Config::GBXML_FILES + '/MultipleZoneAirSys.xml'
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    self.model = translator.loadModel(self.gbxml_path).get
    self.model_manager = ModelManager.new(self.model, self.gbxml_path)
    self.model_manager.load_gbxml
    self.model_manager.resolve_references
    self.model_manager.resolve_read_relationships
  end

  def test_build
    self.model_manager.build
    self.model_manager.connect
    self.model_manager.post_build
    zones = []
    self.model_manager.zones.values.each do |z|
      zones << z.thermal_zone
    end

    zones.each do |zone|
      puts zone 
      zone.equipment.each {|ze| puts ze}
      puts '----------------------------------------'
    end
  end
end 