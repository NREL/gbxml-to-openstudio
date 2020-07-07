module SystemsAnalysisReport
  module Mappers
    class LightingReturnPeakLoadAirMapper < Mapper
      def klass
        Models::PeakLoadComponent
      end

      def mapping
        [
            [:sensible_return_air, :sensible_instant]
        ]
      end
    end
  end
end