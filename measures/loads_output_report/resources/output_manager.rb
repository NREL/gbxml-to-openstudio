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
      name = zone.name.get
      cad_object_id = zone.additionalProperties.getFeatureAsString('CADObjectId')
      if cad_object_id.is_initialized
        cad_object_id = cad_object_id.get
        @zone_loads_by_components[cad_object_id] = @output_service.get_zone_loads_by_component(name) #.to_json
      end

    end
  end

  def hydrate_system_checksums

  end

  def hydrate_facility_loads_by_component
    @facility_component_load_summary = @output_service.get_facility_component_load_summary
  end

  def hydrate_design_psychrometrics

  end

  def hydrate_system_component_summary

  end
end