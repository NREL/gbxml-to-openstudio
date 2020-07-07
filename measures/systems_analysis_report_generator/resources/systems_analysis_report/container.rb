module SystemsAnalysisReport
  def self.container(model, sql_file)
    container = Canister.new

    container.register(:eplusout) { EPlusOut.container(sql_file) }
    container.register(:design_psychrometric_repo) { |c| Repositories::DesignPsychrometricRepo.new(c.eplusout.coil_sizing_details, c.eplusout.locations) }
    container.register(:zone_load_summary_repo) do |c|
      Repositories::ZoneLoadSummaryRepo.new(
          c.eplusout.cooling_peak_conditions,
          c.eplusout.heating_peak_conditions,
          c.eplusout.engineering_check_for_coolings,
          c.eplusout.engineering_check_for_heatings,
          c.eplusout.estimated_cooling_peak_load_component_tables,
          c.eplusout.estimated_heating_peak_load_component_tables,
      )
    end
    container.register(:system_load_summary_repo) do |c|
      Repositories::SystemLoadSummaryRepo.new(
          c.eplusout.cooling_peak_conditions,
          c.eplusout.heating_peak_conditions,
          c.eplusout.engineering_check_for_coolings,
          c.eplusout.engineering_check_for_heatings,
          c.eplusout.estimated_cooling_peak_load_component_tables,
          c.eplusout.estimated_heating_peak_load_component_tables,
          c.eplusout.coil_sizing_details
      )
    end
    container.register(:design_psychrometric_service) { |c| Services::DesignPsychrometricService.new(c.design_psychrometric_repo)}
    container.register(:zone_load_summary_service) { |c| Services::ZoneLoadSummaryService.new(c.zone_load_summary_repo)}
    container.register(:system_load_summary_service) { |c| Services::SystemLoadSummaryService.new(c.system_load_summary_repo)}
    container.register(:json_generator) { |c| ReportGenerators::JSONGenerator.new(model, c.zone_load_summary_service, c.system_load_summary_service, c.design_psychrometric_service)}
  end
end