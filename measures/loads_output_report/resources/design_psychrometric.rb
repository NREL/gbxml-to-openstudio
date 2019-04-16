class DesignPsychrometric < JSONable
  attr_accessor :cad_object_id, :time_of_peak, :coil_air_flow, :zone_sensible_load, :oa_flow_rate, :percent_oa,
                :air_specific_heat, :air_density, :zone_drybulb, :zone_hr, :zone_rh, :return_air_drybulb, :return_air_hr,
                :oa_drybulb, :oa_hr, :entering_coil_drybulb, :entering_coil_hr, :leaving_coil_drybulb, :leaving_coil_hr,
                :supply_fan_temp_diff

  def initialize(coil_sizing_details)
    if coil_sizing_details
      # @system_cad_object_id = coil_sizing_details.system_cad_object_id
      @time_of_peak = coil_sizing_details.datetime_total_peak
      @coil_air_flow = coil_sizing_details.final_reference_airflow
      @zone_sensible_load = coil_sizing_details.cap_sensible_peak
      @oa_flow_rate = coil_sizing_details.oa_airflow_peak
      @percent_oa = coil_sizing_details.oa_percent_peak
      @air_specific_heat = coil_sizing_details.moist_air_heat_capacity
      @air_density = coil_sizing_details.standard_air_density
      @zone_drybulb = coil_sizing_details.zone_drybulb_peak
      @zone_hr = coil_sizing_details.zone_hr_peak
      @zone_rh = coil_sizing_details.zone_rh_peak
      @return_air_drybulb = coil_sizing_details.system_return_drybulb_peak
      @return_air_hr = coil_sizing_details.system_return_hr_peak
      @oa_drybulb = coil_sizing_details.oa_drybulb_peak
      @oa_hr = coil_sizing_details.oa_hr_peak
      @entering_coil_drybulb = coil_sizing_details.entering_drybulb_peak
      @entering_coil_hr = coil_sizing_details.entering_hr_peak
      @leaving_coil_drybulb = coil_sizing_details.leaving_drybulb_peak
      @leaving_coil_hr = coil_sizing_details.leaving_hr_peak
      @supply_fan_temp_diff = coil_sizing_details.calculate_fan_temperature_difference
    end
  end

  def ==(other)
    equal = true
    self.instance_variables.each do |variable|
      unless self.instance_variable_get(variable) == other.instance_variable_get(variable)
        equal = false
        break
      end
    end

    return equal
  end
end