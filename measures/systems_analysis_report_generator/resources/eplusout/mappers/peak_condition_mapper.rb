module EPlusOut
  module Mappers
    class PeakConditionMapper < EPlusOut::Mappers::Mapper

      PARAM_MAP = [
          {:index => 0, :name => :difference_between_peak_and_estimated_sensible_load, :type => 'double'},
          {:index => 1, :name => :difference_due_to_sizing_factor, :type => 'double'},
          {:index => 2, :name => :estimate_instant_delayed_sensible_load, :type => 'double'},
          {:index => 3, :name => :main_fan_air_flow, :type => 'double'},
          {:index => 4, :name => :mixed_air_temperature, :type => 'double'},
          {:index => 5, :name => :outside_dry_bulb_temperature, :type => 'double'},
          {:index => 6, :name => :outside_wet_bulb_temperature, :type => 'double'},
          {:index => 7, :name => :outside_air_flow, :type => 'double'},
          {:index => 8, :name => :outside_humidity_ratio_at_peak, :type => 'double'},
          {:index => 9, :name => :peak_sensible_load, :type => 'double'},
          {:index => 10, :name => :peak_sensible_load_with_sizing_factor, :type => 'double'},
          {:index => 11, :name => :supply_air_temperature, :type => 'double'},
          {:index => 12, :name => :time_of_peak_load, :type => 'string'},
          {:index => 13, :name => :zone_dry_bulb_temperature, :type => 'double'},
          {:index => 14, :name => :zone_humidity_ratio_at_peak, :type => 'double'},
          {:index => 15, :name => :zone_relative_humidity, :type => 'double'},
      ]

      private
      def klass
        EPlusOut::Models::PeakCondition
      end

      def param_map
        PARAM_MAP
      end
    end
  end
end