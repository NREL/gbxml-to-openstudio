require 'openstudio'
require_relative '../minitest_helper'
require_relative '../../measures/loads_output_report/resources/repositories/peak_load_component_repository'
require_relative 'resources/zone_peak_load_components'

class TestPeakLoadComponentRepository < MiniTest::Test
  attr_accessor :sql_file

  def before_setup
    path = OpenStudio::Path.new(File.join(TestConfig::TEST_RESOURCES + '/eplusout.sql'))
    self.sql_file = OpenStudio::SqlFile.new(path)
  end

  def test_get_zone_cooling_people
    repository = PeakLoadComponentRepository.new(sql_file)
    repo_peak_component = repository.get_zone_cooling('VAV BOX ELECTRIC-1', 'People')

    native_peak_component = PeakLoadComponent.new(PEOPLE)
    assert(repo_peak_component == native_peak_component)
  end
end