module SystemsAnalysisReport
  module Mappers
    class PeakLoadComponentMapper < Mapper
      def klass
        Models::PeakLoadComponent
      end

      def mapping
        [
            [:sensible_instant, :sensible_instant],
            [:sensible_delayed, :sensible_delayed],
            [:latent, :latent],
            [:total, :total],
            [:percent_grand_total, :percent_grand_total],
            [:related_area, :related_area]
        ]
      end
    end
  end
end