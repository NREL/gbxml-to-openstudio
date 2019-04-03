module GBXML
  class Space
    @@instances = {}
    attr_accessor :infiltration_flow_per_area, :people_number, :people_heat_gain_total, :people_heat_gain_sensible,
                  :people_heat_gain_latent, :light_power_per_area, :equip_power_per_area, :air_changes_per_hour,
                  :oa_flow_per_area, :oa_flow_per_person, :oa_flow_per_space, :volume, :zone_id_ref, :space_type,
                  :light_schedule_id_ref, :equipment_schedule_id_ref, :people_schedule_id_ref, :condition_type, :id,
                  :name, :cad_object_id

    def self.configure_units(temperature_unit, length_unit, area_unit, volume_unit)
      @@temperature_unit = temperature_unit
      @@length_unit = length_unit
      @@area_unit = area_unit
      @@volume_unit = volume_unit
    end

    def self.from_xml(xml)
      space = new

      # attributes
      space.name = xml.elements['Name'].text unless xml.elements['Name'].nil?
      space.id = xml.attributes['id'] unless xml.attributes['id'].nil?
      space.zone_id_ref = xml.attributes['zoneIdRef'] unless xml.attributes['zoneIdRef'].nil?
      space.space_type = xml.attributes['spaceType'] unless xml.attributes['spaceType'].nil?
      space.light_schedule_id_ref = xml.attributes['lightScheduleIdRef'] unless xml.attributes['lightScheduleIdRef'].nil?
      space.equipment_schedule_id_ref = xml.attributes['equipmentScheduleIdRef'] unless xml.attributes['equipmentScheduleIdRef'].nil?
      space.people_schedule_id_ref = xml.attributes['peopleScheduleIdRef'] unless xml.attributes['peopleScheduleIdRef'].nil?
      space.condition_type = xml.attributes['conditionType'] unless xml.attributes['conditionType'].nil?

      #children
      space.cad_object_id = xml.elements['CADObjectId'].text unless xml.elements['CADObjectId'].nil?
      space.infiltration_flow_per_area = convert_to_metric_from_xml(xml.elements['InfiltrationFlowPerArea']) unless xml.elements['InfiltrationFlowPerArea'].nil?
      space.light_power_per_area = convert_to_metric_from_xml(xml.elements['LightPowerPerArea']) unless xml.elements['LightPowerPerArea'].nil?
      space.equip_power_per_area = convert_to_metric_from_xml(xml.elements['EquipPowerPerArea']) unless xml.elements['EquipPowerPerArea'].nil?
      space.people_number = xml.elements['PeopleNumber'].text.to_f unless xml.elements['PeopleNumber'].nil?
      space.people_heat_gain_total = convert_to_metric_from_xml(xml.elements['PeopleHeatGain[@heatGainType="Total"]']) unless xml.elements['PeopleHeatGain[@heatGainType="Total"]'].nil?
      space.people_heat_gain_sensible = convert_to_metric_from_xml(xml.elements['PeopleHeatGain[@heatGainType="Sensible"]']) unless xml.elements['PeopleHeatGain[@heatGainType="Sensible"]'].nil?
      space.people_heat_gain_latent = convert_to_metric_from_xml(xml.elements['PeopleHeatGain[@heatGainType="Latent"]']) unless xml.elements['PeopleHeatGain[@heatGainType="Latent"]'].nil?
      space.air_changes_per_hour = xml.elements['AirChangesPerHour'].text.to_f unless xml.elements['AirChangesPerHour'].nil?
      space.oa_flow_per_area = convert_to_metric_from_xml(xml.elements['OAFlowPerArea']) unless xml.elements['OAFlowPerArea'].nil?
      space.oa_flow_per_person = convert_to_metric_from_xml(xml.elements['OAFlowPerPerson']) unless xml.elements['OAFlowPerPerson'].nil?
      space.oa_flow_per_space = convert_to_metric_from_xml(xml.elements['OAFlowPerSpace']) unless xml.elements['OAFlowPerSpace'].nil?
      space.volume = convert_to_metric_from_xml(xml.elements['Volume'], @@volume_unit) unless xml.elements['Volume'].nil?

      @@instances[space.id] = space
      space
    end

    def self.convert_to_metric_from_xml(xml, unit = nil)
      value = xml.text.to_f
      unit = xml.attributes['unit'] if unit.nil?
      case unit
      when "CFMPerSquareFoot"
        return OpenStudio.convert(value, "cfm/ft^2", "m^3/s*m^2").get
      when "LPerSecPerSquareM"
        return OpenStudio.convert(value, "L/s*m^2", "m^3/s*m^2").get
      when "WattPerSquareFoot"
        return OpenStudio.convert(value, "W/ft^2", "W/m^2").get
      when "BtuPerHourPerson"
        return OpenStudio.convert(value, "Btu/h", "W").get
      when "CFM"
        return OpenStudio.convert(value, "cfm", "m^3/s").get
      when "LPerSec"
        return OpenStudio.convert(value, "L/s", "m^3/s").get
      when "CubicFeet"
        return OpenStudio.convert(value, "ft^3", "m^3").get
      end

      return value
    end

    def self.find(id)
      if @@instances.key?(id)
        return @@instances[id]
      end
    end

    def self.all
      return @@instances.values
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
