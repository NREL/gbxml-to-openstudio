module EPlusOut
  module Models
    PeakCondition = Struct.new(:name, :difference_between_peak_and_estimated_sensible_load, :difference_due_to_sizing_factor, :estimate_instant_delayed_sensible_load,
                                :main_fan_air_flow, :mixed_air_temperature, :outside_dry_bulb_temperature,
                                :outside_wet_bulb_temperature, :outside_air_flow, :outside_humidity_ratio_at_peak,
                                :peak_sensible_load, :peak_sensible_load_with_sizing_factor, :supply_air_temperature,
                                :time_of_peak_load, :zone_dry_bulb_temperature, :zone_humidity_ratio_at_peak,
                                :zone_relative_humidity) do
      include Models::Model
    end

  end
end