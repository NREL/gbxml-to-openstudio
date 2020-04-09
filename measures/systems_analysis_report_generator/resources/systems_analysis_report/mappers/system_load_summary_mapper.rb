module SystemsAnalysisReport
  module Mappers
    class SystemLoadSummaryMapper
      attr_reader :temperature_mapper, :airflow_mapper, :estimated_peak_load_component_table_mapper

      def initialize(temperature_mapper=Mappers::SystemTemperatureMapper, airflow_mapper=Mappers::SystemAirflowMapper.new,
                     estimated_peak_load_component_table_mapper=Mappers::SystemEstimatedPeakLoadComponentTableMapper.new)
        @temperature_mapper = temperature_mapper
        @airflow_mapper = airflow_mapper
        @estimated_peak_load_component_table_mapper = estimated_peak_load_component_table_mapper
      end

      def call(peak_condition, engineering_check, estimated_peak_load_component_table, coil_sizing_detail)

        estimated_peak_load_component_table = @estimated_peak_load_component_table_mapper.(estimated_peak_load_component_table, peak_condition, coil_sizing_detail)
        temperature = @temperature_mapper.(peak_condition, coil_sizing_detail)
        airflow = @airflow_mapper.(peak_condition)

        Models::SystemLoadSummary.new(nil, peak_condition, engineering_check, estimated_peak_load_component_table,
                                      temperature, airflow)
      end
    end
  end
end