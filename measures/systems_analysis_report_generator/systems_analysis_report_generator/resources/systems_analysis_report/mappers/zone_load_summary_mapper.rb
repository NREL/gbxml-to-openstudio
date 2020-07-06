module SystemsAnalysisReport
  module Mappers
    class ZoneLoadSummaryMapper
      attr_reader :estimated_peak_load_component_table_mapper, :engineering_check_mapper

      def initialize(estimated_peak_load_component_table_mapper=Mappers::ZoneEstimatedPeakLoadComponentTableMapper.new,
                     engineering_check_mapper = Mappers::EngineeringCheckMapper.new
      )
        @estimated_peak_load_component_table_mapper = estimated_peak_load_component_table_mapper
        @engineering_check_mapper = engineering_check_mapper
      end

      def call(peak_condition, engineering_check, estimated_peak_load_component_table)
        estimated_peak_load_component_table = @estimated_peak_load_component_table_mapper.(
            estimated_peak_load_component_table, peak_condition)
        engineering_check = @engineering_check_mapper.(estimated_peak_load_component_table, peak_condition, engineering_check)

        Models::ZoneLoadSummary.new(peak_condition, engineering_check, estimated_peak_load_component_table)
      end
    end
  end
end