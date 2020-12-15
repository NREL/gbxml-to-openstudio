module EPlusOut
  module Mappers
    class EngineeringCheckMapper < EPlusOut::Mappers::Mapper

      PARAM_MAP = [
          {:index => 0, :name => :airflow_per_floor_area, :type => 'double'},
          {:index => 1, :name => :airflow_per_total_capacity, :type => 'double'},
          {:index => 2, :name => :floor_area_per_total_capacity, :type => 'double'},
          {:index => 3, :name => :number_of_people, :type => 'double'},
          {:index => 4, :name => :outside_air_percent, :type => 'double'},
          {:index => 5, :name => :total_capacity_per_floor_area, :type => 'double'}
      ]

      def call(data)
        result = klass.new

        if data
          param_map.each do |param|
            if param[:name] == :outside_air_percent
              result.send("#{param[:name]}=", data[param[:index]] * 100)
            else
              result.send("#{param[:name]}=", data[param[:index]])
            end
          end
        end

        result
      end

      private
      def klass
        EPlusOut::Models::EngineeringCheck
      end

      def param_map
        PARAM_MAP
      end
    end
  end
end
