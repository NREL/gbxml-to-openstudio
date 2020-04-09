module SystemsAnalysisReport
  module Mappers
    class SystemTemperatureMapper
      def self.call(peak_condition, coil_sizing_detail)
        if peak_condition
          outside_air = peak_condition.outside_dry_bulb_temperature
          mixed_air = peak_condition.mixed_air_temperature
          supply_air = peak_condition.supply_air_temperature
        end

        if coil_sizing_detail
          return_air = coil_sizing_detail.system_return_air_drybulb_at_ideal_loads_peak
        end

        SystemsAnalysisReport::Models::SystemTemperature.new(outside_air, return_air, mixed_air, supply_air)
      end
    end
  end
end