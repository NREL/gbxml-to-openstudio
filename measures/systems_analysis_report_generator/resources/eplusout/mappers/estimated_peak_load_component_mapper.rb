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
            result.send("#{param[:name]}=", cast_type(data[param[:index]], param[:type]))
          end
        end

        return result
      end

      private
      def klass
        EPlusOut::Models::EstimatedPeakLoadComponent
      end

      def param_map
        PARAM_MAP
      end

      def cast_type(value, type)
        return nil if value.nil? || value.empty?

        return value.to_f if type=="double"

        value
      end
    end
  end
end