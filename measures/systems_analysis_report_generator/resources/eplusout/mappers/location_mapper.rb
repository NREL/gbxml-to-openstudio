module EPlusOut
  module Mappers
    class LocationMapper < EPlusOut::Mappers::Mapper

      PARAM_MAP = [
          {:index => 0, :name => :elevation, :type => 'double'},
          {:index => 1, :name => :latitude, :type => 'double'},
          {:index => 2, :name => :location_name, :type => 'string'},
          {:index => 3, :name => :longitude, :type => 'double'},
          {:index => 4, :name => :standard_pressure_at_elevation, :type => 'double'},
          {:index => 5, :name => :standard_rhoair_at_elevation, :type => 'double'},
          {:index => 6, :name => :time_zone_number, :type => 'double'}
      ]

      private
      def klass
        EPlusOut::Models::Location
      end

      def param_map
        PARAM_MAP
      end
    end
  end
end