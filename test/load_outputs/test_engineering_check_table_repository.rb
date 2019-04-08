require_relative 'minitest_helper'

class TestEngineeringCheckTableRepository < MiniTest::Test
  attr_accessor :sql_file, :repository

  def before_setup
    path = OpenStudio::Path.new(Config::RESOURCES + '/peak_load_component_repository.sql')
    sql_file = OpenStudio::SqlFile.new(path)
    @repository = EngineeringCheckTableRepository.new(sql_file)
  end

  def test_find_valid_name_zone_cooling
    repo_result = @repository.find_by_name_type_and_conditioning('ZONE EQUIPMENT 1-1', 'Cooling')

    params = {
        :oa_percent=>0.1825,
        :airflow_per_floor_area=>0.0042,
        :airflow_per_total_cap=>0.0001,
        :floor_area_per_total_cap=>0.0218,
        :total_cap_per_floor_area=>45.9216,
        :number_of_people=>10.0
    }

    expected_result = EngineeringCheckTable.new(params)

    assert(repo_result == expected_result)
  end

  def test_find_invalid_name_zone_cooling
    result = @repository.find_by_name_type_and_conditioning('VAV BOX ELECTRIC-12345sdfgr', 'Cooling')

    assert(result.nil?)
  end
end