class HVACObject
  attr_accessor :model_manager, :model, :name, :id, :cad_object_id, :built

  def initialize
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

  def resolve_references

  end

  def resolve_read_relationships

  end

  def build
    # resolve dependencies
    raise "Subclass must overwrite build"
  end

  def connect

  end
end