require_relative 'output_service'

class OutputManager < JSONable
  attr_accessor :model, :sql_file, :output_service, :zone_loads_by_component, :system_checksums, :facility_component_load_summary,
                :design_psychrometrics, :system_component_summary

  def initialize(model, sql_file)
    @model = model
    @sql_file = sql_file
    @output_service = OutputService.new(model, sql_file)
    @zone_loads_by_component = {}
    @system_checksums = {}
    @design_psychrometrics = {}
    @system_component_summary = {}
  end

  def hydrate
    hydrate_zone_loads_by_component
    # hydrate_system_checksums
    hydrate_facility_loads_by_component
    hydrate_design_psychrometrics
    # hydrate_system_component_summary
  end

  def to_json
    zone_component_load_summaries = {}
    zone_loads_by_component.each do |key, value|
      zone_component_load_summaries[key] = value.to_hash
    end
    outputs = {
        "zone_component_load_summaries": zone_component_load_summaries
    }

    JSON.dump(outputs)
  end

  def hydrate_zone_loads_by_component
    @model.getThermalZones.each do |zone|
      name = zone.name.get
      cad_object_id = zone.additionalProperties.getFeatureAsString('CADObjectId')
      if cad_object_id.is_initialized
        cad_object_id = cad_object_id.get
        @zone_loads_by_component[cad_object_id] = @output_service.get_zone_loads_by_component(name) #.to_json
      end

    end
  end

  def add_system_checksum(system)
    name = system.name.get
    cad_object_id = system.additionalProperties.getFeatureAsString('CADObjectId')

    if cad_object_id.is_initialized
      cad_object_id = cad_object_id.get

      cooling_coil = find_cooling_coil_by_features({"system_cad_object_id": cad_object_id, "coil_type": "primary_cooling"})
      cooling_coil_name = cooling_coil.nil? ? nil : cooling_coil.name.get

      heating_coil = find_heating_coil_by_features({"system_cad_object_id": cad_object_id, "coil_type": "primary_heating"})
      heating_coil_name = heating_coil.nil? ? nil : heating_coil.name.get

      @system_checksums[cad_object_id] = @output_service.get_system_checksum(name, cooling_coil_name, heating_coil_name)
    end
  end

  def hydrate_system_checksums
    get_systems.each do |system|
      add_system_checksum(system)
    end
  end

  def hydrate_facility_loads_by_component
    @facility_component_load_summary = @output_service.get_facility_component_load_summary
  end

  def hydrate_design_psychrometrics
    self.get_cooling_coils.each do |coil|
      name = coil.name.get
      cad_object_id = coil.additionalProperties.getFeatureAsString('system_cad_object_id')

      if cad_object_id.is_initialized
        cad_object_id = cad_object_id.get
        @design_psychrometrics[cad_object_id] = @output_service.get_design_psychrometric(name)
      end
    end
  end

  def hydrate_system_component_summary

  end

  def find_cooling_coil_by_features(options = {})
    self.get_cooling_coils.each do |cooling_coil|
      match = true

      options.each do |key, value|
        unless cooling_coil.additionalProperties.hasFeature(key.to_s)
          match = false
          break
        end

        feature = cooling_coil.additionalProperties.getFeatureAsString(key.to_s).get
        unless feature == value
          match = false
          break
        end
      end

      if match
        return cooling_coil
      end
    end

    return nil
  end

  def find_heating_coil_by_features(options = {})
    self.get_heating_coils.each do |heating_coil|
      match = true

      options.each do |key, value|
        unless heating_coil.additionalProperties.hasFeature(key.to_s)
          match = false
          break
        end

        feature = heating_coil.additionalProperties.getFeatureAsString(key.to_s).get
        unless feature == value
          match = false
          break
        end
      end

      if match
        return heating_coil
      end
    end

    return nil
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

    heating_coils += self.model.getCoilHeatingDXMultiSpeeds
    heating_coils += self.model.getCoilHeatingDXSingleSpeeds
    heating_coils += self.model.getCoilHeatingDXVariableSpeeds
    heating_coils += self.model.getCoilHeatingElectrics
    heating_coils += self.model.getCoilHeatingFourPipeBeams
    heating_coils += self.model.getCoilHeatingGass
    heating_coils += self.model.getCoilHeatingGasMultiStages
    heating_coils += self.model.getCoilHeatingLowTempRadiantConstFlows
    heating_coils += self.model.getCoilHeatingLowTempRadiantVarFlows
    heating_coils += self.model.getCoilHeatingWaters
    heating_coils += self.model.getCoilHeatingWaterBaseboards
    heating_coils += self.model.getCoilHeatingWaterBaseboardRadiants
    heating_coils += self.model.getCoilHeatingWaterToAirHeatPumpEquationFits
    heating_coils += self.model.getCoilHeatingWaterToAirHeatPumpVariableSpeedEquationFits

    heating_coils
  end

  def get_systems
    systems = []

    systems += @model.getAirLoopHVACs
    systems += @model.getZoneHVACFourPipeFanCoils
    systems += @model.getZoneHVACPackagedTerminalAirConditioners
    systems += @model.getZoneHVACPackagedTerminalHeatPumps
    systems += @model.getZoneHVACUnitHeaters
    systems += @model.getZoneHVACUnitVentilators
    systems += @model.getZoneHVACTerminalUnitVariableRefrigerantFlows
    systems += @model.getZoneHVACWaterToAirHeatPumps

    return systems

    return
  end
end
