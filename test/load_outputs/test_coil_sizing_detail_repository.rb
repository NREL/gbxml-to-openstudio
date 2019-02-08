require 'openstudio'
require_relative '../gbxml_hvac_import/minitest_helper'
require_relative 'resources/coil_sizing_detail_params'
require_relative '../../measures/loads_output_report/resources/repositories/coil_sizing_detail_repository'

class TestCoilSizingDetailRepository < MiniTest::Test
  attr_accessor :sql_file, :repository

  def before_setup
    path = OpenStudio::Path.new(File.join(Config::TEST_RESOURCES + '/vav_box.sql'))
    self.sql_file = OpenStudio::SqlFile.new(path)
    @repository = CoilSizingDetailRepository.new(@sql_file)
  end

  def test_find_valid_name
    repo_coil = @repository.find_by_name('Air System Cooling Coil')

    puts repo_coil.inspect
    native_coil = CoilSizingDetail.new(COIL_1)
    puts native_coil.inspect

    assert(repo_coil == native_coil)
  end

  def test_find_invalid_name
    result = @repository.find_by_name('VAV BOX ELECTRIC-12345sdfgr')

    assert(result.nil?)
  end
end