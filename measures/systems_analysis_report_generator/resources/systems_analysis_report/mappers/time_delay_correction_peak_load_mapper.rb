module SystemsAnalysisReport
  module Mappers
    class TimeDelayCorrectionPeakLoadMapper < Mapper
      def klass
        Models::PeakLoadComponent
      end

      def mapping
        [
            [:difference_between_peak_and_estimated_sensible_load, :sensible_delayed]
        ]
      end
    end
  end
end