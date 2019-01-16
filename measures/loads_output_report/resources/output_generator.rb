require 'openstudio'
require_relative 'design_psychrometrics'

class OutputGenerator
  attr_accessor :model, :sql_file

  def initialize(model, sql_file)
    self.model = model
    self.sql_file = sql_file
  end

  def get_results
    results = {}

    return results
  end

  def get_zone_component_load_summaries
    component_loads = {}
    component_load_summary = ComponentLoadSummaryOld.new(self.sql_file)

    self.model.getThermalZones.each do |zone|
      zone_name = zone.name.get
      loads_and_peaks = component_load_summary.get_loads_and_peak_conditions(zone_name.upcase)

      zone.spaces.each do |space|
        id = space.additionalProperties.getFeatureAsString('CADObjectId')

        if id.is_initialized
          component_loads[id.get] = loads_and_peaks
        end
      end

    end

    return component_loads
  end

  def get_airsystem_checksums
    checksum = {}
    air_system_checksum = AirSystemChecksum.new(self.sql_file)

    self.model.getAirLoopHVACs.each do |airloop|
      airloop_name = airloop.name.get
      id = airloop.additionalProperties.getFeatureAsString('CADObjectId')

      if id.is_initialized
        loads_and_peaks = air_system_checksum.get_loads_and_peak_conditions(airloop_name.upcase)
        checksum[id.get] = loads_and_peaks
      end
    end

    return checksum
  end

  def get_facility_component_load_summary
    component_loads = {}
    component_load_summary = ComponentLoadSummaryOld.new(self.sql_file)
    component_loads['facility'] = component_load_summary.get_loads_and_peak_conditions('Facility')
    return component_loads
  end

  def get_design_psychrometrics
    psychrometrics = {}
    design_psychrometrics = DesignPsychrometrics(self.sql_file)

    ## Todo: Update this to use CADObjectID from parents system
    self.get_cooling_coils.each do |cooling_coil|
      name = cooling_coil.name.get
      psychrometrics[name] = design_psychrometrics.get_design_psychrometrics(name)
    end

    return psychrometrics
  end

  def get_system_component_summaries

  end

  def get_cooling_coils
    cooling_coils = []
    cooling_coils += self.model.getCoilCoolingDXMultiSpeeds
    cooling_coils += self.model.getCoilCoolingDXSingleSpeeds
    cooling_coils += self.model.getCoilCoolingDXTwoSpeeds
    cooling_coils += self.model.getCoilCoolingDXTwoStageWithHumidityControlModes
    cooling_coils += self.model.getCoilCoolingDXVariableRefrigerantFlows
    cooling_coils += self.model.getCoilCoolingDXVariableSpeeds
    cooling_coils += self.model.getCoilCoolingWaters
    cooling_coils += self.model.getCoilCoolingWaterToAirHeatPumpEquationFits
    cooling_coils += self.model.getCoilCoolingWaterToAirHeatPumpVariableSpeedEquationFits

    # cooling_coils += model.getCoilCoolingCooledBeam
    # cooling_coils.append(model.getCoilCoolingFourPipeBeam)
    # cooling_coils.append(model.getCoilCoolingLowTempRadiantConstFlow)
    # cooling_coils.append(model.getCoilCoolingLowTempRadiantVarFlow)

    return cooling_coils
  end
end

model = OpenStudio::Model::Model.new
coil1 = OpenStudio::Model::CoilCoolingDXSingleSpeed.new(model)
coil2 = OpenStudio::Model::CoilCoolingDXTwoSpeed.new(model)

generator = OutputGenerator.new(model, nil)
generator.get_cooling_coils.each do |coil|
  puts coil.name.get
end
