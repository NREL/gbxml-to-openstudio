require 'openstudio'
require_relative '../minitest_helper'
require_relative 'resources/coil_sizing_detail_params'

class TestPeakLoadComponentTable < MiniTest::Test
  attr_accessor :sql_file

  def before_setup
    path = OpenStudio::Path.new(File.join(TestConfig::TEST_RESOURCES + '/eplusout.sql'))
    self.sql_file = OpenStudio::SqlFile.new(path)
  end

  def test_get
    repository = PeakLoadComponentTableRepository.new(sql_file)
    repo_table = repository.get()
  end
end