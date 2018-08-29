# require 'openstudio'
# require 'openstudio-standards'
# require 'rexml/document'

class CondenserLoop
  def self.create_cw_loop_from_xml(model, std, xml)
    cw_loop = std.model_add_cw_loop(model,
                                    'Open Cooling Tower',
                                    'Propeller or Axial',
                                    'VariableSpeedFan',
                                    1,
                                    1,
                                    nil)

    name = xml.elements['Name']
    unless name.nil?
      cw_loop.setName(xml.elements['Name'].text)
    end

    unless xml.attributes['id'].nil?
      cw_loop.additionalProperties.setFeature('id', xml.attributes['id'])
    end

    unless xml.elements['CADObjectId'].nil?
      cw_loop.additionalProperties.setFeature('CADObjectId', xml.elements['CADObjectId'].text)
    end

    cw_loop
  end
end