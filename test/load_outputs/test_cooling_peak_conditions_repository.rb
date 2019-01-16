require 'openstudio'
require_relative '../minitest_helper'

class TestCoolingPeakConditionsRepository < MiniTest::Test
  attr_accessor :sql_file

  def before_setup
    path = OpenStudio::Path.new(File.join(TestConfig::TEST_RESOURCES + '/eplusout.sql'))
    self.sql_file = OpenStudio::SqlFile.new(path)
  end

  def test_get
    repository = PeakConditionTableRepository.new(sql_file)
    repo_coil = repository.get('COIL COOLING DX SINGLE SPEED 1')

    native_coil = CoilSizingDetail.new(get_coil_params)

    assert(repo_coil == native_coil)
  end
end