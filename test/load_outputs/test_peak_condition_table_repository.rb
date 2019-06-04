require_relative 'minitest_helper'

class TestPeakConditionTableRepository < MiniTest::Test
  attr_accessor :sql_file, :repository

  def before_setup
    path = OpenStudio::Path.new(Config::RESOURCES + '/peak_load_component_repository.sql')
    @sql_file = OpenStudio::SqlFile.new(path)
    @repository = PeakConditionTableRepository.new(@sql_file)
  end

  def test_find_valid_name_zone_cooling
    repo_result = @repository.find_by_name_and_conditioning('ZONE EQUIPMENT 1-1', 'Cooling')

    params = {
        "time_of_peak_load": "7/21 17:00:00",
        "oa_drybulb": 32.47,
        "oa_wetbulb": 17.11,
        "oa_hr": 0.00591,
        "zone_drybulb": 23.33,
        "zone_rh": 47.34,
        "zone_hr": 0.00845,
        "sat": 14.0,
        "mat": 0.0,
        "fan_flow": 1.21,
        "oa_flow": 0.22,
        "sensible_peak_sf": 13052.74,
        "sf_diff": 1702.53,
        "sensible_peak": 11350.21,
        "estimate_instant_delayed_sensible": 11349.12,
        "peak_estimate_diff": 1.09
    }

    expected_result = PeakConditionTable.new(params)

    assert(repo_result == expected_result)
  end

  def test_find_invalid_name_zone_cooling
    result = @repository.find_by_name_and_conditioning('VAV BOX ELECTRIC-12345sdfgr', 'Cooling')

    assert(result.nil?)
  end

  def test_speed
    path = OpenStudio::Path.new(Config::RESOURCES + '/peak_load_component_repository.sql')
    sql_file = OpenStudio::SqlFile.new(path)
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    (0..100).each do |i| sql_file.execAndReturnVectorOfString("SELECT Value FROM TabularDataWithStrings WHERE
TableName = 'Cooling Peak Conditions' AND UPPER(ReportForString) = 'ZONE EQUIPMENT 1-1'").get
    end

    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = ending - starting
    puts elapsed

    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    (0..100).each { |i| @repository.find_by_name_and_conditioning('ZONE EQUIPMENT 1-1', 'Cooling')}

    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = ending - starting
    puts elapsed

  end
end