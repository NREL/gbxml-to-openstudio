require 'openstudio'
require_relative '../gbxml_hvac_import/minitest_helper'
require_relative '../../measures/loads_output_report/resources/repositories/engineering_check_table_repository'

class TestEngineeringCheckTableRepository < MiniTest::Test
  attr_accessor :sql_file, :repository

  def before_setup
    path = OpenStudio::Path.new(File.join(Config::TEST_RESOURCES + '/vav_box.sql'))
    @sql_file = OpenStudio::SqlFile.new(path)
    @repository = EngineeringCheckTableRepository.new(@sql_file)
  end

  def test_find_valid_name_zone_cooling
    repo_result = @repository.find_by_name_type_and_conditioning('VAV BOX ELECTRIC-1', 'Zone', 'Cooling')

    params = {
        :oa_percent => 0.1981,
        :airflow_per_floor_area => 0.0073,
        :airflow_per_total_cap => 0.0001,
        :floor_area_per_total_cap => 0.0119,
        :total_cap_per_floor_area => 84.1066,
        :number_of_people => 81.4
    }

    native_result = EngineeringCheckTable.new(params)

    assert(repo_result == native_result)
  end

  def test_find_invalid_name_zone_cooling
    result = @repository.find_by_name_type_and_conditioning('VAV BOX ELECTRIC-12345sdfgr', 'Zone', 'Cooling')

    assert(result.nil?)
  end
end