module SystemsAnalysisReport
  module Mappers
    class ZoneLoadSummaryMapper
      attr_reader :estimated_peak_load_component_table_mapper

      def initialize(estimated_peak_load_component_table_mapper=Mappers::ZoneEstimatedPeakLoadComponentTableMapper.new
      )
        @estimated_peak_load_component_table_mapper = estimated_peak_load_component_table_mapper
      end

      def call(peak_condition, engineering_check, estimated_peak_load_component_table)
        estimated_peak_load_component_table = @estimated_peak_load_component_table_mapper.(
            estimated_peak_load_component_table, peak_condition)
        Models::ZoneLoadSummary.new(peak_condition, engineering_check, estimated_peak_load_component_table)
      end
    end
  end
end