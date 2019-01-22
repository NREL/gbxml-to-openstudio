require_relative 'peak_load_component_table'

class SystemChecksumPeakLoadComponentTable < PeakLoadComponentTable
  attr_accessor :peak_load_component_table, :ventilation, :supply_fan_heat, :time_delay_correction_factor, :sizing_factor_correction,
                :airflow_correction

  def initialize(peak_load_component_table)
    self.peak_load_component_table = peak_load_component_table
  end

  # Todo: change this method
  def to_hash
    base_hash = self.peak_load_component_table.to_hash

    instance_hash = instance_variables.select {|iv| iv.to_s !=  '@peak_load_component_table'}.map do |iv|
        value = instance_variable_get(:"#{iv}")
        [
            iv.to_s[1..-1], # name without leading `@`
            case value
            when JSONable then value.to_hash # Base instance? convert deeply
            when Array # Array? convert elements
              value.map do |e|
                e.respond_to?(:to_h) ? e.to_hash : e
              end
            else value # seems to be non-convertable, put as is
            end
        ]
    end.to_h

    base_hash.merge(instance_hash)
  end
end