class CoolingCoilComponentSummary
  attr_accessor :sizing_method, :time_of_peak, :total_capacity, :sensible_capacity, :ventilation_load, :ov_undr_sizing,
                :air_flow, :enter_db, :enter_hr, :leave_db, :leave_hr, :water_flow, :water_enter_temp, :water_leave_temp

  def self.from_coil_sizing_detail(coil_sizing_detail)

  end
end