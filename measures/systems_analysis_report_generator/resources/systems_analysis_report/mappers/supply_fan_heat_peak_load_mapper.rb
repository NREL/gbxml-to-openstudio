module SystemsAnalysisReport
  module Mappers
    class SupplyFanHeatPeakLoadMapper < Mapper
      def klass
        Models::PeakLoadComponent
      end

      def mapping
        [
            [:supply_fan_air_heat_gain_at_ideal_loads_peak, :sensible_instant]
        ]
      end
    end
  end
end