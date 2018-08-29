require_relative '../model/helpers'

class VAVBox
  def self.create_vav_box_from_xml(model, std, xml)

    heating_coil = nil
    # Add the heating coil
    unless xml.attributes['heatingCoilType'].nil? or xml.attributes['heatingCoilType'] == "None"
      heating_coil_type = xml.attributes['heatingCoilType']
      if heating_coil_type == "ElectricResistance"
        heating_coil = AirSystem.create_coil_heating_electric(model)
      elsif heating_coil_type == "Furnace"
        heating_coil = AirSystem.create_coil_heating_gas(model)
      elsif heating_coil_type == "HotWater"
        hydronic_loop_id = xml.elements['HydronicLoopId[@hydronicLoopType="HotWater"]']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            hw_loop = Helpers.get_plant_loop_by_id(model, hydronic_loop_id_ref)
            if hw_loop
              heating_coil = AirSystem.create_coil_heating_water(model, hw_loop)
            end
          end
        end
      end
    end

    # default to electric for now
    if heating_coil.nil?
      heating_coil = std.create_coil_heating_electric(model)
    end

    vav_box = OpenStudio::Model::AirTerminalSingleDuctVAVReheat.new(model, model.alwaysOnDiscreteSchedule, heating_coil)

    unless xml.elements['Name'].nil?
      vav_box.setName(xml.elements['Name'].text)
    end

    # assign VAV box to air system
    air_system_id = xml.elements['AirSystemId']
    unless air_system_id.nil?
      air_system_id_ref = air_system_id.attributes['airSystemIdRef']
      unless air_system_id_ref.nil?
        air_system = Helpers.get_air_loop_by_id(model, air_system_id_ref)
        if air_system
          air_system.addBranchForHVACComponent(vav_box)
        end
      end
    end

    unless xml.attributes['id'].nil?
      vav_box.additionalProperties.setFeature('id', xml.attributes['id'])
    end

    unless xml.elements['CADObjectId'].nil?
      vav_box.additionalProperties.setFeature('CADObjectId', xml.elements['CADObjectId'].text)
    end

  end
end