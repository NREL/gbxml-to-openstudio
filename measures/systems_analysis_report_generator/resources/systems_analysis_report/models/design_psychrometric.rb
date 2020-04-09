require_relative 'model'
module SystemsAnalysisReport
  module Models
    DesignPsychrometric = Struct.new(:name, :air_density, :air_specific_heat, :percent_outdoor_air, :outdoor_air_flow_rate,
                                     :zone_sensible_load, :coil_air_flow_rate, :time_of_peak, :zone_dry_bulb_temperature,
                                     :zone_humidity_ratio, :zone_relative_humidity, :return_air_dry_bulb_temperature,
                                     :return_air_humidity_ratio, :outdoor_air_dry_bulb_temperature, :outdoor_air_humidity_ratio,
                                     :entering_coil_dry_bulb_temperature, :entering_coil_humidity_ratio,
                                     :leaving_coil_dry_bulb_temperature, :leaving_coil_humidity_ratio, :supply_fan_temperature_difference) do

      include Models::Model

      def validate

      end

    end
  end
end
