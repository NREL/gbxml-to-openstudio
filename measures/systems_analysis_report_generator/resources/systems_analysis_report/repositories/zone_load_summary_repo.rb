module SystemsAnalysisReport
  module Repositories
    class ZoneLoadSummaryRepo
      attr_reader :cooling_peak_conditions, :engineering_check_for_coolings, :engineering_check_for_heatings,
                  :estimated_cooling_peak_load_component_tables, :estimated_heating_peak_load_component_tables,
                  :heating_peak_conditions, :load_summary_mapper

      def initialize(cooling_peak_conditions, heating_peak_conditions, engineering_check_for_coolings, engineering_check_for_heatings,
                     estimated_cooling_peak_load_component_tables, estimated_heating_peak_load_component_tables,
                     load_summary_mapper=Mappers::ZoneLoadSummaryMapper.new)
        @cooling_peak_conditions = cooling_peak_conditions
        @heating_peak_conditions = heating_peak_conditions
        @engineering_check_for_coolings = engineering_check_for_coolings
        @engineering_check_for_heatings = engineering_check_for_heatings
        @estimated_cooling_peak_load_component_tables = estimated_cooling_peak_load_component_tables
        @estimated_heating_peak_load_component_tables = estimated_heating_peak_load_component_tables
        @load_summary_mapper = load_summary_mapper
      end

      def find(name)
        result = nil

        cooling_peak_condition = @cooling_peak_conditions.find_by_name(name)
        engineering_check_for_cooling = @engineering_check_for_coolings.find_by_name(name)
        estimated_cooling_peak_load_component_table = @estimated_cooling_peak_load_component_tables.find_by_name(name)

        if [cooling_peak_condition, engineering_check_for_cooling, estimated_cooling_peak_load_component_table].any?
          cooling = @load_summary_mapper.(cooling_peak_condition, engineering_check_for_cooling,
              estimated_cooling_peak_load_component_table)
        end

        heating_peak_condition = @heating_peak_conditions.find_by_name(name)
        engineering_check_for_heating = @engineering_check_for_heatings.find_by_name(name)
        estimated_heating_peak_load_component_table = @estimated_heating_peak_load_component_tables.find_by_name(name)

        if [heating_peak_condition, engineering_check_for_heating, estimated_heating_peak_load_component_table].any?
          heating = @load_summary_mapper.(heating_peak_condition, engineering_check_for_heating,
              estimated_heating_peak_load_component_table)
        end

        if [cooling, heating].any?
          result = Models::CoolingAndHeating.new(name, cooling, heating)
        end

        result
      end
    end
  end
end
