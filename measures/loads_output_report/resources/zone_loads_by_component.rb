require_relative 'jsonable'

class ZoneLoadsByComponent < JSONable
  attr_accessor :cad_object_id, :cooling_peak_load_component_table, :cooling_peak_condition_table,
                :cooling_engineering_check_table, :heating_peak_load_component_table, :heating_peak_condition_table,
                :heating_engineering_check_table
end
