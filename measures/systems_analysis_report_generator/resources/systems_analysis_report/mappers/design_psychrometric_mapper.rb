module SystemsAnalysisReport
  module Mappers
    class DesignPsychrometricMapper < Mapper
      def klass
        Models::DesignPsychrometric
      end

      def mapping
        [
            [:standard_air_density_adjusted_for_elevation, :air_density],
            [:moist_air_heat_capacity, :air_specific_heat],
            [:outdoor_air_flow_percentage_at_ideal_loads_peak, :percent_outdoor_air],
            [:outdoor_air_volume_flow_rate_at_ideal_loads_peak, :outdoor_air_flow_rate],
            [:coil_sensible_capacity_at_ideal_loads_peak, :zone_sensible_load],
            [:coil_final_reference_air_volume_flow_rate, :coil_air_flow_rate],
            [:date_time_at_sensible_ideal_loads_peak, :time_of_peak],
            [:zone_air_drybulb_at_ideal_loads_peak, :zone_dry_bulb_temperature],
            [:zone_air_humidity_ratio_at_ideal_loads_peak, :zone_humidity_ratio],
            [:zone_air_relative_humidity_at_ideal_loads_peak, :zone_relative_humidity],
            [:system_return_air_drybulb_at_ideal_loads_peak, :return_air_dry_bulb_temperature],
            [:system_return_air_humidity_ratio_at_ideal_loads_peak, :return_air_humidity_ratio],
            [:outdoor_air_drybulb_at_ideal_loads_peak, :outdoor_air_dry_bulb_temperature],
            [:outdoor_air_humidity_ratio_at_ideal_loads_peak, :outdoor_air_humidity_ratio],
            [:coil_entering_air_drybulb_at_ideal_loads_peak, :entering_coil_dry_bulb_temperature],
            [:coil_entering_air_humidity_ratio_at_ideal_loads_peak, :entering_coil_humidity_ratio],
            [:coil_leaving_air_drybulb_at_ideal_loads_peak, :leaving_coil_dry_bulb_temperature],
            [:coil_leaving_air_humidity_ratio_at_ideal_loads_peak, :leaving_coil_humidity_ratio],
            [:supply_fan_air_heat_gain_at_ideal_loads_peak, :supply_fan_temperature_difference]
        ]
      end

      def call(from)
        result = super(from)
        fan_temp_diff = from.supply_fan_air_heat_gain_at_ideal_loads_peak / (from.supply_fan_maximum_air_mass_flow_rate *
            from.moist_air_heat_capacity)

        result.supply_fan_temperature_difference = fan_temp_diff
        result
      end
    end
  end
end