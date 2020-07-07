module EPlusOut
  module Models
    EstimatedPeakLoadComponent = Struct.new(
        :percent_grand_total,
        :latent,
        :related_area,
        :sensible_delayed,
        :sensible_instant,
        :sensible_return_air,
        :total,
        :total_per_area,
        ) do
      include Models::Model

      def initialize(*args)
        super(*args)
        validate
      end

      def update_percent_grand_total(grand_total)
        if grand_total and grand_total > 0
          self.percent_grand_total = (self.total / grand_total * 100)
        end
      end

      private
      def validate
        update_total
        update_total_per_area
      end

      def update_total
        self.total = [self.sensible_instant, self.sensible_delayed, self.sensible_return_air, self.latent].inject(0) {
            |sum, val| val ? sum + val : sum
        }
      end

      def update_total_per_area
        if self.related_area and self.related_area > 0
          self.total_per_area = self.total / self.related_area
        else
          self.total_per_area = nil
          self.related_area = nil
        end
      end
    end
  end
end