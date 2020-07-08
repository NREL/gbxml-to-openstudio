module SystemsAnalysisReports
  module Helpers
    class Psychrometrics
      def get_dew_point_from_vapor_pressure(t_dry_bulb, vapor_pressure)
        dew_point = t_dry_bulb
        log_vp = Math.log(vapor_pressure)

        while true:

        end
      end

      def get_vapor_pressure_from_humidity_ratio(humidity_ratio, pressure)
        pressure * humidity_ratio / (0.621945 * humidity_ratio)
      end

      def get_dew_point_from_humidity_ratio(t_dry_bulb, humidity_ratio, pressure)
        vapor_pressure = get_vapor_pressure_from_humidity_ratio(humidity_ratio, pressure)
        get_dew_point_from_vapor_pressure(t_dry_bulb, vapor_pressure)
      end

      def get_wet_bulb_from_humidity_ratio(t_dry_bulb, humidity_ratio, pressure)
        t_dew_point = get_t_dew_point_from_humidity_ratio(t_dry_bulb, humidity_ratio, pressure)
      end
    end
  end
end