class LoadAirflowSummary < JSONable
  attr_accessor :cad_object_id, :cooling_time_of_peak, :cooling_supply_air_flow, :cooling_sensible_load,
                :heating_time_of_peak, :heating_supply_air_flow, :heating_sensible_load

  def self.from_zone_sensible_summary(cooling_zone_sensible_summary = nil, heating_zone_sensible_summary = nil)
    summary = new

    if cooling_zone_sensible_summary
      summary.cooling_time_of_peak = cooling_zone_sensible_summary.date_time_of_peak
      summary.cooling_supply_air_flow = cooling_zone_sensible_summary.user_design_air_flow
      summary.cooling_sensible_load = cooling_zone_sensible_summary.user_design_load
    end

    if heating_zone_sensible_summary
      summary.heating_time_of_peak = heating_zone_sensible_summary.date_time_of_peak
      summary.heating_supply_air_flow = heating_zone_sensible_summary.user_design_air_flow
      summary.heating_sensible_load = heating_zone_sensible_summary.user_design_load
    end

    summary
  end
end