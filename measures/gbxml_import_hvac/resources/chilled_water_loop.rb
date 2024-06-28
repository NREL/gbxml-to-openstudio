class ChilledWaterLoop < HVACObject
  attr_accessor :plant_loop, :chiller, :pump, :spm, :condenser_loop_ref, :condenser_loop, :is_low_temperature, :equipment

  HIGH_DESIGN_LOOP_EXIT_TEMP = 15
  LOW_DESIGN_LOOP_EXIT_TEMP = 6.666667
  HIGH_LOOP_DESIGN_DELTA_T = 3.333333
  LOW_LOOP_DESIGN_DELTA_T = 8.8888889

  def initialize
    self.name = "Chilled Water Loop"
    self.is_low_temperature = false
    self.equipment = []
  end

  def self.create_from_xml(model_manager, xml)
    plant_loop = new
    plant_loop.model_manager = model_manager

    name = xml.elements['Name']
    plant_loop.set_name(xml.elements['Name'].text) unless name.nil?
    plant_loop.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    plant_loop.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    cw_loop_ref = xml.elements['HydronicLoopId[@hydronicLoopType="CondenserWater"]']
    unless cw_loop_ref.nil?
      plant_loop.condenser_loop_ref = xml.elements['HydronicLoopId'].attributes['hydronicLoopIdRef']
    end

    plant_loop
  end

  def design_loop_exit_temp
    self.is_low_temperature ? LOW_DESIGN_LOOP_EXIT_TEMP : HIGH_DESIGN_LOOP_EXIT_TEMP
  end

  def loop_design_delta_t
    self.is_low_temperature ? LOW_LOOP_DESIGN_DELTA_T : HIGH_LOOP_DESIGN_DELTA_T
  end

  def design_loop_return_temp
    if self.is_low_temperature
      LOW_DESIGN_LOOP_EXIT_TEMP - LOW_LOOP_DESIGN_DELTA_T
    else
      HIGH_DESIGN_LOOP_EXIT_TEMP - HIGH_LOOP_DESIGN_DELTA_T
    end
  end

  def resolve_references
    if self.condenser_loop_ref
      cw_loop = self.model_manager.cw_loops[self.condenser_loop_ref]
      self.condenser_loop = cw_loop if cw_loop
    end
  end

  def build
    self.model_manager = model_manager
    self.model = model_manager.model
    self.plant_loop = add_plant_loop
    self.chiller = add_chiller
    self.pump = add_pump
    self.spm = add_spm

    self.pump.addToNode(self.plant_loop.supplyInletNode)
    self.plant_loop.addSupplyBranchForComponent(self.chiller)
    self.spm.addToNode(self.plant_loop.supplyOutletNode)

    self.plant_loop.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    self.plant_loop.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
  end

  def post_build
    if self.condenser_loop
      self.condenser_loop.plant_loop.addDemandBranchForComponent(self.chiller) if self.condenser_loop
      self.chiller.setCondenserType('WaterCooled')
    end
  end

  private

  def add_plant_loop
    plant_loop = OpenStudio::Model::PlantLoop.new(self.model)
    plant_loop.setName(self.name) unless self.name.nil?
    plant_loop.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    plant_loop.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?

    sizing_plant = plant_loop.sizingPlant
    sizing_plant.setLoopType('Cooling')
    sizing_plant.setDesignLoopExitTemperature(self.design_loop_exit_temp)
    sizing_plant.setLoopDesignTemperatureDifference(self.loop_design_delta_t)

    plant_loop
  end

  def add_chiller
    chiller = OpenStudio::Model::ChillerElectricEIR.new(self.model)
    chiller.setName("#{self.name} Chiller")
    chiller.setReferenceLeavingChilledWaterTemperature(self.design_loop_exit_temp)
    chiller.setReferenceEnteringCondenserFluidTemperature(35)
    chiller.setMinimumPartLoadRatio(0.15)
    chiller.setMaximumPartLoadRatio(1.0)
    chiller.setOptimumPartLoadRatio(1.0)
    chiller.setMinimumUnloadingRatio(0.25)
    chiller.setLeavingChilledWaterLowerTemperatureLimit(2)
    chiller.setChillerFlowMode('LeavingSetpointModulated')

    chiller
  end

  def add_pump
    pump = OpenStudio::Model::PumpVariableSpeed.new(self.model)
    pump.setName("#{self.name} Pump")
    pump.setRatedPumpHead(179344.014)
    pump.setMotorEfficiency(0.9)
    pump.setFractionofMotorInefficienciestoFluidStream(0)
    pump.setCoefficient1ofthePartLoadPerformanceCurve(0)
    pump.setCoefficient2ofthePartLoadPerformanceCurve(0)
    pump.setCoefficient3ofthePartLoadPerformanceCurve(1)
    pump.setCoefficient4ofthePartLoadPerformanceCurve(0)
    pump.setPumpControlType('Intermittent')

    pump
  end

  def add_spm
    temp_sch = OpenStudio::Model::ScheduleRuleset.new(self.model)
    temp_sch.setName("#{self.name} Temp Schedule")
    temp_sch.defaultDaySchedule.setName("#{self.name} Schedule Default")
    if self.is_low_temperature
      temp_sch.defaultDaySchedule.addValue(OpenStudio::Time.new(0, 24, 0, 0), self.design_loop_exit_temp)
    else
      temp_sch.defaultDaySchedule.addValue(OpenStudio::Time.new(0, 24, 0, 0), self.design_loop_exit_temp)
    end
    temp_sch.setName("#{self.name} Temp Schedule")
    spm = OpenStudio::Model::SetpointManagerScheduled.new(self.model, temp_sch)
    spm.setName("#{self.name} Setpoint Manager")
    spm
  end
end