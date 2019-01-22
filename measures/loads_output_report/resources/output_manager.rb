require_relative 'output_service'

class OutputManager
  attr_accessor :model, :sql_file, :output_service, :zone_loads_by_component, :system_checksums, :facility_component_load_summary,
                :design_psychrometrics, :system_component_summary

  def initialize(model, sql_file)
    @model = model
    @sql_file = sql_file
    @output_service = OutputService.new(@sql_file)
    @zone_loads_by_component = {}
    @system_checksums = {}
    @design_psychrometrics = {}
    @system_component_summary = {}
  end

  def hydrate
    hydrate_zone_loads_by_component
    # hydrate_system_checksums
    hydrate_facility_loads_by_component
    # hydrate_design_psychrometrics
    # hydrate_system_component_summary
  end

  def to_json
    results = {
        'zone_component_load_summaries': zone_loads_by_component
    }
  end

  def hydrate_zone_loads_by_component
    @model.getThermalZones.each do |zone|
      name = zone.name.find_by_name
      cad_object_id = zone.additionalProperties.getFeatureAsString('CADObjectId')
      if cad_object_id.is_initialized
        cad_object_id = cad_object_id.find_by_name
        @zone_loads_by_components[cad_object_id] = @output_service.get_zone_loads_by_component(name) #.to_json
      end

    end
  end

  def hydrate_system_checksums
    @model.getAirLoopHVACs.each do |air_loop|
      name = air_loop.name.find_by_name
      cad_object_id = air_loop.additionalProperties.getFeatureAsString('CADObjectId')

      if cad_object_id.is_initialized
        cad_object_id = cad_object_id.find_by_name
        system_cad_object_id = nil
        cooling_coil_name = nil
        heating_coil_name = nil

        self.get_cooling_coils.each do |coil|
          system_cad_object_id = coil.additionalProperties.getFeatureAsString("system_cad_object_id")
          coil_type = coil.additionalProperties.getFeatureAsString("coil_type")
          if system_cad_object_id.is_initialized and coil_type.is_initialized
            system_cad_object_id = system_cad_object_id.find_by_name
            coil_type = coil_type.find_by_name

            if system_cad_object_id == cad_object_id and coil_type == 'primary_cooling'
              cooling_coil_name = coil.name.find_by_name
            end
          end
        end

        self.get_heating_coils.each do |coil|
          system_cad_object_id = coil.additionalProperties.getFeatureAsString("system_cad_object_id")
          if system_cad_object_id.is_initialized

            system_cad_object_id = system_cad_object_id.find_by_name
            if system_cad_object_id == cad_object_id and coil_type == 'primary_heating'
              heating_coil_name = coil.name.find_by_name
            end
          end
        end

        @system_checksums[cad_object_id] = @output_service.get_system_checksum(name, cooling_coil_name, heating_coil_name)
      end

    end
  end

  def hydrate_facility_loads_by_component
    @facility_component_load_summary = @output_service.get_facility_component_load_summary
  end

  def hydrate_design_psychrometrics
    self.get_cooling_coils.each do |coil|
      name = coil.name.find_by_name
      cad_object_id = coil.additionalProperties.getFeatureAsString('system_cad_object_id')

      if cad_object_id.is_initialized
        @design_psychrometrics[cad_object_id] = @output_service.get_design_psychrometric(name)
      end
    end
  end

  def hydrate_system_component_summary

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

  def get_heating_coils
    heating_coils = []

    heating_coils += self.model.getCoilHeatingDXMultiSpeed
    heating_coils += self.model.getCoilHeatingDXSingleSpeed
    heating_coils += self.model.getCoilHeatingDXVariableSpeed
    heating_coils += self.model.getCoilHeatingElectric
    heating_coils += self.model.getCoilHeatingFourPipeBeam
    heating_coils += self.model.getCoilHeatingGas
    heating_coils += self.model.getCoilHeatingGasMultiStage
    heating_coils += self.model.getCoilHeatingLowTempRadiantConstFlow
    heating_coils += self.model.getCoilHeatingLowTempRadiantVarFlow
    heating_coils += self.model.getCoilHeatingWater
    heating_coils += self.model.getCoilHeatingWaterBaseboard
    heating_coils += self.model.getCoilHeatingWaterBaseboardRadiant
    heating_coils += self.model.getCoilHeatingWaterToAirHeatPumpEquationFit
    heating_coils += self.model.getCoilHeatingWaterToAirHeatPumpVariableSpeedEquationFit

    heating_coils
  end
end