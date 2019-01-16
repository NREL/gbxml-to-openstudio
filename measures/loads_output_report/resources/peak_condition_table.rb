require_relative 'jsonable'

class PeakConditionTable < JSONable
  attr_accessor :time_of_peak_load, :oa_drybulb, :oa_wetbulb, :oa_hr, :zone_drybulb, :zone_rh, :zone_hr, :sat, :mat,
                :fan_flow, :oa_flow, :sensible_peak_sf, :sf_diff, :sensible_peak, :estimate_instant_delayed_sensible,
                :peak_estimate_diff

  def initialize(options)
    @time_of_peak_load = options[:time_of_peak_load]
    @oa_drybulb = options[:oa_drybulb]
    @oa_wetbulb = options[:oa_wetbulb]
    @oa_hr = options[:oa_hr]
    @zone_drybulb = options[:zone_drybulb]
    @zone_rh = options[:zone_rh]
    @zone_hr = options[:zone_hr]
    @sat = options[:sat]
    @mat = options[:mat]
    @fan_flow = options[:fan_flow]
    @oa_flow = options[:oa_flow]
    @sensible_peak_sf = options[:sensible_peak_sf]
    @sf_diff = options[:sf_diff]
    @sensible_peak = options[:sensible_peak]
    @estimate_instant_delayed_sensible = options[:estimate_instant_delayed_sensible]
    @peak_estimate_diff = options[:peak_estimate_diff]
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