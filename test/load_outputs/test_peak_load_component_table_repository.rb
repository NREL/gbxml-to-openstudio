require_relative 'minitest_helper'
require_relative 'resources/zone_peak_load_component_table'

class TestPeakLoadComponentTableRepository < MiniTest::Test
  attr_accessor :sql_file, :repository

  def before_setup
    path = OpenStudio::Path.new(File.join(Config::RESOURCES + '/peak_load_component_repository.sql'))
    sql_file = OpenStudio::SqlFile.new(path)
    @repository = PeakLoadComponentTableRepository.new(sql_file)
  end

  def test_find_valid_name_zone_cooling
    repo_result = @repository.find_by_name_type_and_conditioning('ZONE EQUIPMENT 1-1', 'Cooling')

    params = {}
    PeakLoadComponentTableRepository::ROW_PARAM_MAP.each do |param|
      params[param[:param_name].to_sym] = PeakLoadComponent.new(PEAK_LOAD_COMPONENT_TABLE[param[:param_name].to_sym])
    end

    native_result = PeakLoadComponentTable.new(params)
    # puts JSON.dump(repo_result.to_hash)

    assert(repo_result.to_hash == native_result.to_hash)
  end

  def test_find_invalid_name_zone_cooling
    result = @repository.find_by_name_type_and_conditioning('VAV BOX ELECTRIC-12345sdfgr', 'Cooling')

    assert(result.nil?)
  end
end