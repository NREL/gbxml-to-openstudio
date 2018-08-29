# require 'openstudio'
# require 'openstudio-standards'
# require 'rexml/document'
# require_relative '../condenser_loop/condenser_loop'

require_relative '../model/helpers'
class ChilledWaterLoop
  def self.create_chw_loop_from_xml(model, std, xml)

    # Should this logic assume air cooled if the condenser loop can't be found
    # or should it create a new condenser loop if it cant be found?
    if xml.elements['HydronicLoopId[@hydronicLoopType="CondenserWater"]'].nil?
      chw_loop = std.model_add_chw_loop(model,
                                        'const_pri',
                                        chiller_cooling_type = nil,
                                        chiller_condenser_type = nil,
                                        chiller_compressor_type = nil,
                                        'Electricity',
                                        condenser_water_loop = nil,
                                        building_type = nil)
      name = xml.elements['Name']
      unless name.nil?
        chw_loop.setName(xml.elements['Name'].text)
      end
    else
      cw_loop_id = xml.elements['HydronicLoopId'].attributes['hydronicLoopIdRef']
      cw_loop = Helpers.get_plant_loop_by_id(model, cw_loop_id)
      if cw_loop
        chw_loop = std.model_add_chw_loop(model,
                                          'const_pri_var_sec',
                                          'WaterCooled',
                                          chiller_condenser_type = nil,
                                          'Rotary Screw',
                                          cool_fueling = nil,
                                          cw_loop,
                                          building_type = nil)
      end
      name = xml.elements['Name']
      unless name.nil?
        chw_loop.setName(xml.elements['Name'].text)
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