require_relative 'minitest_helper'

class TestVRFCondenser < Minitest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    # self.gbxml_path = Config::GBXML_FILES + '/VRFAllVariations.xml'
    self.gbxml_path = Config::GBXML_FILES + '/VRFAllVariations703.xml'
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    self.model = translator.loadModel(self.gbxml_path).get
    self.model_manager = ModelManager.new(self.model, self.gbxml_path)
    self.model_manager.load_gbxml
    self.model_manager.resolve_references
    self.model_manager.resolve_read_relationships
  end

  def test_xml_creation
    equipment = self.model_manager.vrf_loops.values[0]
    xml_element = self.model_manager.gbxml_parser.vrf_loops[0]
    name = xml_element.elements['Name'].text
    id = xml_element.attributes['id']
    cad_object_id = xml_element.elements['CADObjectId'].text

    assert(equipment.name == name)
    assert(equipment.cad_object_id == cad_object_id)
    assert(equipment.id == id)
  end

  def test_build
    self.model_manager.build
    self.model_manager.post_build
    ac_vrf = self.model_manager.vrf_loops.values[0].condenser
    
    assert(ac_vrf.is_a?(OpenStudio::Model::AirConditionerVariableRefrigerantFlow))
    assert(ac_vrf.condenserType == "AirCooled")
    assert(ac_vrf.additionalProperties.getFeatureAsString('id').get == 'aim0956')
    assert(ac_vrf.additionalProperties.getFeatureAsString('CADObjectId').get == '280225')
    
    wc_vrf = self.model_manager.vrf_loops.values[1].condenser
    puts wc_vrf
    cw_loop = self.model_manager.vrf_loops.values[1].condenser_loop
    puts cw_loop.plant_loop
    assert(wc_vrf.is_a?(OpenStudio::Model::AirConditionerVariableRefrigerantFlow))
    assert(wc_vrf.condenserType == "WaterCooled")
    assert(wc_vrf.additionalProperties.getFeatureAsString('id').get == 'aim0958')
    assert(wc_vrf.additionalProperties.getFeatureAsString('CADObjectId').get == '280799')

  end

  def create_osw
    # osw = create_test_sizing_osw
    osw = create_test_annual_osw
    osw = adjust_gbxml_paths(osw, 'VRFAllVariations703.xml')
    osw_in_path = Config::TEST_OUTPUT_PATH + '/vrf_condenser/in.osw'
    osw.saveAs(osw_in_path)
  end

  def test_simulation
    create_osw
    # set osw_path to find location of osw to run
    osw_in_path = Config::TEST_OUTPUT_PATH + '/vrf_condenser/in.osw'
    cmd = "\"#{Config::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = Config::TEST_OUTPUT_PATH + '/vrf_condenser/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
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

#   def test_attach_condenser_loop
#     xml = <<EOF
#   <HydronicLoop loopType="CondenserWater" fluidType="Water" id="aim0933">
#     <Name>CW Loop</Name>
#     <CADObjectId>280798</CADObjectId>
#   </HydronicLoop>
#   <HydronicLoop loopType="VRFLoop" fluidType="Refrigerant" chillerType="WaterCooled" id="aim0934">
#     <Name>WC VRF</Name>
#     <CADObjectId>280799</CADObjectId>
#     <HydronicLoopId hydronicLoopIdRef="aim0933" hydronicLoopType="CondenserWater" />
#   </HydronicLoop>
# EOF

#     document = REXML::Document.new(xml)
#     xml_vrf_condenser = VRFCondenser.create_from_xml(self.model_manager, document.get_elements("HydronicLoop[@loopType='VRFLoop']")[0])

#     assert(xml_vrf_condenser.name == "WC VRF")
#     assert(xml_vrf_condenser.condenser_loop_ref == "aim0933")
#     assert(xml_vrf_condenser.cad_object_id == "280799")
#     assert(xml_vrf_condenser.id == "aim0934")
#   end
end