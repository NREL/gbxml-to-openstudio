require 'rexml/document'
require 'openstudio'
require 'openstudio-standards'
require_relative '../model/helpers'

class AirSystem

  def self.create_air_system_from_xml(model, std, xml)

    air_loop_hvac = OpenStudio::Model::AirLoopHVAC.new(model)

    unless xml.elements['Name'].nil?
      air_loop_hvac.setName(xml.elements['Name'].text)
    end

    # Add the fan
    unless xml.elements['Fan'].nil?
      fan_type = xml.elements['Fan'].attributes['FanType']
      if fan_type == "VariableVolume"
        fan = std.create_fan_variable_volume_from_json(model, 'VAV_default')
        fan.addToNode(air_loop_hvac.supplyInletNode)
      elsif fan_type == "ConstantVolume"
        fan = std.create_fan_constant_volume_from_json(model, 'VAV_default')
        fan.addToNode(air_loop_hvac.supplyInletNode)
      end
    end

    # Add the heating coil
    unless xml.attributes['heatingCoilType'].nil? or xml.attributes['heatingCoilType'] == "None"
      heating_coil_type = xml.attributes['heatingCoilType']
      if heating_coil_type == "ElectricResistance"
        std.create_coil_heating_electric(model, air_loop:air_loop_hvac)
      elsif heating_coil_type == "Furnace"
        std.create_coil_heating_gas(model, air_loop:air_loop_hvac)
      elsif heating_coil_type == "HotWater"
        hydronic_loop_id = xml.elements['HydronicLoopId[@coilType="Heating"]']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            hw_loop = Helpers.get_plant_loop_by_id(model, hydronic_loop_id_ref)
            if hw_loop
              std.create_coil_heating_water(model, hw_loop, air_loop:air_loop_hvac)
            end
          end
        end
      end
    end

    # Add the cooling coil
    unless xml.attributes['coolingCoilType'].nil? or xml.attributes['coolingCoilType'] == "None"
      cooling_coil_type = xml.attributes['coolingCoilType']
      if cooling_coil_type == "DX"
        std.create_coil_cooling_dx_single_speed(model, air_loop:air_loop_hvac)
      elsif cooling_coil_type == "ChilledWater"
        hydronic_loop_id = xml.elements['HydronicLoopId[@coilType="Cooling"]']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            chw_loop = Helpers.get_plant_loop_by_id(model, hydronic_loop_id_ref)
            if chw_loop
              std.create_coil_cooling_water(model, chw_loop, air_loop:air_loop_hvac)
            end
          end
        end
      end
    end

    # Add the preheat coil
    unless xml.attributes['preheatCoilType'].nil? or xml.attributes['preheatCoilType'] == "None"
      preheating_coil_type = xml.attributes['preheatCoilType']
      if preheating_coil_type == "ElectricResistance"
        std.create_coil_heating_electric(model, air_loop:air_loop_hvac)
      elsif preheating_coil_type == "Furnace"
        std.create_coil_heating_gas(model, air_loop:air_loop_hvac)
      elsif preheating_coil_type == "HotWater"
        hydronic_loop_id = xml.elements['HydronicLoopId[@coilType="preheat"]']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            hw_loop = Helpers.get_plant_loop_by_id(model, hydronic_loop_id_ref)
            if hw_loop
              std.create_coil_heating_water(model, hw_loop, air_loop:air_loop_hvac)
            end
          end
        end
      end
    end

    # Add the OA System
    oa_controller = OpenStudio::Model::ControllerOutdoorAir.new(model)
    oa_system = OpenStudio::Model::AirLoopHVACOutdoorAirSystem.new(model, oa_controller)
    oa_system.addToNode(air_loop_hvac.supplyInletNode)

    # Add the Heat Exchanger
    heat_exchanger_element = xml.elements['HeatExchanger']
    unless heat_exchanger_element.nil?
      hx_type = heat_exchanger_element.attributes['heatExchangerType']
      unless hx_type.nil? or hx_type == 'None'
        std.air_loop_hvac_apply_energy_recovery_ventilator(air_loop_hvac)
      end
    end

    # Add an SPM
    spm = OpenStudio::Model::SetpointManagerWarmest.new(model)
    spm.addToNode(air_loop_hvac.supplyOutletNode)

    unless xml.attributes['id'].nil?
      air_loop_hvac.additionalProperties.setFeature('id', xml.attributes['id'])
    end

    unless xml.elements['CADObjectId'].nil?
      air_loop_hvac.additionalProperties.setFeature('CADObjectId', xml.elements['CADObjectId'].text)
    end

  end
end