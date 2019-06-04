require_relative 'output_service'

class OutputManager < JSONable
  attr_accessor :model, :sql_file, :output_service, :zone_loads_by_component, :system_checksums, :facility_component_load_summary,
                :design_psychrometrics, :system_component_summary

  def initialize(model, sql_file)
    @model = model
    @sql_file = sql_file
    @output_service = OutputService.new(model, sql_file)
    @zone_loads_by_components = []
    @system_checksums = []
    @design_psychrometrics = []
  end

  def hydrate
    hydrate_zone_loads_by_component
    hydrate_facility_loads_by_component
    hydrate_system_checksums
    hydrate_design_psychrometrics
    hydrate_system_component_summarys
  end

  def to_json
    zone_loads_by_components_hash = []
    @zone_loads_by_components.each do |value|
      zone_loads_by_components_hash << value.to_hash
    end

    system_checksums_hash = []
    @system_checksums.each do |value|
      system_checksums_hash << value.to_hash
    end

    design_psychrometrics_hash = []
    @design_psychrometrics.each do |value|
      design_psychrometrics_hash << value.to_hash
    end

    outputs = {
        "zone_loads_by_components": zone_loads_by_components_hash,
        "system_checksums": system_checksums_hash,
        "facility_component_load_summary": @facility_component_load_summary.to_hash,
        "design_psychrometrics": design_psychrometrics_hash,
        "system_component_load_summarys": @system_component_summary.to_hash
    }

    JSON.dump(outputs)
  end

  def hydrate_zone_loads_by_component
    @model.getThermalZones.each do |zone|
      name = zone.name.get
      cad_object_id = zone.additionalProperties.getFeatureAsString('CADObjectId')
      if cad_object_id.is_initialized
        cad_object_id = cad_object_id.get
        zone_loads_by_component = @output_service.get_zone_loads_by_component(name) #.to_json

        if zone_loads_by_component
          zone_loads_by_component.cad_object_id = cad_object_id
          @zone_loads_by_components << zone_loads_by_component
        end

      end
    end
  end

  def add_system_checksum(system)
    cad_object_id = system.additionalProperties.getFeatureAsString('CADObjectId')

    if cad_object_id.is_initialized

      if system.to_ZoneHVACComponent.is_initialized
        zone = system.thermalZone
        if zone.is_initialized
          name = zone.get.name.get
        end
      else
        name = system.name.get
      end

      return unless name

      cad_object_id = cad_object_id.get

      cooling_coil = find_cooling_coil_by_features({"system_cad_object_id": cad_object_id, "coil_type": "primary_cooling"})
      cooling_coil_name = cooling_coil.nil? ? nil : cooling_coil.name.get

      heating_coil = find_heating_coil_by_features({"system_cad_object_id": cad_object_id, "coil_type": "primary_heating"})
      heating_coil_name = heating_coil.nil? ? nil : heating_coil.name.get

      system_checksum = @output_service.get_system_checksum(name, cooling_coil_name, heating_coil_name)

      if system_checksum
        system_checksum.cad_object_id = cad_object_id
        @system_checksums << system_checksum
      end

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
      system_cad_object_id = coil.additionalProperties.getFeatureAsString('system_cad_object_id')

      if system_cad_object_id.is_initialized
        name = coil.name.get
        system_cad_object_id = system_cad_object_id.get
        design_psychrometric = @output_service.get_design_psychrometric(name)

        if design_psychrometric
          design_psychrometric.cad_object_id = system_cad_object_id
          @design_psychrometrics << design_psychrometric
        end

      end
    end
  end

  def get_heating_coil_summaries(coils)
    coil_summaries = []

    coils.each do |coil|
      system_cad_object_id = coil.additionalProperties.getFeatureAsString('system_cad_object_id')

      if system_cad_object_id.is_initialized
        name = coil.name.get
        system_cad_object_id = system_cad_object_id.get
        coil_component_summary = @output_service.get_heating_coil_component_summary(name)
        if coil_component_summary
          coil_component_summary.cad_object_id = system_cad_object_id
          coil_summaries << coil_component_summary
        end
      end
    end

    coil_summaries
  end

  def get_cooling_coil_summaries(coils)
    coil_summaries = []

    coils.each do |coil|
      system_cad_object_id = coil.additionalProperties.getFeatureAsString('system_cad_object_id')

      if system_cad_object_id.is_initialized
        name = coil.name.get
        system_cad_object_id = system_cad_object_id.get
        coil_component_summary = @output_service.get_cooling_coil_component_summary(name)
        if coil_component_summary
          coil_component_summary.cad_object_id = system_cad_object_id
          coil_summaries << coil_component_summary
        end
      end
    end

    coil_summaries
  end

  def get_preheat_coil_summaries
    coils = find_heating_coils_by_features({"coil_type": "preheat"})
    get_heating_coil_summaries(coils)
  end

  def get_primary_heating_coil_summaries
    coils = find_heating_coils_by_features({"coil_type": "primary_heating"})
    get_heating_coil_summaries(coils)
  end

  def get_supplemental_heating_coil_summaries
    coils = find_heating_coils_by_features({"coil_type": "supplemental_heating"})
    get_heating_coil_summaries(coils)
  end

  def get_primary_cooling_coil_summaries
    coils = find_cooling_coils_by_features({"coil_type": "primary_cooling"})
    get_cooling_coil_summaries(coils)
  end

  def get_load_airflow_summaries
    zones = @model.getThermalZones
    zone_summaries = []

    zones.each do |zone|
      cad_object_id = zone.additionalProperties.getFeatureAsString('CADObjectId')

      if cad_object_id.is_initialized
        name = zone.name.get
        cad_object_id = cad_object_id.get
        load_airflow_summary = @output_service.get_load_airflow_summary(name)
        if load_airflow_summary
          load_airflow_summary.cad_object_id = cad_object_id
          zone_summaries << load_airflow_summary
        end
      end
    end

    zone_summaries
  end

  def get_fan_component_summaries
    fan_summaries = []

    get_fans.each do |fan|
      cad_object_id = fan.additionalProperties.getFeatureAsString('system_cad_object_id')
      if cad_object_id.is_initialized
        name = fan.name.get
        cad_object_id = cad_object_id.get
        fan_component_summary = @output_service.get_fan_component_summary(name)
        if fan_component_summary
          fan_component_summary.cad_object_id = cad_object_id
          fan_summaries << fan_component_summary
        end
      end
    end

    fan_summaries
  end

  def hydrate_system_component_summarys
    @system_component_summary = SystemComponentSummary.new
    @system_component_summary.preheat_coils = get_preheat_coil_summaries
    @system_component_summary.cooling_coils = get_primary_cooling_coil_summaries
    @system_component_summary.heating_coils = get_primary_heating_coil_summaries
    @system_component_summary.supplemental_heating_coils = get_supplemental_heating_coil_summaries
    @system_component_summary.load_air_flows = get_load_airflow_summaries
    @system_component_summary.fans = get_fan_component_summaries
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

  def find_cooling_coils_by_features(options = {})
    cooling_coils = []

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
        cooling_coils << cooling_coil
      end
    end

    return cooling_coils
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

  def find_heating_coils_by_features(options = {})
    heating_coils = []

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
        heating_coils << heating_coil
      end
    end

    return heating_coils
  end

  def find_fans_by_features(options = {})
    fans = []

    self.get_fans.each do |fan|
      match = true

      options.each do |key, value|
        unless fan.additionalProperties.hasFeature(key.to_s)
          match = false
          break
        end

        feature = fan.additionalProperties.getFeatureAsString(key.to_s).get
        unless feature == value
          match = false
          break
        end
      end

      if match
        fans << fan
      end
    end

    return fans
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
  end

  def get_fans
    fans = []

    fans += @model.getFanConstantVolumes
    fans += @model.getFanOnOffs
    fans += @model.getFanVariableVolumes

    fans
  end
end
