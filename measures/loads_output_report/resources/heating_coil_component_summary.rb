class HeatingCoilComponentSummary
  attr_accessor :time_of_peak, :total_capacity, :ventilation_load, :ov_undr_sizing, :air_flow, :air_enter_db,
                :air_leave_db, :water_flow, :water_enter_temp, :water_leave_temp

  def self.from_coil_sizing_detail(coil_sizing_detail)

  end
end