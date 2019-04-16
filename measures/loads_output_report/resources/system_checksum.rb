require_relative 'jsonable'

class SystemChecksum
  attr_accessor :cad_object_id, :cooling_peak_load_component_table, :cooling_peak_condition_table,
                :cooling_engineering_check_table, :heating_peak_load_component_table, :heating_peak_condition_table,
                :heating_engineering_check_table, :cooling_coil_sizing_detail, :heating_coil_sizing_detail

  def calculate_additional_results
    calculate_ventilation_load
    calculate_fan_load
  end

  def calculate_ventilation_load
    if self.cooling_coil_sizing_detail
      cooling_ventilation = self.cooling_coil_sizing_detail.create_ventilation_peak_load_component
      self.cooling_peak_load_component_table.ventilation = cooling_ventilation
    end

    if self.heating_coil_sizing_detail
      heating_ventilation = self.heating_coil_sizing_detail.create_ventilation_peak_load_component
      self.heating_peak_load_component_table.ventilation = heating_ventilation
    end
  end

  def calculate_fan_load
    if self.cooling_coil_sizing_detail
      cooling_fan_peak_load_component = self.cooling_coil_sizing_detail.create_fan_peak_load_component
      self.cooling_peak_load_component_table.supply_fan_heat = cooling_fan_peak_load_component
    end

    if self.heating_coil_sizing_detail
      heating_fan_peak_load_component = self.heating_coil_sizing_detail.create_fan_peak_load_component
      self.heating_peak_load_component_table.supply_fan_heat = heating_fan_peak_load_component
    end
  end

  def to_hash
    instance_variables
        .select {|iv| !['@cooling_coil_sizing_detail', '@heating_coil_sizing_detail'].include? iv.to_s}
        .map do |iv|
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
  end
end