require_relative '../minitest_helper'

class TestSpaceMapper < MiniTest::Test

  include Mappers

  def test_update_infiltration
    model = OpenStudio::Model::Model.new
    os_space = OpenStudio::Model::Space.new(model)
    gbxml_space = GBXML::Space.new
    gbxml_space.infiltration_flow_per_area = 0.2

    space_mapper = Space.new(model)
    space_mapper.update_infiltration(gbxml_space, os_space)

    assert(gbxml_space.infiltration_flow_per_area == os_space.spaceInfiltrationDesignFlowRates[0].designFlowRate.get)
  end

  def test_update_lighting
    model = OpenStudio::Model::Model.new
    os_space = OpenStudio::Model::Space.new(model)
    gbxml_space = GBXML::Space.new
    gbxml_space.light_power_per_area = 0.5

    space_mapper = Space.new(model)
    space_mapper.update_lighting(gbxml_space, os_space)

    assert(gbxml_space.light_power_per_area == os_space.lightingPowerPerFloorArea)
  end

  def test_update_equipment
    model = OpenStudio::Model::Model.new
    os_space = OpenStudio::Model::Space.new(model)
    gbxml_space = GBXML::Space.new
    gbxml_space.equip_power_per_area = 0.7

    space_mapper = Space.new(model)
    space_mapper.update_equipment(gbxml_space, os_space)

    assert(gbxml_space.equip_power_per_area == os_space.electricEquipmentPowerPerFloorArea)
  end

  def test_update_ventilation
    model = OpenStudio::Model::Model.new
    os_space = OpenStudio::Model::Space.new(model)
    gbxml_space = GBXML::Space.new
    gbxml_space.air_changes_per_hour = 0.7
    gbxml_space.oa_flow_per_area = 0.6
    gbxml_space.oa_flow_per_person = 0.5
    gbxml_space.oa_flow_per_space = 0.4

    space_mapper = Space.new(model)
    space_mapper.update_ventilation(gbxml_space, os_space)

    design_specification_outdoor_air = os_space.designSpecificationOutdoorAir.get
    assert(gbxml_space.air_changes_per_hour == design_specification_outdoor_air.outdoorAirFlowAirChangesperHour)
    assert(gbxml_space.oa_flow_per_area == design_specification_outdoor_air.outdoorAirFlowperFloorArea)
    assert(gbxml_space.oa_flow_per_person == design_specification_outdoor_air.outdoorAirFlowperPerson)
    assert(gbxml_space.oa_flow_per_space == design_specification_outdoor_air.outdoorAirFlowRate)

  end

  def test_calculate_sensible_heat_fraction
    assert(Space.calculate_sensible_heat_fraction(2.0, 1.0, 0) == 0.5)
    assert(Space.calculate_sensible_heat_fraction(nil, 1.0, 1.0) == 0.5)
    assert(Space.calculate_sensible_heat_fraction(2.0, nil, 1.0) == 0.5)
    assert(Space.calculate_sensible_heat_fraction(nil, nil, 1.0) == nil)
  end
end