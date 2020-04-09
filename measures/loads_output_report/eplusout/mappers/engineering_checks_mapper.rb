﻿module EPlusOut
  module Mappers
    class EngineeringChecksMapper < EPlusOut::Mappers::Mapper

      PARAM_MAP = [
          {:index => 0, :name => :airflow_per_floor_area, :type => 'double'},
          {:index => 1, :name => :airflow_per_total_cap, :type => 'double'},
          {:index => 2, :name => :floor_area_per_total_cap, :type => 'double'},
          {:index => 3, :name => :number_of_people, :type => 'double'},
          {:index => 4, :name => :oa_percent, :type => 'double'},
          {:index => 5, :name => :total_cap_per_floor_area, :type => 'double'}
      ]

      def klass
        EPlusOut::EngineeringChecks
      end

      def param_map
        PARAM_MAP
      end
    end
  end
end
