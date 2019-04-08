require_relative 'minitest_helper'

class TestHelpers < MiniTest::Test

  def test_get_thermal_zone_by_cad_object_id
    model = OpenStudio::Model::Model.new
    expected_thermal_zone = OpenStudio::Model::ThermalZone.new(model)
    cad_object_id = "120948-1"
    expected_thermal_zone.additionalProperties.setFeature("CADObjectId", cad_object_id)

    retrieved_thermal_zone = Helpers.get_thermal_zone_by_cad_object_id(model, cad_object_id)
    assert(expected_thermal_zone == retrieved_thermal_zone)
  end
end