require 'openstudio'
require_relative '../minitest_helper'
require_relative '../../measures/loads_output_report/resources/repositories/peak_condition_table_repository'

class TestPeakConditionTableRepository < MiniTest::Test
  attr_accessor :sql_file, :repository

  def before_setup
    path = OpenStudio::Path.new(File.join(TestConfig::TEST_RESOURCES + '/vav_box.sql'))
    @sql_file = OpenStudio::SqlFile.new(path)
    @repository = PeakConditionTableRepository.new(@sql_file)
  end

  def test_find_valid_name_zone_cooling
    repo_result = @repository.find_by_name_type_and_conditioning('VAV BOX ELECTRIC-1', 'Zone', 'Cooling')

    params = {
        :time_of_peak_load => "7/21 11:00:00",
        :oa_drybulb => 31.1,
        :oa_wetbulb => 16.64,
        :oa_hr => 0.00591,
        :zone_drybulb => 23.89,
        :zone_rh => 47.02,
        :zone_hr => 0.00868,
        :sat => 14.0,
        :mat => 0.0,
        :fan_flow => 1.23,
        :oa_flow => 0.24,
        :sensible_peak_sf => 14049.14,
        :sf_diff => 1832.5,
        :sensible_peak => 12216.64,
        :estimate_instant_delayed_sensible => 12220.61,
        :peak_estimate_diff => -4.0
    }

    native_result = PeakConditionTable.new(params)

    assert(repo_result == native_result)
  end

  def test_find_invalid_name_zone_cooling
    result = @repository.find_by_name_type_and_conditioning('VAV BOX ELECTRIC-12345sdfgr', 'Zone', 'Cooling')

    assert(result.nil?)
  end
end