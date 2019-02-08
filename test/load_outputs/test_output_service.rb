require 'openstudio'
require_relative '../gbxml_hvac_import/minitest_helper'
require_relative '../../measures/loads_output_report/resources/output_service'
require_relative 'resources/coil_sizing_detail_params'

class TestOutputService < MiniTest::Test
  attr_accessor :model, :sql_file

  def before_setup
    path = OpenStudio::Path.new(File.join(Config::TEST_RESOURCES + '/vav_box.sql'))
    self.sql_file = OpenStudio::SqlFile.new(path)
    self.model = OpenStudio::Model::Model.load(OpenStudio::Path.new(File.join(Config::TEST_RESOURCES + '/vav_box.osm'))).get
  end

  def test_get_zone_loads_by_component_name
    output_service = OutputService.new(@sql_file)

    name = model.getThermalZones()[0].name.get

    zone_loads_by_component = output_service.get_zone_loads_by_component(name)

    require_relative 'resources/zone_loads_by_component'
    assert(JSON.dump(zone_loads_by_component.to_hash) == JSON.dump(ZONE_LOADS_BY_COMPONENT))
  end

  def test_get_zone_loads_by_component_invalid_name
    output_service = OutputService.new(@sql_file)

    name = "invalid_n@me"

    zone_loads_by_component = output_service.get_zone_loads_by_component(name)
    assert(zone_loads_by_component.nil?)
  end

  def test_get_system_checksum_by_name
    output_service = OutputService.new(@sql_file)
    name = 'AIR SYSTEM'
    cooling_coil_name = 'COIL COOLING DX SINGLE SPEED 1'
    heating_coil_name = 'COIL HEATING WATER 1'

    system_checksum = output_service.get_system_checksum(name, cooling_coil_name, heating_coil_name)

    require_relative 'resources/system_checksum'
    assert(JSON.dump(system_checksum.to_hash) == JSON.dump(SYSTEM_CHECKSUM))
  end

  def test_get_system_checksum_invalid_name
    output_service = OutputService.new(@sql_file)
    name = 'AiR Syst3m'

    system_checksum = output_service.get_system_checksum(name, cooling_coil_name, heating_coil_name)

    assert(system_checksum.nil?)
  end

  def test_get_system_checksum_invalid_cooling_coil_name
    output_service = OutputService.new(@sql_file)
    name = 'AIR SYSTEM'
    cooling_coil_name = 'C00IL C00LING DX S1NGLE SP33D 42'

    system_checksum = output_service.get_system_checksum(name, cooling_coil_name)

    assert(system_checksum.cooling_coil_sizing_detail.nil?)
    assert(system_checksum.cooling_peak_load_component_table.ventilation.nil?)
    assert(system_checksum.cooling_peak_load_component_table.supply_fan_heat.nil?)
  end

  def test_get_system_checksum_invalid_heating_coil_name
    output_service = OutputService.new(@sql_file)
    name = 'AIR SYSTEM'
    heating_coil_name = 'C01l H34TING WATER 42'

    system_checksum = output_service.get_system_checksum(name, nil, heating_coil_name)

    assert(system_checksum.heating_coil_sizing_detail.nil?)
    assert(system_checksum.heating_peak_load_component_table.ventilation.nil?)
    assert(system_checksum.heating_peak_load_component_table.supply_fan_heat.nil?)
  end

  def test_get_facility_component_load_summary
    output_service = OutputService.new(@sql_file)
    facility_component_load_summary = output_service.get_facility_component_load_summary

    require_relative 'resources/facility_component_load_summary'
    assert(JSON.dump(facility_component_load_summary.to_hash) == JSON.dump(FACILITY))
  end

  def test_get_design_psychrometric
    output_service = OutputService.new(@sql_file)
    repo_design_psychrometric = output_service.get_design_psychrometric('COIL COOLING DX SINGLE SPEED 1')

    native_design_psychrometric = DesignPsychrometric.new(CoilSizingDetail.new(COIL_1))

    assert(repo_design_psychrometric == native_design_psychrometric)
  end

  def test_get_design_psychrometric_bad_name
    output_service = OutputService.new(@sql_file)
    design_psychrometric = output_service.get_design_psychrometric('COIL COOLING DX SINGLE SPEED 2')

    assert(design_psychrometric.nil?)
  end
end