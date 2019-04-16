class CoolingCoilComponentSummary < JSONable
  attr_accessor :cad_object_id, :sizing_method, :time_of_peak, :total_capacity, :sensible_capacity, :ventilation_load, :ov_undr_sizing,
                :air_flow, :enter_db, :enter_hr, :leave_db, :leave_hr, :water_flow, :water_enter_temp, :water_leave_temp

  def self.from_coil_sizing_detail(coil_sizing_detail)
    summary = new

    summary.sizing_method = coil_sizing_detail.sizing_method_concurrence
    summary.time_of_peak = coil_sizing_detail.datetime_sensible_peak
    summary.total_capacity = coil_sizing_detail.final_gross_total_capacity
    summary.sensible_capacity = coil_sizing_detail.final_gross_sensible_capacity
    ventilation_peak_load_component = coil_sizing_detail.create_ventilation_peak_load_component
    summary.ventilation_load = ventilation_peak_load_component.total if ventilation_peak_load_component
    summary.ov_undr_sizing = nil
    summary.air_flow = coil_sizing_detail.final_reference_airflow
    summary.enter_db = coil_sizing_detail.entering_drybulb_peak
    summary.enter_hr = coil_sizing_detail.entering_hr_peak
    summary.leave_db = coil_sizing_detail.leaving_drybulb_peak
    summary.leave_hr = coil_sizing_detail.leaving_hr_peak
    summary.water_flow = coil_sizing_detail.final_reference_fluidflow
    summary.water_enter_temp = coil_sizing_detail.entering_plant_temp_peak
    summary.water_leave_temp = coil_sizing_detail.leaving_plant_temp_peak

    summary
  end

end