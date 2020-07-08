module SystemsAnalysisReport
  module Models
    AirStatePoint = Struct.new(:dry_bulb_temperature, :humidity_ratio) do
      include Models::Model

      def validate

      end
    end
  end
end