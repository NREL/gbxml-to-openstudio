module SystemsAnalysisReport
  module Mappers
    class AirStatePointMapper < Mapper
      def klass
        Models::AirStatePoint
      end

      def mapping
        [
            # dry-bulb
            # wet-bulb
            #
            # dew point
            # Magnus Formula:
            # y(Tdb, RH) = ln(RH/100) + b*Tdb/(c + Tdb)
            # Tdp = cy(T, RH) / (b - y(T,RH))
            # humidity ratio
            # relative humdiity
            # enthalpy
            # specific heat
            # density
            # specific volume

            [:zone_air_drybulb_at_ideal_loads_peak, :zone_dry_bulb_temperature],
            [:zone_air_humidity_ratio_at_ideal_loads_peak, :zone_humidity_ratio],
            [:zone_air_relative_humidity_at_ideal_loads_peak, :zone_relative_humidity],

            [:system_return_air_drybulb_at_ideal_loads_peak, :return_air_dry_bulb_temperature],
            [:system_return_air_humidity_ratio_at_ideal_loads_peak, :return_air_humidity_ratio],

            [:outdoor_air_drybulb_at_ideal_loads_peak, :outdoor_air_dry_bulb_temperature],
            [:outdoor_air_humidity_ratio_at_ideal_loads_peak, :outdoor_air_humidity_ratio],
            [:outdoor_air_wet_bulb_at_ideal_loads_peak, :outdoor_air_wet_bulb_temperature],

            [:coil_entering_air_drybulb_at_ideal_loads_peak, :entering_coil_dry_bulb_temperature],
            [:coil_entering_air_humidity_ratio_at_ideal_loads_peak, :entering_coil_humidity_ratio],
            [:coil_entering_air_enthalpy_at_ideal_loads_peak, :entering_coil_enthalpy],
            [:coil_entering_air_wetbulb_at_ideal_loads_peak, :entering_coil_wet_bulb_temperature],

            [:coil_leaving_air_drybulb_at_ideal_loads_peak, :leaving_coil_dry_bulb_temperature],
            [:coil_leaving_air_humidity_ratio_at_ideal_loads_peak, :leaving_coil_humidity_ratio],
            [:coil_leaving_air_enthalpy_at_ideal_loads_peak, :leaving_coil_enthalpy],
            [:coil_leaving_air_wetbulb_at_ideal_loads_peak, :leaving_coil_wet_bulb_temperature],

            [:standard_air_density_adjusted_for_elevation, :air_density],
            [:moist_air_heat_capacity, :air_specific_heat],
            [:outdoor_air_flow_percentage_at_ideal_loads_peak, :percent_outdoor_air],
            [:outdoor_air_volume_flow_rate_at_ideal_loads_peak, :outdoor_air_flow_rate],
            [:coil_sensible_capacity_at_ideal_loads_peak, :zone_sensible_load],
            [:coil_final_reference_air_volume_flow_rate, :coil_air_flow_rate],
            [:date_time_at_sensible_ideal_loads_peak, :time_of_peak],
            [:zone_air_relative_humidity_at_ideal_loads_peak, :zone_relative_humidity],
        ]
      end

      def relative_humidity(t_dry_bulb, hum_ratio, pressure)
        vapor_pressure = vapor_pressure(hum_ratio, pressure,)
        relative_humidity = relative_humidty_from_vapor_pressure(t_dry_bulb, vapor_pressure)
        return relative_humidity
      end
    end
  end
end