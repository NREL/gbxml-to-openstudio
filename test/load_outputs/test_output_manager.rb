require_relative 'minitest_helper'

class TestOutputManager < MiniTest::Test
  attr_accessor :model, :sql_file, :output_manager

  def before_setup
    path = OpenStudio::Path.new(File.join(Config::RESOURCES + '/peak_load_component_repository.sql'))
    self.sql_file = OpenStudio::SqlFile.new(path)
    self.model = OpenStudio::Model::Model.load(OpenStudio::Path.new(File.join(Config::RESOURCES + '/peak_load_component_repository.osm'))).get
    @output_manager = OutputManager.new(@model, @sql_file)
  end

  def test_hydrate
    @output_manager.hydrate
    puts output_manager.to_json
  end

  def test_find_cooling_coil_by_features
    output_manager = OutputManager.new(@model, @sql_file)
    coil = OpenStudio::Model::CoilCoolingDXSingleSpeed.new(model)
    coil.additionalProperties.setFeature("system_cad_object_id", "280629")

    retrieved_coil = output_manager.find_cooling_coil_by_features(
                      {"system_cad_object_id": "280629"}
    )

    assert(coil == retrieved_coil)
  end

  def test_find_cooling_coil_by_features_wrong
    output_manager = OutputManager.new(@model, @sql_file)

    retrieved_coil = output_manager.find_cooling_coil_by_features(
        {"system_cad_object_id": "asdf235f3d"}
    )

    assert(retrieved_coil.nil?)
  end

  def test_find_heating_coil_by_features
    output_manager = OutputManager.new(@model, @sql_file)
    coil = OpenStudio::Model::CoilHeatingGas.new(model)
    coil.additionalProperties.setFeature("system_cad_object_id", "280628")

    retrieved_coil = output_manager.find_heating_coil_by_features(
        {"system_cad_object_id": "280628"}
    )

    assert(coil == retrieved_coil)
  end

  def test_find_heating_coil_by_features_wrong
    output_manager = OutputManager.new(@model, @sql_file)

    retrieved_coil = output_manager.find_heating_coil_by_features(
        {"system_cad_object_id": "asjon208nsh"}
    )

    assert(retrieved_coil.nil?)
  end
end