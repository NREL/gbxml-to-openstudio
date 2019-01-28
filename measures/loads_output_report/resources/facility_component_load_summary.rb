require_relative 'jsonable'

class FacilityComponentLoadSummary < JSONable
  attr_accessor :cooling_peak_load_component_table, :cooling_peak_condition_table_repository, :cooling_engineering_check_table,
                :heating_peak_load_component_table, :heating_peak_condition_table_repository, :heating_engineering_check_table
end