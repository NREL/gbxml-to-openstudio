module SystemsAnalysisReport
  module Mappers
    class SizingFactorCorrectionPeakLoadMapper < Mapper
      def klass
        Models::PeakLoadComponent
      end

      def mapping
        [
            [:difference_due_to_sizing_factor, :sensible_instant]
        ]
      end
    end
  end
end