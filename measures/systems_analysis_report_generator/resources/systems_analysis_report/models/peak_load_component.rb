module SystemsAnalysisReport
  module Models
    PeakLoadComponent = Struct.new(:sensible_instant, :sensible_delayed, :latent, :total, :percent_grand_total) do
      include Models::Model

      def initialize(*args)
        super(*args)
        validate
      end

      def update_percent_grand_total(grand_total)
        self.percent_grand_total = (self.total / grand_total * 100)
      end

      def validate
        update_total
      end

      private
      def update_total
        self.total = [self.sensible_instant, self.sensible_delayed, self.latent].inject(0) {
            |sum, val| val ? sum + val : sum
        }
      end
    end
  end
end