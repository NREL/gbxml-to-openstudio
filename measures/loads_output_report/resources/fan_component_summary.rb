class FanComponentSummary < JSONable
  attr_accessor :cad_object_id, :total_efficiency, :static_pressure, :flow_rate, :power, :motor_heat_in_air_fraction

  def self.from_fan_equipment_summary(fan_equipment_summary)
    summary = new
    summary.total_efficiency = fan_equipment_summary.total_efficiency
    summary.static_pressure = fan_equipment_summary.delta_pressure
    summary.flow_rate = fan_equipment_summary.max_air_flow_rate
    summary.power = fan_equipment_summary.rated_electric_power
    summary.motor_heat_in_air_fraction = fan_equipment_summary.motor_heat_in_air_fraction

    summary
  end
end