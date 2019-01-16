require 'openstudio'
require_relative '../minitest_helper'
require_relative '../../measures/loads_output_report/resources/output_manager'

class TestOutputManager < MiniTest::Test
  attr_accessor :model, :sql_file

  def before_setup
    path = OpenStudio::Path.new(File.join(TestConfig::TEST_RESOURCES + '/vav_box.sql'))
    self.sql_file = OpenStudio::SqlFile.new(path)
    self.model = OpenStudio::Model::Model.load(OpenStudio::Path.new(File.join(TestConfig::TEST_RESOURCES + '/vav_box.osm'))).get
  end

  def test_output_manager_hydrate
    output_manager = OutputManager.new(@model, @sql_file)
    output_manager.hydrate
    puts output_manager.inspect
  end
end