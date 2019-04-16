require_relative 'minitest_helper'

class TestPeakLoadComponentRepository < MiniTest::Test
  attr_accessor :repository

  def before_setup
    path = OpenStudio::Path.new(File.join(Config::RESOURCES + '/peak_load_component_repository.sql'))
    sql_file = OpenStudio::SqlFile.new(path)
    @repository = PeakLoadComponentRepository.new(sql_file)
  end

  def test_find_valid_peak_load_by_name_type_conditioning_component
    repo_result = @repository.find('ZONE EQUIPMENT 1-1', 'Cooling', 'People')

    params = {
        :sensible_instant=>494.06,
        :sensible_delayed=>338.07,
        :sensible_return_air=>0.0,
        :latent=>547.08, :total=>1379.21,
        :percent_grand_total=>12.33,
        :related_area=>284.24,
        :total_per_area=>4.85
    }

    expected_result = PeakLoadComponent.new(params)
    assert(expected_result == repo_result)
  end

  def test_find_invalid_peak_load_by_name_type_conditioning_component
    repo_result = @repository.find('ZONE EQUIPMENT asdnoeer', 'Cooling', 'People')

    puts repo_result
    assert(repo_result.nil?)
  end
end