module EPlusOut
  module Mappers
    class EstimatedPeakLoadComponentTableMapper < EPlusOut::Mappers::Mapper
      attr_reader :estimated_peak_load_component_mapper

      PARAM_MAP = [
          {:index => 0, :name => :doas_direct_to_zone},
          {:index => 1, :name => :equipment},
          {:index => 2, :name => :exterior_floor},
          {:index => 3, :name => :exterior_wall},
          {:index => 4, :name => :fenestration_conduction},
          {:index => 5, :name => :fenestration_solar},
          {:index => 6, :name => :grand_total},
          {:index => 7, :name => :ground_contact_floor},
          {:index => 8, :name => :ground_contact_wall},
          {:index => 9, :name => :hvac_equipment_loss},
          {:index => 10, :name => :infiltration},
          {:index => 11, :name => :interzone_ceiling},
          {:index => 12, :name => :interzone_floor},
          {:index => 13, :name => :interzone_mixing},
          {:index => 14, :name => :interzone_wall},
          {:index => 15, :name => :lights},
          {:index => 16, :name => :opaque_door},
          {:index => 17, :name => :other_floor},
          {:index => 18, :name => :other_roof},
          {:index => 19, :name => :other_wall},
          {:index => 20, :name => :people},
          {:index => 21, :name => :power_generation_equipment},
          {:index => 22, :name => :refrigeration},
          {:index => 23, :name => :roof},
          {:index => 24, :name => :water_use_equipment},
          {:index => 25, :name => :zone_ventilation}
      ]

      def initialize(estimated_peak_load_component_mapper = EstimatedPeakLoadComponentMapper.new)
        @estimated_peak_load_component_mapper = estimated_peak_load_component_mapper
      end

      def size
        param_map.size * @estimated_peak_load_component_mapper.size
      end

      def call(data)
        result = klass.new

        param_map.each do |param|
          start_index = param[:index] * 8
          end_index = start_index + 7
          result.send("#{param[:name]}=", @estimated_peak_load_component_mapper.(data[start_index..end_index]))
        end

        return result
      end

      private
      def klass
        EPlusOut::Models::EstimatedPeakLoadComponentTable
      end

      def param_map
        PARAM_MAP
      end
    end
  end
end