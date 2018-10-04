require_relative '../hvac_object/hvac_object'

class HotWaterLoop < HVACObject
  attr_accessor :plant_loop, :boiler, :pump, :spm

  # Should defaults be in here?
  def initialize
    self.name = "Hot Water Loop"
  end

  def add_plant_loop
    plant_loop = OpenStudio::Model::PlantLoop.new(self.model)
    plant_loop.setName(self.name)
    plant_loop.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    plant_loop.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?

    sizing_plant = plant_loop.sizingPlant
    sizing_plant.setLoopType('Heating')
    sizing_plant.setDesignLoopExitTemperature(60)
    sizing_plant.setLoopDesignTemperatureDifference(16.666666667)

    plant_loop
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

  def add_pump
    pump = OpenStudio::Model::PumpVariableSpeed.new(self.model)
    pump.setName("#{self.name} Pump")
    pump.setRatedPumpHead(179344.014)
    pump.setMotorEfficiency(0.9)
    pump.setPumpControlType('Intermittent')
    pump
  end

  def add_spm
    temp_sch = OpenStudio::Model::ScheduleRuleset.new(self.model)
    temp_sch.setName("#{self.name} Temp Schedule")
    temp_sch.defaultDaySchedule.setName("#{self.name} Schedule Default")
    temp_sch.defaultDaySchedule.addValue(OpenStudio::Time.new(0, 24, 0, 0), 60)
    temp_sch.setName("#{self.name} Temp Schedule")
    spm = OpenStudio::Model::SetpointManagerScheduled.new(self.model, temp_sch)
    spm.setName("#{self.name} Setpoint Manager")
    spm
  end

  def build
    self.model_manager = model_manager
    self.model = model_manager.model
    self.plant_loop = add_plant_loop
    self.boiler = add_boiler
    self.pump = add_pump
    self.spm = add_spm

    self.pump.addToNode(self.plant_loop.supplyInletNode)
    self.plant_loop.addSupplyBranchForComponent(self.boiler)
    self.spm.addToNode(self.plant_loop.supplyOutletNode)

    self.plant_loop.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    self.plant_loop.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?

    self.built = true
    self.plant_loop
  end

  def self.create_from_xml(model_manager, xml)
    plant_loop = new
    plant_loop.model_manager = model_manager

    name = xml.elements['Name']
    plant_loop.set_name(xml.elements['Name'].text) unless name.nil?
    plant_loop.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    plant_loop.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    plant_loop
  end
end