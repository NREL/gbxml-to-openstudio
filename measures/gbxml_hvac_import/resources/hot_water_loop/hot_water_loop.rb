class HotWaterLoop
  def self.create_hw_loop_from_xml(model, std, xml)
    hw_loop = std.model_add_hw_loop(model, 'NaturalGas')

    name = xml.elements['Name']
    unless name.nil?
      hw_loop.setName(xml.elements['Name'].text)
    end

    unless xml.attributes['id'].nil?
      hw_loop.additionalProperties.setFeature('id', xml.attributes['id'])
    end

    unless xml.elements['CADObjectId'].nil?
      hw_loop.additionalProperties.setFeature('CADObjectId', xml.elements['CADObjectId'].text)
    end

    hw_loop
  end
end