module SystemsAnalysisReport
  module Models
    SystemTemperature = Struct.new(:supply, :return, :mixed_air, :fan_heat_temperature_difference) do
      include Models::Model

      def validate

      end
    end
  end
end