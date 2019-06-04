class ZoneSensibleSummary < JSONable
  attr_accessor :calculated_design_load, :user_design_load, :user_design_load_per_area, :calculated_design_air_flow,
                :user_design_air_flow, :design_day_name, :date_time_of_peak, :thermostat_setpoint_temperature_at_peak_load,
                :indoor_temperature_at_peak_load, :indoor_humidity_ratio_at_peak_load, :outdoor_temperature_at_peak_load,
                :outdoor_humidity_ratio_at_peak_load, :minimum_outdoor_air_flow_rate, :heat_gain_rate_from_doas

  def self.from_options(options)
    summary = new

    summary.calculated_design_load = options[:calculated_design_load]
    summary.user_design_load = options[:user_design_load]
    summary.user_design_load_per_area = options[:user_design_load_per_area]
    summary.calculated_design_air_flow = options[:calculated_design_air_flow]
    summary.user_design_air_flow = options[:user_design_air_flow]
    summary.design_day_name = options[:design_day_name]
    summary.date_time_of_peak = options[:date_time_of_peak]
    summary.thermostat_setpoint_temperature_at_peak_load = options[:thermostat_setpoint_temperature_at_peak_load]
    summary.indoor_temperature_at_peak_load = options[:indoor_temperature_at_peak_load]
    summary.indoor_humidity_ratio_at_peak_load = options[:indoor_humidity_ratio_at_peak_load]
    summary.outdoor_temperature_at_peak_load = options[:outdoor_temperature_at_peak_load]
    summary.outdoor_humidity_ratio_at_peak_load = options[:outdoor_humidity_ratio_at_peak_load]
    summary.minimum_outdoor_air_flow_rate = options[:minimum_outdoor_air_flow_rate]
    summary.heat_gain_rate_from_doas = options[:heat_gain_rate_from_doas]

    summary
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