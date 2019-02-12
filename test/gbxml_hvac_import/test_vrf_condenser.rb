require_relative 'minitest_helper'

class TestVRFCondenser < MiniTest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = Config::GBXML_FILES + '/VRFAllVariations.xml'
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    self.model = translator.loadModel(self.gbxml_path).get
    self.model_manager = ModelManager.new(self.model, self.gbxml_path)
    self.model_manager.load_gbxml
    self.model_manager.resolve_read_relationships
  end

  def test_create_from_xml_air_cooled
    xml = <<EOF
  <HydronicLoop loopType="VRFLoop" fluidType="Refrigerant" chillerType="AirCooled" id="aim0932">
    <Name>AC VRF</Name>
    <CADObjectId>280225</CADObjectId>
  </HydronicLoop>
EOF

    document = REXML::Document.new(xml)
    xml_vrf_condenser = VRFCondenser.create_from_xml(self.model_manager, document.get_elements("HydronicLoop[@loopType='VRFLoop']")[0])

    assert(xml_vrf_condenser.name == "AC VRF")
    assert(xml_vrf_condenser.cad_object_id == "280225")
    assert(xml_vrf_condenser.id == "aim0932")
  end

  def test_create_from_xml_water_cooled
    xml = <<EOF
  <HydronicLoop loopType="VRFLoop" fluidType="Refrigerant" chillerType="WaterCooled" id="aim0934">
    <Name>WC VRF</Name>
    <CADObjectId>280799</CADObjectId>
    <HydronicLoopId hydronicLoopIdRef="aim0933" hydronicLoopType="CondenserWater" />
  </HydronicLoop>
EOF

    document = REXML::Document.new(xml)
    xml_vrf_condenser = VRFCondenser.create_from_xml(self.model_manager, document.get_elements("HydronicLoop[@loopType='VRFLoop']")[0])

    assert(xml_vrf_condenser.name == "WC VRF")
    assert(xml_vrf_condenser.condenser_loop_ref == "aim0933")
    assert(xml_vrf_condenser.cad_object_id == "280799")
    assert(xml_vrf_condenser.id == "aim0934")
  end

  def test_attach_condenser_loop
    xml = <<EOF
  <HydronicLoop loopType="CondenserWater" fluidType="Water" id="aim0933">
    <Name>CW Loop</Name>
    <CADObjectId>280798</CADObjectId>
  </HydronicLoop>
  <HydronicLoop loopType="VRFLoop" fluidType="Refrigerant" chillerType="WaterCooled" id="aim0934">
    <Name>WC VRF</Name>
    <CADObjectId>280799</CADObjectId>
    <HydronicLoopId hydronicLoopIdRef="aim0933" hydronicLoopType="CondenserWater" />
  </HydronicLoop>
EOF

    document = REXML::Document.new(xml)
    xml_vrf_condenser = VRFCondenser.create_from_xml(self.model_manager, document.get_elements("HydronicLoop[@loopType='VRFLoop']")[0])

    assert(xml_vrf_condenser.name == "WC VRF")
    assert(xml_vrf_condenser.condenser_loop_ref == "aim0933")
    assert(xml_vrf_condenser.cad_object_id == "280799")
    assert(xml_vrf_condenser.id == "aim0934")
  end
end