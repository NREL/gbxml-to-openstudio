require_relative 'minitest_helper'

class TestZoneSensibleSummaryRepository < MiniTest::Test
  attr_accessor :sql_file, :repository

  def before_setup
    path = OpenStudio::Path.new(Config::RESOURCES + '/peak_load_component_repository.sql')
    @sql_file = OpenStudio::SqlFile.new(path)
    @repository = ZoneSensibleSummaryRepository.new(@sql_file)
  end

  def test_find_valid_name_zone_cooling
    repo_result = @repository.find_by_name_and_conditioning('ZONE EQUIPMENT 1-1', 'Cooling')

    params = {
        "calculated_design_load":11350.21,
        "user_design_load": 13052.74,
        "user_design_load_per_area": 45.92,
        "calculated_design_air_flow": 1.208,
        "user_design_air_flow": 1.389,
        "design_day_name": "DENVER INTL AP ANN CLG .4% CONDNS DB=>MWB",
        "date_time_of_peak": "7/21 17:00:00",
        "thermostat_setpoint_temperature_at_peak_load": 23.33,
        "indoor_temperature_at_peak_load": 23.33,
        "indoor_humidity_ratio_at_peak_load": 0.00845,
        "outdoor_temperature_at_peak_load": 32.47,
        "outdoor_humidity_ratio_at_peak_load": 0.00591,
        "minimum_outdoor_air_flow_rate": 0.22,
        "heat_gain_rate_from_doas": 0.0
    }

    expected_result = ZoneSensibleSummary.from_options(params)

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
ReportName == 'HVACSizingSummary' AND TableName == 'Zone Sensible Cooling' AND UPPER(RowName) == 'ZONE EQUIPMENT 1-1'").get
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