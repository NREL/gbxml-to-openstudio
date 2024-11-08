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

  def test_build_ideal_air_loads
    model = OpenStudio::Model::Model.new
    expected_thermal_zone = OpenStudio::Model::ThermalZone.new(model)
    cad_object_id = "120948-1"
    expected_thermal_zone.additionalProperties.setFeature("CADObjectId", cad_object_id)

    zone = Zone.new
    model_manager.model = model
    zone.model = model
    zone.cad_object_id = "120948-1"
    zone.use_ideal_air_loads = true
    zone.build
    assert(zone.thermal_zone.useIdealAirLoads)
  end

  def test_set_ideal_air_loads_from_xml
    xml = <<EOF
  <Zone id="aim0956">
    <OAFlowPerPerson unit="CFM">15</OAFlowPerPerson>
    <DesignHeatT unit="F">70</DesignHeatT>
    <DesignCoolT unit="F">74</DesignCoolT>
    <Name>Zone Default</Name>
    <CADObjectId>81706</CADObjectId>
  </Zone>
EOF

    document = REXML::Document.new(xml).get_elements('Zone')[0]
    zone = Zone.create_from_xml(nil, document)
    assert(zone.use_ideal_air_loads)
  end
end
