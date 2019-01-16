require 'openstudio'
require_relative '../minitest_helper'
require_relative 'resources/coil_sizing_detail_params'

class TestCoilSizingDetailRepository < MiniTest::Test
  attr_accessor :sql_file

  def before_setup
    path = OpenStudio::Path.new(File.join(TestConfig::TEST_RESOURCES + '/eplusout.sql'))
    self.sql_file = OpenStudio::SqlFile.new(path)
  end

  def test_get
    repository = CoilSizingDetailRepository.new(sql_file)
    repo_coil = repository.get('COIL COOLING DX SINGLE SPEED 1')

    native_coil = CoilSizingDetail.new(COIL_1)
    puts native_coil.inspect
    puts repo_coil.inspect

    assert(repo_coil == native_coil)
  end

  def test_get_all
    repository = CoilSizingDetailRepository.new(sql_file)
    coils = repository.get_all

    assert(coils.length == 5)
  end

  def test_get_by_idd_type
    repository = CoilSizingDetailRepository.new(sql_file)

    coils = repository.get_by_idd_type('Coil:Heating:Electric')

    puts coils.length
    assert(coils.length == 3)
  end
end