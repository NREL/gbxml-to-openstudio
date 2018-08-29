# require 'openstudio'
# require 'openstudio-standards'
# require 'rexml/document'
# require_relative '../condenser_loop/condenser_loop'

require_relative '../model/helpers'
class ChilledWaterLoop
  def self.create_chw_loop_from_xml(model, std, xml)
    name = xml.elements['Name'].nil? ? nil : xml.elements['Name'].text

    # Should this logic assume air cooled if the condenser loop can't be found
    # or should it create a new condenser loop if it cant be found?
    if xml.elements['HydronicLoopId[@hydronicLoopType="CondenserWater"]'].nil?
      chw_loop = std.model_add_chw_loop(model,
                                        system_name: name,
                                        chw_pumping_type: 'const_pri_var_sec',
                                        chiller_cooling_type: 'AirCooled')
    else
      cw_loop_id = xml.elements['HydronicLoopId'].attributes['hydronicLoopIdRef']
      cw_loop = Helpers.get_plant_loop_by_id(model, cw_loop_id)
      if cw_loop
        chw_loop = std.model_add_chw_loop(model,
                                          system_name: name,
                                          chw_pumping_type: 'const_pri_var_sec',
                                          chiller_cooling_type: 'WaterCooled',
                                          condenser_water_loop: cw_loop)
      end
    end

    unless xml.attributes['id'].nil?
      chw_loop.additionalProperties.setFeature('id', xml.attributes['id'])
    end

    unless xml.elements['CADObjectId'].nil?
      chw_loop.additionalProperties.setFeature('CADObjectId', xml.elements['CADObjectId'].text)
    end

    chw_loop
  end

end