require_relative 'jsonable'

class SystemChecksum
  attr_accessor :cooling_peak_load_component_table, :cooling_peak_condition_table_repository, :cooling_engineering_check_table,
                :heating_peak_load_component_table, :heating_peak_condition_table_repository, :heating_engineering_check_table,
                :cooling_coil_sizing_detail, :heating_coil_sizing_detail

  def calculate_additional_results
    calculate_ventilation_load
    calculate_fan_load
  end

  def calculate_ventilation_load
    cooling_ventilation = self.cooling_coil_sizing_detail.create_ventilation_peak_load_component if self.cooling_coil_sizing_detail
    if cooling_ventilation
      self.cooling_peak_load_component_table.ventilation = cooling_ventilation
    end

    heating_ventilation = self.heating_coil_sizing_detail.create_ventilation_peak_load_component if self.heating_coil_sizing_detail
    if heating_ventilation
      self.heating_peak_load_component_table.ventilation = heating_ventilation
    end
  end

  def calculate_fan_load
    cooling_fan_peak_load_component = self.cooling_coil_sizing_detail.create_fan_peak_load_component if self.cooling_coil_sizing_detail
    if cooling_fan_peak_load_component
      self.cooling_peak_load_component_table.supply_fan_heat = cooling_fan_peak_load_component
    end

    heating_fan_peak_load_component = self.heating_coil_sizing_detail.create_fan_peak_load_component if self.heating_coil_sizing_detail
    if heating_fan_peak_load_component
      self.heating_peak_load_component_table.supply_fan_heat = heating_fan_peak_load_component
    end
  end

  def to_hash
    instance_hash = instance_variables.map do |iv|
      unless ['@cooling_coil_sizing_detail', '@heating_coil_sizing_detail'].include? iv
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
      end
    end.to_h
  end
end