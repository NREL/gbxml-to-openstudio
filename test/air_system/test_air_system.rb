require_relative '../minitest_helper'

class TestAirSystem < Minitest::Test
  attr_accessor :model, :model_manager, :gbxml_path

  def before_setup
    self.gbxml_path = TestConfig::GBXML_FILES + '/AirSystemAllVariations.xml'
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    self.model = translator.loadModel(self.gbxml_path).get
    self.model_manager = ModelManager.new(self.model, self.gbxml_path)
    self.model_manager.load_gbxml
  end

  def test_air_system_xml_creation
    equipment = self.model_manager.air_systems.values[0]
    xml_element = self.model_manager.gbxml_parser.air_systems[0]
    name = xml_element.elements['Name'].text
    id = xml_element.attributes['id']
    cad_object_id = xml_element.elements['CADObjectId'].text

    assert(equipment.name == name)
    assert(equipment.cad_object_id == cad_object_id)
    assert(equipment.id == id)
  end

  def test_air_system_build
    self.model_manager.build
    all_none = self.model_manager.air_systems.values[0].air_loop_hvac
    enth_elec_ac_dx_elec_var = self.model_manager.air_systems.values[1].air_loop_hvac
    sens_furn_wc_dx_furn_var = self.model_manager.air_systems.values[2].air_loop_hvac
    none_hw_chw_hw_vav = self.model_manager.air_systems.values[3].air_loop_hvac

    # Should have OAsys and supply fan
    assert(all_none.airLoopHVACOutdoorAirSystem.is_initialized)
    optional_hx = all_none.airLoopHVACOutdoorAirSystem.get.reliefAirModelObject.get.to_Node.get.outletModelObject
    assert(!optional_hx.is_initialized)
    mixed_air_node = all_none.airLoopHVACOutdoorAirSystem.get.mixedAirModelObject.get.to_Node.get
    fan = mixed_air_node.outletModelObject.get.to_FanVariableVolume
    assert(fan.is_initialized)
    assert(fan.get.outletModelObject.get == all_none.supplyOutletNode)

    # Should have OAsys, HX, elec preheat, AC DX, elec heating, vav
    assert(enth_elec_ac_dx_elec_var.airLoopHVACOutdoorAirSystem.is_initialized)
    optional_hx = enth_elec_ac_dx_elec_var.airLoopHVACOutdoorAirSystem.get.reliefAirModelObject.get.to_Node.get.outletModelObject.get.to_HeatExchangerAirToAirSensibleAndLatent
    assert(optional_hx.is_initialized)
    mixed_air_node = enth_elec_ac_dx_elec_var.airLoopHVACOutdoorAirSystem.get.mixedAirModelObject.get.to_Node.get
    preheat_coil = mixed_air_node.outletModelObject.get.to_CoilHeatingElectric
    assert(preheat_coil.is_initialized)
    cooling_coil = preheat_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_CoilCoolingDXSingleSpeed
    assert(cooling_coil.is_initialized)
    heating_coil = cooling_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_CoilHeatingElectric
    assert(heating_coil.is_initialized)
    fan = heating_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_FanVariableVolume
    assert(fan.is_initialized)

    assert(enth_elec_ac_dx_elec_var.airLoopHVACOutdoorAirSystem.is_initialized)
    optional_hx = enth_elec_ac_dx_elec_var.airLoopHVACOutdoorAirSystem.get.reliefAirModelObject.get.to_Node.get.outletModelObject.get.to_HeatExchangerAirToAirSensibleAndLatent
    assert(optional_hx.is_initialized)
    mixed_air_node = enth_elec_ac_dx_elec_var.airLoopHVACOutdoorAirSystem.get.mixedAirModelObject.get.to_Node.get
    preheat_coil = mixed_air_node.outletModelObject.get.to_CoilHeatingElectric
    assert(preheat_coil.is_initialized)
    cooling_coil = preheat_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_CoilCoolingDXSingleSpeed
    assert(cooling_coil.is_initialized)
    heating_coil = cooling_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_CoilHeatingElectric
    assert(heating_coil.is_initialized)
    fan = heating_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_FanVariableVolume
    assert(fan.is_initialized)

    assert(sens_furn_wc_dx_furn_var.airLoopHVACOutdoorAirSystem.is_initialized)
    optional_hx = sens_furn_wc_dx_furn_var.airLoopHVACOutdoorAirSystem.get.reliefAirModelObject.get.to_Node.get.outletModelObject.get.to_HeatExchangerAirToAirSensibleAndLatent
    assert(optional_hx.is_initialized)
    mixed_air_node = sens_furn_wc_dx_furn_var.airLoopHVACOutdoorAirSystem.get.mixedAirModelObject.get.to_Node.get
    preheat_coil = mixed_air_node.outletModelObject.get.to_CoilHeatingGas
    assert(preheat_coil.is_initialized)
    cooling_coil = preheat_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_CoilCoolingDXSingleSpeed
    assert(cooling_coil.is_initialized)
    heating_coil = cooling_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_CoilHeatingGas
    assert(heating_coil.is_initialized)
    fan = heating_coil.get.outletModelObject.get.to_Node.get.outletModelObject.get.to_FanVariableVolume
    assert(fan.is_initialized)

    assert(none_hw_chw_hw_vav.airLoopHVACOutdoorAirSystem.is_initialized)
    optional_hx = none_hw_chw_hw_vav.airLoopHVACOutdoorAirSystem.get.reliefAirModelObject.get.to_Node.get.outletModelObject
    assert(!optional_hx.is_initialized)
    mixed_air_node = none_hw_chw_hw_vav.airLoopHVACOutdoorAirSystem.get.mixedAirModelObject.get.to_Node.get
    preheat_coil = mixed_air_node.outletModelObject.get.to_CoilHeatingWater
    assert(preheat_coil.is_initialized)
    cooling_coil = preheat_coil.get.airOutletModelObject.get.to_Node.get.outletModelObject.get.to_CoilCoolingWater
    assert(cooling_coil.is_initialized)
    heating_coil = cooling_coil.get.airOutletModelObject.get.to_Node.get.outletModelObject.get.to_CoilHeatingWater
    assert(heating_coil.is_initialized)
    fan = heating_coil.get.airOutletModelObject.get.to_Node.get.outletModelObject.get.to_FanConstantVolume
    assert(fan.is_initialized)
  end

  def test_simulation
    # set osw_path to find location of osw to run
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/air_system/in.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" run -w \"#{osw_in_path}\""
    system(cmd)

    osw_out_path = TestConfig::TEST_OUTPUT_PATH + '/air_system/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end
end