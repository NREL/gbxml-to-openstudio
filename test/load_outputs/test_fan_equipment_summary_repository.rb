require_relative 'minitest_helper'
require_relative 'resources/fan_equipment_summary_params'

class TestFanEquipmentSummaryRepository < MiniTest::Test
  attr_accessor :sql_file, :repository

  def before_setup
    path = OpenStudio::Path.new(Config::RESOURCES + '/peak_load_component_repository.sql')
    sql_file = OpenStudio::SqlFile.new(path)
    @repository = FanEquipmentSummaryRepository.new(sql_file)
  end

  def test_find_valid_name
    repo_fan = @repository.find_by_name('AIR SYSTEM SUPPLY FAN')

    expected_fan = FanEquipmentSummary.from_options(FAN)
    puts JSON.dump(repo_fan.to_hash)
    puts JSON.dump(expected_fan.to_hash)

    assert(repo_fan == expected_fan)
  end

  def test_find_invalid_name
    result = @repository.find_by_name('VAV BOX ELECTRIC-12345sdfgr')

    assert(result.nil?)
  end
end