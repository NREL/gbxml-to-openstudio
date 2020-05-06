module SystemsAnalysisReport
  module Mappers
    class EngineeringCheckMapper
      def call(peak_load_component_table, peak_condition, engineering_check)
        floor_area = peak_load_component_table.floor_area
        total_capacity = peak_load_component_table.grand_total.total

        result = EPlusOut::Models::EngineeringCheck.new
        result.outside_air_percent = engineering_check.outside_air_percent # don't recalculate because of E+ output precision
        result.airflow_per_floor_area = peak_condition.main_fan_air_flow / floor_area  if floor_area > 0
        result.airflow_per_total_capacity = peak_condition.main_fan_air_flow / total_capacity if total_capacity > 0
        result.floor_area_per_total_capacity = floor_area / total_capacity  if total_capacity > 0
        result.total_capacity_per_floor_area = total_capacity / floor_area  if floor_area > 0
        result.number_of_people = engineering_check.number_of_people

        result
      end
    end
  end
end