require 'minitest/autorun'
require 'minitest/assertions'
require 'minitest/reporters'
require_relative 'minitest_helper'

# TODO: Recreate a better test
class TestGbxmlParser < MiniTest::Test
  def test_gbxml_parsing
    gbxml_path = File.expand_path(File.join(File.dirname(__FILE__), '../../gbxmls/Analytical Systems 01.xml'))
    gbxml_parser = GBXMLParser.new(gbxml_path)
    hw_loops_count = gbxml_parser.hw_loops.count
    chw_loops_count = gbxml_parser.chw_loops.count
    cw_loops_count = gbxml_parser.cw_loops.count
    air_systems_count = gbxml_parser.air_systems.count
    zone_hvac_equipments_count = gbxml_parser.zone_hvac_equipments.count
    zones_count = gbxml_parser.zones.count

    assert(hw_loops_count == 1)
    assert(chw_loops_count == 1)
    assert(cw_loops_count == 1)
    assert(air_systems_count == 3)
    assert(zone_hvac_equipments_count == 4)
    assert(zones_count == 2)

  end
end