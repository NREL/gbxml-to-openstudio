class BaseboardRadiant < HVACObject
  attr_accessor :baseboard, :supply_fan, :heating_coil, :heating_coil_type, :heating_loop_ref

  def initialize
    self.name = "Baseboard Radiant"
  end

  def connect_thermal_zone(thermal_zone)
    self.baseboard.addToThermalZone(thermal_zone)
  end

  def add_baseboard_convective
    baseboard = nil

    if self.heating_coil_type == 'ElectricResistance'
      baseboard = OpenStudio::Model::ZoneHVACBaseboardRadiantConvectiveElectric.new(self.model)
    elsif self.heating_coil_type == 'HotWater'
      baseboard = OpenStudio::Model::ZoneHVACBaseboardRadiantConvectiveWater.new(self.model)
    end

    baseboard.setName(self.name) unless self.name.nil?
    baseboard.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    baseboard.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
    baseboard
  end

  def add_heating_coil
    heating_coil = nil

    if self.heating_coil_type == "HotWater"
      heating_coil = OpenStudio::Model::CoilHeatingWaterBaseboardRadiant.new(self.model)
      heating_coil.setName(self.name + " Heating Coil") unless self.name.nil?
      heating_coil.additionalProperties.setFeature('system_cad_object_id', self.cad_object_id) unless self.name.nil?
      heating_coil.additionalProperties.setFeature('coil_type', 'primary_heating')
    end

    heating_coil
  end

  def resolve_dependencies
    unless self.heating_loop_ref.nil?
      heating_loop = self.model_manager.hw_loops[self.heating_loop_ref]
      heating_loop.plant_loop.addDemandBranchForComponent(self.heating_coil)
    end
  end

  def build
    # Object dependency resolution needs to happen before the object is built
    self.model = model_manager.model
    self.heating_coil = add_heating_coil
    self.baseboard = add_baseboard_convective
    resolve_dependencies

    self.baseboard.setHeatingCoil(self.heating_coil) unless self.heating_coil.nil?

    self.built = true
    self.baseboard
  end

  def self.create_from_xml(model_manager, xml)
    equipment = new
    equipment.model_manager = model_manager

    name = xml.elements['Name']
    equipment.set_name(xml.elements['Name'].text) unless name.nil?
    equipment.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    equipment.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    unless xml.attributes['heatingCoilType'].nil? or xml.attributes['heatingCoilType'] == "None"
      equipment.heating_coil_type = xml.attributes['heatingCoilType']

      if equipment.heating_coil_type == 'HotWater'
        hydronic_loop_id = xml.elements['HydronicLoopId']
        unless hydronic_loop_id.nil?
          hydronic_loop_id_ref = hydronic_loop_id.attributes['hydronicLoopIdRef']
          unless hydronic_loop_id_ref.nil?
            equipment.heating_loop_ref = hydronic_loop_id_ref
          end
        end
      end
    end

    equipment
  end
end