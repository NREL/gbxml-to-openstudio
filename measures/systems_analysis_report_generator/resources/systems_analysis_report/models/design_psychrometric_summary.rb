module SystemsAnalysisReport
  module Models
    DesignPsychrometricSummary = Struct.new(:name, :atmospheric_pressure, :coil_air_flow_rate, :outdoor_air_flow_rate,
                                            :percent_outdoor_air, :supply_fan_temperature_difference, :time_of_peak,
                                            :zone_sensible_load) do
      include Models::Model

      def validate

      end
    end
  end
end