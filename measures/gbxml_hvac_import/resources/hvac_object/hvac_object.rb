class HVACObject
  attr_accessor :model_manager, :model, :name, :dependents, :dependencies, :id, :cad_object_id, :built

  def initialize
    self.dependents = []
    self.dependencies = []
    self.built = false
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

  def add_dependents(dependent)
    self.dependents.push(dependent)
  end

  def add_dependencies(dependency)
    self.dependencies.push(dependency)
  end

  def build(model_manager)
    # resolve dependencies
    raise "Subclass must overwrite build"
  end
end