module SystemsAnalysisReport
  module Mappers
    class DesignPsychrometricMapper < Mapper
      attr_accessor :design_psychrometric_summary_mapper

      def initialize(design_psychrometric_summary_mapper=Mappers::DesignPsychrometricSummaryMapper.new)
        @design_psychrometric_summary_mapper = design_psychrometric_summary_mapper
      end

      def klass
        Models::DesignPsychrometric
      end

      def call(coil_sizing_detail, location)
        result = klass.new

        result.summary = @design_psychrometric_summary_mapper.(coil_sizing_detail, location)
        result.entering_coil = Models::AirStatePoint.new(coil_sizing_detail.coil_entering_air_drybulb_at_ideal_loads_peak, coil_sizing_detail.coil_entering_air_humidity_ratio_at_ideal_loads_peak)
        result.leaving_coil = Models::AirStatePoint.new(coil_sizing_detail.coil_leaving_air_drybulb_at_ideal_loads_peak, coil_sizing_detail.coil_leaving_air_humidity_ratio_at_ideal_loads_peak)
        result.outdoor_air = Models::AirStatePoint.new(coil_sizing_detail.outdoor_air_drybulb_at_ideal_loads_peak, coil_sizing_detail.outdoor_air_humidity_ratio_at_ideal_loads_peak)
        result.return_air = Models::AirStatePoint.new(coil_sizing_detail.system_return_air_drybulb_at_ideal_loads_peak, coil_sizing_detail.system_return_air_humidity_ratio_at_ideal_loads_peak)
        result.zone = Models::AirStatePoint.new(coil_sizing_detail.zone_air_drybulb_at_ideal_loads_peak, coil_sizing_detail.zone_air_humidity_ratio_at_ideal_loads_peak)

        result
      end
    end
  end
end