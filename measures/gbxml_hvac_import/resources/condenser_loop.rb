class CondenserLoop < HVACObject
  attr_accessor :plant_loop, :cooler, :pump, :outlet_spm, :boiler_spm, :boiler, :has_heating

  def initialize
    self.name = "Condenser Water Loop"
    self.has_heating = false
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

  def set_has_heating(has_heating)
    self.has_heating = has_heating
  end

  def build
    self.model_manager = model_manager
    self.model = model_manager.model
    self.plant_loop = add_plant_loop
    self.cooler = add_cooler
    self.pump = add_pump
    self.outlet_spm = add_outlet_spm

    self.pump.addToNode(self.plant_loop.supplyInletNode)
    self.plant_loop.addSupplyBranchForComponent(self.cooler)
    self.outlet_spm.addToNode(self.plant_loop.supplyOutletNode)

    if self.has_heating
      self.boiler = add_boiler
      self.boiler_spm = add_boiler_spm
      self.plant_loop.addSupplyBranchForComponent(self.boiler)
      self.boiler_spm.addToNode(self.boiler.outletModelObject.get.to_Node.get)
    end

    self.plant_loop.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    self.plant_loop.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
  end

  private

  def add_plant_loop
    plant_loop = OpenStudio::Model::PlantLoop.new(self.model)
    plant_loop.setName(self.name) unless self.name.nil?
    plant_loop.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    plant_loop.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?

    sizing_plant = plant_loop.sizingPlant

    if self.has_heating
      sizing_plant.setLoopType('Condenser')
      sizing_plant.setDesignLoopExitTemperature(29.444444)
      sizing_plant.setLoopDesignTemperatureDifference(5.55555556)
    else
      sizing_plant.setLoopType('Condenser')
      sizing_plant.setDesignLoopExitTemperature(29.444444)
      sizing_plant.setLoopDesignTemperatureDifference(5.55555556)
    end

    plant_loop
  end

  def add_cooler
    if self.has_heating
      cooler = OpenStudio::Model::EvaporativeFluidCoolerSingleSpeed.new(self.model)
      cooler.setName("#{self.name} Fluid Cooler")
      cooler.setDesignSprayWaterFlowRate(0.002208)
      cooler.setPerformanceInputMethod('UFactorTimesAreaAndDesignWaterFlowRate')
    else
      cooler = OpenStudio::Model::CoolingTowerVariableSpeed.new(self.model)
      cooler.setName("#{self.name} Cooling Tower")
      cooler.setDesignApproachTemperature(3.8888889)
      cooler.setDesignRangeTemperature(5.55555556)
      cooler.setFractionofTowerCapacityinFreeConvectionRegime(0.125)
    end

    cooler
  end

  def add_pump
    pump = OpenStudio::Model::PumpConstantSpeed.new(self.model)
    pump.setName("#{self.name} Pump")
    pump.setRatedPumpHead(148556.625)
    pump.setPumpControlType('Intermittent')
    pump
  end

  def add_outlet_spm
    if self.has_heating
      high_temp_sch = OpenStudio::Model::ScheduleRuleset.new(self.model)
      high_temp_sch.setName("#{self.name} High Temp Schedule")
      high_temp_sch.defaultDaySchedule.setName("#{self.name} High Temp Schedule Default Day")
      high_temp_sch.defaultDaySchedule.addValue(OpenStudio::Time.new(0, 24, 0, 0), 21.1111111)

      low_temp_sch = OpenStudio::Model::ScheduleRuleset.new(self.model)
      low_temp_sch.setName("#{self.name} Low Temp Schedule")
      low_temp_sch.defaultDaySchedule.setName("#{self.name} Low Temp Schedule Default Day")
      low_temp_sch.defaultDaySchedule.addValue(OpenStudio::Time.new(0, 24, 0, 0), 10)

      spm = OpenStudio::Model::SetpointManagerScheduledDualSetpoint.new(self.model)
      spm.setHighSetpointSchedule(high_temp_sch)
      spm.setLowSetpointSchedule(low_temp_sch)
    else
      spm = OpenStudio::Model::SetpointManagerFollowOutdoorAirTemperature.new(self.model)
      spm.setControlVariable("Temperature")
      spm.setReferenceTemperatureType("OutdoorAirWetBulb")
      spm.setOffsetTemperatureDifference(3.888888889)
      spm.setName("#{self.name} Condenser Setpoint Manager")
    end

    spm
  end

  def add_boiler_spm
    high_temp_sch = OpenStudio::Model::ScheduleRuleset.new(self.model)
    high_temp_sch.setName("#{self.name} High Temp Schedule")
    high_temp_sch.defaultDaySchedule.setName("#{self.name} High Temp Schedule Default Day")
    high_temp_sch.defaultDaySchedule.addValue(OpenStudio::Time.new(0, 24, 0, 0), 21.1111111)

    low_temp_sch = OpenStudio::Model::ScheduleRuleset.new(self.model)
    low_temp_sch.setName("#{self.name} Low Temp Schedule")
    low_temp_sch.defaultDaySchedule.setName("#{self.name} Low Temp Schedule Default Day")
    low_temp_sch.defaultDaySchedule.addValue(OpenStudio::Time.new(0, 24, 0, 0), 10)

    spm = OpenStudio::Model::SetpointManagerScheduledDualSetpoint.new(self.model)
    spm.setHighSetpointSchedule(high_temp_sch)
    spm.setLowSetpointSchedule(low_temp_sch)
    spm
  end

  def add_boiler
    boiler = OpenStudio::Model::BoilerHotWater.new(self.model)
    boiler.setName("#{self.name} Boiler")
    boiler.setEfficiencyCurveTemperatureEvaluationVariable('LeavingBoiler')
    boiler.setFuelType('NaturalGas')
    # setDesignWaterOutletTemperature was deprecated in 3.0.0
    # https://github.com/NREL/OpenStudio/pull/3846/files#diff-38aa0007ea5d7e93911e6a920c66a1ae
    if OpenStudio::VersionString.new(OpenStudio.openStudioVersion) < OpenStudio::VersionString.new('3.0.0')
      boiler.setDesignWaterOutletTemperature(30)
    end
    boiler.setNominalThermalEfficiency(0.96)
    boiler.setMaximumPartLoadRatio(1.2)
    boiler.setWaterOutletUpperTemperatureLimit(95)
    boiler.setBoilerFlowMode('ConstantFlow')
    boiler
  end
end