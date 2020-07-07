require_relative 'model'
module SystemsAnalysisReport
  module Models
    DesignPsychrometric = Struct.new(:name, :summary, :entering_coil, :leaving_coil, :outdoor_air, :return_air, :zone) do

      include Models::Model

      def validate

      end

    end
  end
end