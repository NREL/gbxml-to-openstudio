require_relative 'jsonable'

class FanEquipmentSummary < JSONable
  attr_accessor :type, :total_efficiency, :delta_pressure, :max_air_flow_rate, :rated_electric_power,
                :rated_power_per_max_air_flow_rate, :motor_heat_in_air_fraction, :end_use,
                :design_day_name_for_fan_sizing_peak, :date_time_for_fan_sizing_peak, :fan_energy_index

  def self.from_options(options)
    fan = new

    fan.type = options[:type]
    fan.total_efficiency = options[:total_efficiency]
    fan.delta_pressure = options[:delta_pressure]
    fan.fan_energy_index = options[:fan_energy_index]
    fan.max_air_flow_rate = options[:max_air_flow_rate]
    fan.rated_electric_power = options[:rated_electric_power]
    fan.rated_power_per_max_air_flow_rate = options[:rated_power_per_max_air_flow_rate]
    fan.motor_heat_in_air_fraction = options[:motor_heat_in_air_fraction]
    fan.end_use = options[:end_use]
    fan.design_day_name_for_fan_sizing_peak = options[:design_day_name_for_fan_sizing_peak]
    fan.date_time_for_fan_sizing_peak = options[:date_time_for_fan_sizing_peak]

    fan
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