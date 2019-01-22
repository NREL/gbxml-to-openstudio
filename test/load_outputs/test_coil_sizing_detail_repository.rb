require 'openstudio'
require_relative '../minitest_helper'
require_relative 'resources/coil_sizing_detail_params'
require_relative '../../measures/loads_output_report/resources/repositories/coil_sizing_detail_repository'

class TestCoilSizingDetailRepository < MiniTest::Test
  attr_accessor :sql_file, :repository

  def before_setup
    path = OpenStudio::Path.new(File.join(TestConfig::TEST_RESOURCES + '/vav_box.sql'))
    self.sql_file = OpenStudio::SqlFile.new(path)
    @repository = CoilSizingDetailRepository.new(@sql_file)
  end

  def test_find_valid_name
    repo_coil = @repository.find_by_name('COIL COOLING DX SINGLE SPEED 1')

    native_coil = CoilSizingDetail.new(COIL_1)

    puts repo_coil.to_hash
    puts native_coil.to_hash

    assert(repo_coil == native_coil)
  end

  def test_find_invalid_name
    result = @repository.find_by_name('VAV BOX ELECTRIC-12345sdfgr')

    assert(result.nil?)
  end
end