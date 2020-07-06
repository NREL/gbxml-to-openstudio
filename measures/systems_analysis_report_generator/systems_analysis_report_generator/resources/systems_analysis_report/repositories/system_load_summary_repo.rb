module SystemsAnalysisReport
  module Repositories
    class SystemLoadSummaryRepo
      attr_reader :cooling_peak_conditions, :heating_peak_conditions, :engineering_check_for_coolings, :engineering_check_for_heatings,
                  :estimated_cooling_peak_load_component_tables, :estimated_heating_peak_load_component_tables,
                  :coil_sizing_details, :load_summary_mapper

      def initialize(cooling_peak_conditions, heating_peak_conditions, engineering_check_for_coolings, engineering_check_for_heatings,
                     estimated_cooling_peak_load_component_tables, estimated_heating_peak_load_component_tables,
                      coil_sizing_details, load_summary_mapper=Mappers::SystemLoadSummaryMapper.new)
        @cooling_peak_conditions = cooling_peak_conditions
        @engineering_check_for_coolings = engineering_check_for_coolings
        @engineering_check_for_heatings = engineering_check_for_heatings
        @estimated_cooling_peak_load_component_tables = estimated_cooling_peak_load_component_tables
        @estimated_heating_peak_load_component_tables = estimated_heating_peak_load_component_tables
        @heating_peak_conditions = heating_peak_conditions
        @coil_sizing_details = coil_sizing_details
        @load_summary_mapper = load_summary_mapper
      end

      def find(name, cooling_coil, heating_coil)
        result = nil

        cooling_peak_condition = @cooling_peak_conditions.find_by_name(name)
        engineering_check_for_cooling = @engineering_check_for_coolings.find_by_name(name)
        estimated_cooling_peak_load_component_table = @estimated_cooling_peak_load_component_tables.find_by_name(name)
        cooling_coil = @coil_sizing_details.find_by_name(cooling_coil) if cooling_coil

        if [cooling_peak_condition, engineering_check_for_cooling, estimated_cooling_peak_load_component_table, cooling_coil].any?
          cooling = @load_summary_mapper.(cooling_peak_condition, engineering_check_for_cooling,
              estimated_cooling_peak_load_component_table, cooling_coil)
        end

        heating_peak_condition = @heating_peak_conditions.find_by_name(name)
        engineering_check_for_heating = @engineering_check_for_heatings.find_by_name(name)
        estimated_heating_peak_load_component_table = @estimated_heating_peak_load_component_tables.find_by_name(name)
        heating_coil = @coil_sizing_details.find_by_name(heating_coil)  if heating_coil

        if [heating_peak_condition, engineering_check_for_heating, estimated_heating_peak_load_component_table, heating_coil].any?
          heating = @load_summary_mapper.(heating_peak_condition, engineering_check_for_heating,
              estimated_heating_peak_load_component_table, heating_coil)
        end

        if [cooling, heating].any?
          result = Models::CoolingAndHeating.new(name, cooling, heating)
        end

        result
      end
    end
  end
end