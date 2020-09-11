module EPlusOut
  module Mappers
    class EstimatedPeakLoadComponentMapper

      PARAM_MAP = [
          {:index => 0, :name => :percent_grand_total, :type => 'double'},
          {:index => 1, :name => :latent, :type => 'double'},
          {:index => 2, :name => :related_area, :type => 'double'},
          {:index => 3, :name => :sensible_delayed, :type => 'double'},
          {:index => 4, :name => :sensible_instant, :type => 'double'},
          {:index => 5, :name => :sensible_return_air, :type => 'double'},
          {:index => 6, :name => :total, :type => 'double'},
          {:index => 7, :name => :total_per_area, :type => 'double'}
      ]

      def call(data)
        result = klass.new

        if data
          param_map.each do |param|
            result.send("#{param[:name]}=", data[param[:index]])
          end
        end

        result
      end

      def size
        param_map.size
      end

      private
      def klass
        EPlusOut::Models::EstimatedPeakLoadComponent
      end

      def param_map
        PARAM_MAP
      end
    end
  end
end