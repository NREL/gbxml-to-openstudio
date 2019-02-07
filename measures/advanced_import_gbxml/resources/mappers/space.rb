module Mappers
  class Space < BaseMapper
    def initialize(os_model)
      super(os_model)
    end

    def update_loads(gbxml_space, os_space)
      update_people(gbxml_space, os_space)
      update_equipment(gbxml_space, os_space)
      update_lighting(gbxml_space, os_space)
      update_infiltration(gbxml_space, os_space)
      update_ventilation(gbxml_space, os_space)
    end

    def update_infiltration(gbxml_space, os_space)
      if gbxml_space.infiltration_flow_per_area
        load = OpenStudio::Model::SpaceInfiltrationDesignFlowRate.new(@os_model)
        load.setName("#{gbxml_space.name} Infiltration") if gbxml_space.name
        load.setDesignFlowRate(gbxml_space.infiltration_flow_per_area)
        load.setSpace(os_space)
      end
    end

    def update_people(gbxml_space, os_space)
      if gbxml_space.people_number or gbxml_space.people_heat_gain_total or gbxml_space.people_heat_gain_sensible or gbxml_space.people_heat_gain_latent
        load = OpenStudio::Model::People.new(model)
        load.setName("#{gbxml_space.name} People") if gbxml_space.name

        definition = OpenStudio::Model::PeopleDefinition.new(@os_model)
        definition.setName("#{gbxml_space.name} People Definition") if gbxml_space.name
        definition.setNumberofPeople(gbxml_space.people_number) if gbxml_space.people_number
        sensible_heat_fraction = calculate_sensible_heat_fraction(gbxml_space.people_heat_gain_total, gbxml_space.people_heat_gain_sensible, gbxml_space.people_heat_gain_latent)
        definition.setSensibleHeatFraction(sensible_heat_fraction) if sensible_heat_fraction

        load.setPeopleDefinition(definition)
        load.setSpace(os_space)
        # Not sure schedule creation should be here, but not sure else how to map people load
        if gbxml_space.people_heat_gain_total
          schedule_rulset = OpenStudio::Model::ScheduleRulset.new(model)
          definition.setName("#{gbxml_space.name} People Activity Level Schedule") if gbxml_space.name
          day_schedule = schedule_rulset.defaultDaySchedule
          day_schedule.addValue(OpenStudio::Time.new(0,24,0,0), gbxml_space.people_heat_gain_total)
          load.setActivityLevelSchedule(schedule_ruleset)
        end
      end
    end

    def update_lighting(gbxml_space, os_space)
      if gbxml_space.light_power_per_area
        definition = OpenStudio::Model::LightsDefinition.new(@os_model)
        definition.setName("#{gbxml_space.name} Lights Definition") if gbxml_space.name
        definition.setWattsperSpaceFloorArea(gbxml_space.light_power_per_area)

        load = OpenStudio::Model::Lights.new(definition)
        load.setName("#{gbxml_space.name} Lights") if gbxml_space.name
        load.setSpace(os_space)
      end
    end

    def update_equipment(gbxml_space, os_space)
      if gbxml_space.equip_power_per_area
        definition = OpenStudio::Model::ElectricEquipmentDefinition.new(@os_model)
        definition.setName("#{gbxml_space.name} Equipment Definition") if gbxml_space.name
        definition.setWattsperSpaceFloorArea(gbxml_space.equip_power_per_area)

        load = OpenStudio::Model::ElectricEquipment.new(definition)
        load.setName("#{gbxml_space.name} Equipment") if gbxml_space.name
        load.setSpace(os_space)
      end
    end

    def update_ventilation(gbxml_space, os_space)
      if gbxml_space.air_changes_per_hour or gbxml_space.oa_flow_per_area or gbxml_space.oa_flow_per_person or gbxml_space.oa_flow_per_space
        load = OpenStudio::Model::DesignSpecificationOutdoorAir.new(@os_model)
        load.setOutdoorAirFlowAirChangesperHour(gbxml_space.air_changes_per_hour) if gbxml_space.air_changes_per_hour
        load.setOutdoorAirFlowperPerson(gbxml_space.oa_flow_per_person) if gbxml_space.oa_flow_per_person
        load.setOutdoorAirFlowperFloorArea(gbxml_space.oa_flow_per_area) if gbxml_space.oa_flow_per_area
        load.setOutdoorAirFlowRate(gbxml_space.oa_flow_per_space) if gbxml_space.oa_flow_per_space
        os_space.setDesignSpecificationOutdoorAir(load)
      end
    end

    def self.calculate_sensible_heat_fraction(total, sensible, latent)
      if sensible and total
        return sensible/total
      elsif sensible and latent
        return sensible / (sensible + latent)
      elsif total and latent
        return (total - latent) / total
      end
    end
  end
end