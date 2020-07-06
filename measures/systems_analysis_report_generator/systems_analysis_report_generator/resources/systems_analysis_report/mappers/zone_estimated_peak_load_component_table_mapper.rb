module SystemsAnalysisReport
  module Mappers
    class ZoneEstimatedPeakLoadComponentTableMapper
      attr_reader :peak_load_component_table_mapper, :lighting_return_air_mapper, :other_return_air_mapper,
                  :sizing_factor_correction_mapper, :time_delay_correction_mapper

      def initialize(peak_load_component_table_mapper = EstimatedPeakLoadComponentTableToPeakLoadComponentTable.new,
                     lighting_return_air_mapper = LightingReturnPeakLoadAirMapper.new,
                     other_return_air_mapper = OtherReturnAirPeakLoadMapper.new,
                     time_delay_correction_mapper = TimeDelayCorrectionPeakLoadMapper.new,
                     sizing_factor_correction_mapper = SizingFactorCorrectionPeakLoadMapper.new
      )
        @peak_load_component_table_mapper = peak_load_component_table_mapper
        @lighting_return_air_mapper = lighting_return_air_mapper
        @other_return_air_mapper = other_return_air_mapper
        @time_delay_correction_mapper = time_delay_correction_mapper
        @sizing_factor_correction_mapper = sizing_factor_correction_mapper
      end

      def call(estimated_peak_load_component_table, peak_condition)
        result = @peak_load_component_table_mapper.(estimated_peak_load_component_table)
        result.add_load(:return_air_lights, @lighting_return_air_mapper.(estimated_peak_load_component_table.lights))
        result.add_load(:return_air_other, @other_return_air_mapper.(estimated_peak_load_component_table))

        if peak_condition
          result.add_load(:time_delay_correction, @time_delay_correction_mapper.(peak_condition))
          result.add_load(:sizing_factor_correction, @sizing_factor_correction_mapper.(peak_condition))
        end

        result.normalize
        result
      end
    end
  end
end