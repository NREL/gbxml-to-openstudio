require 'openstudio'
require_relative '../gbxml_hvac_import/minitest_helper'
require_relative '../../measures/loads_output_report/resources/repositories/peak_condition_table_repository'

class TestPeakConditionTableRepository < MiniTest::Test
  attr_accessor :sql_file, :repository

  def before_setup
    path = OpenStudio::Path.new(File.join(Config::TEST_RESOURCES + '/vav_box.sql'))
    @sql_file = OpenStudio::SqlFile.new(path)
    @repository = PeakConditionTableRepository.new(@sql_file)
  end

  def test_find_valid_name_zone_cooling
    repo_result = @repository.find_by_name_type_and_conditioning('VAV Box Electric-1', 'Zone', 'Cooling')

    params = {
        :time_of_peak_load => "7/21 11:00:00",
        :oa_drybulb => 31.1,
        :oa_wetbulb => 16.64,
        :oa_hr => 0.00591,
        :zone_drybulb => 23.89,
        :zone_rh => 46.78,
        :zone_hr => 0.00863,
        :sat => 14.0,
        :mat => 0.0,
        :fan_flow => 1.39,
        :oa_flow => 0.63,
        :sensible_peak_sf => 15965.68,
        :sf_diff => 2082.48,
        :sensible_peak => 13883.2,
        :estimate_instant_delayed_sensible => 13886.61,
        :peak_estimate_diff => -3.4
    }

    native_result = PeakConditionTable.new(params)

    assert(repo_result == native_result)
  end

  def test_find_invalid_name_zone_cooling
    result = @repository.find_by_name_type_and_conditioning('VAV BOX ELECTRIC-12345sdfgr', 'Zone', 'Cooling')

    assert(result.nil?)
  end
end