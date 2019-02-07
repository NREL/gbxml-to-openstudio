module GBXML
  class Space
    attr_accessor :infiltration_flow_per_area, :people_number, :people_heat_gain_total, :people_heat_gain_sensible,
                  :people_heat_gain_latent, :light_power_per_area, :equip_power_per_area, :air_changes_per_hour,
                  :oa_flow_per_area, :oa_flow_per_person, :oa_flow_per_space, :volume, :zone_id_ref, :space_type,
                  :light_schedule_id_ref, :equipment_schedule_id_ref, :people_schedule_id_ref, :condition_type, :id,
                  :name, :cad_object_id

    def self.from_xml(xml)
      space = new

      # children
      space.name = xml.elements['Name'].text unless xml.elements['Name'].nil?
      space.cad_object_id = xml.elements['CADObjectId'].text unless xml.elements['CADObjectId'].nil?
      space.infiltration_flow_per_area = xml.elements['InfiltrationFlowPerArea'].text unless xml.elements['InfiltrationFlowPerArea'].nil?
      space.people_number = xml.elements['PeopleNumber'].text unless xml.elements['PeopleNumber'].nil?
      space.people_heat_gain_total = xml.elements['PeopleHeatGain[@heatGainType="Total"]'].text unless xml.elements['PeopleHeatGain[@heatGainType="Total"]'].nil?
      space.people_heat_gain_sensible = xml.elements['PeopleHeatGain[@heatGainType="Sensible"]'].text unless xml.elements['PeopleHeatGain[@heatGainType="Sensible"]'].nil?
      space.people_heat_gain_latent = xml.elements['PeopleHeatGain[@heatGainType="Latent"]'].text unless xml.elements['PeopleHeatGain[@heatGainType="Latent"]'].nil?
      space.light_power_per_area = xml.elements['LightPowerPerArea'].text unless xml.elements['LightPowerPerArea'].nil?
      space.equip_power_per_area = xml.elements['EquipPowerPerArea'].text unless xml.elements['EquipPowerPerArea'].nil?
      space.air_changes_per_hour = xml.elements['AirChangesPerHour'].text unless xml.elements['AirChangesPerHour'].nil?
      space.oa_flow_per_area = xml.elements['OAFlowPerArea'].text unless xml.elements['OAFlowPerArea'].nil?
      space.oa_flow_per_person = xml.elements['OAFlowPerPerson'].text unless xml.elements['OAFlowPerPerson'].nil?
      space.oa_flow_per_space = xml.elements['OAFlowPerSpace'].text unless xml.elements['OAFlowPerSpace'].nil?
      space.volume = xml.elements['Volume'].text unless xml.elements['Volume'].nil?
      # attributes
      space.id = xml.attributes['id'] unless xml.attributes['id'].nil?
      space.zone_id_ref = xml.attributes['zoneIdRef'] unless xml.attributes['zoneIdRef'].nil?
      space.space_type = xml.attributes['spaceType'] unless xml.attributes['spaceType'].nil?
      space.light_schedule_id_ref = xml.attributes['lightScheduleIdRef'] unless xml.attributes['lightScheduleIdRef'].nil?
      space.equipment_schedule_id_ref = xml.attributes['equipmentScheduleIdRef'] unless xml.attributes['equipmentScheduleIdRef'].nil?
      space.people_schedule_id_ref = xml.attributes['peopleScheduleIdRef'] unless xml.attributes['peopleScheduleIdRef'].nil?
      space.condition_type = xml.attributes['conditionType'] unless xml.attributes['conditionType'].nil?

      space
    end

    def ==(other)
      equal = true
      self.instance_variables.each do |variable|
        unless self.instance_variable_get(variable) == other.instance_variable_get(variable)
          equal = false
          break
        end
      end

      return equal
    end
  end
end
