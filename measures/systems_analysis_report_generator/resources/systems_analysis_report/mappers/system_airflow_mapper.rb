module SystemsAnalysisReport
  module Mappers
    class SystemAirflowMapper < Mapper
      def klass
        Models::SystemAirflow
      end

      def mapping
        [
            [:main_fan_air_flow, :main_fan],
            [:outside_air_flow, :ventilation]
        ]
      end
    end
  end
end