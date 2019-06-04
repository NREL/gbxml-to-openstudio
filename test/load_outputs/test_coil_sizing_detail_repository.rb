require_relative 'minitest_helper'
require_relative 'resources/coil_sizing_detail_params'

class TestCoilSizingDetailRepository < MiniTest::Test
  attr_accessor :sql_file, :repository

  def before_setup
    path = OpenStudio::Path.new(Config::RESOURCES + '/peak_load_component_repository.sql')
    sql_file = OpenStudio::SqlFile.new(path)
    @repository = CoilSizingDetailRepository.new(sql_file)
  end

  def test_find_valid_name
    repo_coil = @repository.find_by_name('ZONE EQUIPMENT 1-1 HEATING COIL')

    expected_coil = CoilSizingDetail.new(COIL_1)

    assert(repo_coil == expected_coil)
  end

  def test_find_invalid_name
    result = @repository.find_by_name('VAV BOX ELECTRIC-12345sdfgr')

    assert(result.nil?)
  end

  def test_speed
    path = OpenStudio::Path.new(Config::RESOURCES + '/peak_load_component_repository.sql')
    sql_file = OpenStudio::SqlFile.new(path)
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    (0..1000).each {|i| sql_file.execAndReturnVectorOfString("SELECT Value FROM TabularDataWithStrings WHERE ReportName
== 'CoilSizingDetails' AND UPPER(RowName) == 'ZONE EQUIPMENT 1-1 HEATING COIL'").get}

    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = ending - starting
    puts elapsed

    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    (0..1000).each { |i| @repository.find_by_name('ZONE EQUIPMENT 1-1 HEATING COIL')}

    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = ending - starting
    puts elapsed

    puts @repository.find_by_name('ZONE EQUIPMENT 1-1 HEATING COIL').to_hash
  end
end