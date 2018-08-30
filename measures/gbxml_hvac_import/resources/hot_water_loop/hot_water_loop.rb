class HotWaterLoop
  attr_accessor :model, :name, :references, :id, :cad_object_id

  def initialize(model)
    self.model = model
    self.references = []
  end

  def set_name(name)
    self.name = name
  end

  def set_id(id)
    self.id = id
  end

  def set_cad_object_id(cad_object_id)
    self.cad_object_id = cad_object_id
  end

  def add_reference(reference)
    self.references.push(reference)
  end

  def build
    hw_loop = OpenStudio::Model::PlantLoop.new(model)
  end

  def self.create_hw_loop_from_xml(model, xml)
    hw_loop = new(model)

    name = xml.elements['Name']
    unless name.nil?
      hw_loop.set_name(xml.elements['Name'].text)
    end

    unless xml.attributes['id'].nil?
      hw_loop.set_id(xml.attributes['id'])
    end

    unless xml.elements['CADObjectId'].nil?
      hw_loop.set_cad_object_id(xml.elements['CADObjectId'].text)
    end

    hw_loop
  end
end