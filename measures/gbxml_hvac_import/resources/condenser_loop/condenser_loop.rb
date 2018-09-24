require_relative '../hvac_object/hvac_object'

class CondenserLoop < HVACObject
  attr_accessor :plant_loop, :cooling_tower, :pump, :spm, :has_heating

  def initialize
    self.name = "Condenser Water Loop"
    self.has_heating = false
  end

  def set_has_heating(has_heating)
    self.has_heating = has_heating
  end

  def add_plant_loop
    plant_loop = OpenStudio::Model::PlantLoop.new(self.model)
    plant_loop.setName(self.name) unless self.name.nil?
    plant_loop.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    plant_loop.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?

    sizing_plant = plant_loop.sizingPlant
    sizing_plant.setLoopType('Condenser')
    sizing_plant.setDesignLoopExitTemperature(29.444444)
    sizing_plant.setLoopDesignTemperatureDifference(5.55555556)

    plant_loop
  end

  def add_cooling_tower
    cooling_tower = OpenStudio::Model::CoolingTowerVariableSpeed.new(self.model)
    cooling_tower.setName("#{self.name} Cooling Tower")
    cooling_tower.setDesignApproachTemperature(3.8888889)
    cooling_tower.setDesignRangeTemperature(5.55555556)
    cooling_tower.setFractionofTowerCapacityinFreeConvectionRegime(0.125)
    cooling_tower
  end

  def add_pump
    pump = OpenStudio::Model::PumpConstantSpeed.new(self.model)
    pump.setName("#{self.name} Pump")
    pump.setRatedPumpHead(148556.625)
    pump.setPumpControlType('Intermittent')
    pump
  end

  def add_spm
    if self.has_heating

    else
      temp_sch = OpenStudio::Model::ScheduleRuleset.new(self.model)
      temp_sch.setName("#{self.name} Temp Schedule")
      temp_sch.defaultDaySchedule.setName("#{self.name} Schedule Default")
      temp_sch.defaultDaySchedule.addValue(OpenStudio::Time.new(0, 24, 0, 0), 21.1111111)
      temp_sch.setName("#{self.name} Temp Schedule")
      spm = OpenStudio::Model::SetpointManagerScheduled.new(self.model, temp_sch)
      spm.setName("#{self.name} Setpoint Manager")
      spm
    end
  end

  def add_boiler
    boiler = OpenStudio::Model::BoilerHotWater.new(self.model)
    boiler.setName("#{self.name} Boiler")
    boiler.setEfficiencyCurveTemperatureEvaluationVariable('LeavingBoiler')
    boiler.setFuelType('NaturalGas')
    boiler.setDesignWaterOutletTemperature(60)
    boiler.setNominalThermalEfficiency(0.92)
    boiler.setMaximumPartLoadRatio(1.2)
    boiler.setWaterOutletUpperTemperatureLimit(95)
    boiler.setBoilerFlowMode('LeavingSetpointModulated')
    boiler
  end

  def build(model_manager)
    self.model_manager = model_manager
    self.model = model_manager.model
    self.plant_loop = add_plant_loop
    self.cooling_tower = add_cooling_tower
    self.pump = add_pump
    self.spm = add_spm

    self.pump.addToNode(self.plant_loop.supplyInletNode)
    self.plant_loop.addSupplyBranchForComponent(self.cooling_tower)
    self.spm.addToNode(self.plant_loop.supplyOutletNode)

    self.plant_loop.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    self.plant_loop.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?

    # self.built = true
    self.plant_loop
  end

  def self.create_from_xml(xml)
    plant_loop = new

    name = xml.elements['Name']
    plant_loop.set_name(xml.elements['Name'].text) unless name.nil?
    plant_loop.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    plant_loop.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    plant_loop
  end
end