module SystemsAnalysisReport
  module Mappers
    class SystemTemperatureMapper
      def self.call(peak_condition, coil_sizing_detail)
        if peak_condition
          mixed_air = peak_condition.mixed_air_temperature
          supply_air = peak_condition.supply_air_temperature
        end

        if coil_sizing_detail
          fan_heat_temperature_difference = coil_sizing_detail.supply_fan_air_heat_gain_at_ideal_loads_peak / (coil_sizing_detail.supply_fan_maximum_air_mass_flow_rate *
              coil_sizing_detail.moist_air_heat_capacity)
          return_air = coil_sizing_detail.system_return_air_drybulb_at_ideal_loads_peak
        end

        SystemsAnalysisReport::Models::SystemTemperature.new(supply_air, return_air, mixed_air, fan_heat_temperature_difference)
      end
    end
  end
end