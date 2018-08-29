# require 'openstudio'
# require 'openstudio-standards'
# require 'rexml/document'

class CondenserLoop
  def self.create_cw_loop_from_xml(model, std, xml)
    name = xml.elements['Name'].nil? ? nil : xml.elements['Name'].text
    cw_loop = std.model_add_cw_loop(model, system_name:name)

    unless xml.attributes['id'].nil?
      cw_loop.additionalProperties.setFeature('id', xml.attributes['id'])
    end

    unless xml.elements['CADObjectId'].nil?
      cw_loop.additionalProperties.setFeature('CADObjectId', xml.elements['CADObjectId'].text)
    end

    cw_loop
  end
end

# file = File.open('/Users/npflaum/Projects/Autodesk/gbxml-hvac-translation/sample-gbxmls/Analytical Systems 01.xml')
#
# gbxml_doc = REXML::Document.new(file)
# model = OpenStudio::Model::Model.new
# std = Standard.build('90.1-2013')
#
# cw_loop_hash = {}
#
# gbxml_doc.elements.each("gbXML/HydronicLoop[@loopType='CondenserWater']") do |element|
#   cw_loop = CondenserLoop.create_cw_loop_from_xml(model, std, element)
#   cw_loop_hash[element.attributes['id']] = cw_loop
# end
#
# puts cw_loop_hash
# puts model