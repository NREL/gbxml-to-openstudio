require_relative 'jsonable'

class CoilSizingDetail < JSONable
  attr_accessor :coil_type, :coil_location, :hvac_type, :hvac_name, :zone_names, :sizing_method_concurrence,
                :sizing_method_capacity, :sizing_method_airflow, :autosized_capacity, :autosized_airflow, :autosized_waterflow,
                :oa_pretreated, :final_gross_total_capacity, :final_gross_sensible_capacity, :final_reference_airflow,
                :final_reference_fluidflow, :coil_ua, :tu_rh_coil_mult, :dx_capacity_increase_low_flow, :dx_capacity_decrease_high_flow,
                :moist_air_heat_capacity, :dry_air_heat_capacity, :standard_air_density, :supply_fan_name, :supply_fan_type,
                :supply_fan_max_airflow_rate, :supply_fan_max_massflow_rate, :plant_name, :plant_specific_heat_capacity,
                :plant_fluid_density, :plant_max_mass_flow_rate, :plant_design_fluid_return_temp, :plant_design_fluid_supply_temp,
                :plant_design_fluid_temp_diff, :plant_design_capacity, :cap_percent_of_plant_design, :flow_percent_of_plant_design,
                :design_day_name_sensible_peak, :datetime_sensible_peak, :design_day_name_total_peak, :datetime_total_peak,
                :design_day_name_flow_peak, :datetime_flow_peak, :cap_total_peak, :cap_sensible_peak, :cap_modifier_peak,
                :airmass_peak, :airflow_peak, :entering_drybulb_peak, :entering_wetbulb_peak, :entering_hr_peak, :entering_enth_peak,
                :leaving_drybulb_peak, :leaving_wetbulb_peak, :leaving_hr_peak, :leaving_enth_peak, :fluidmass_peak,
                :entering_plant_temp_peak, :leaving_plant_temp_peak, :plant_fluid_temp_diff_peak, :fan_heat_gain_peak, :oa_drybulb_peak,
                :oa_hr_peak, :oa_wetbulb_peak, :oa_airflow_peak, :oa_percent_peak, :system_return_drybulb_peak, :system_return_hr_peak,
                :zone_drybulb_peak, :zone_hr_peak, :zone_rh_peak, :zone_sensible_peak, :zone_latent_peak, :total_cap_rating,
                :sensible_cap_rating, :airmass_rating, :entering_drybulb_rating, :entering_wetbulb_rating, :entering_hr_rating,
                :entering_enth_rating, :leaving_drybulb_rating, :leaving_wetbulb_rating, :leaving_hr_rating, :leaving_enth_rating

  def initialize(options)
    @coil_type = options[:coil_type]
    @coil_location = options[:coil_location]
    @hvac_type = options[:hvac_type]
    @hvac_name = options[:hvac_name]
    @zone_names = options[:zone_names]
    @sizing_method_concurrence = options[:sizing_method_concurrence]
    @sizing_method_capacity = options[:sizing_method_capacity]
    @sizing_method_airflow = options[:sizing_method_airflow]
    @autosized_capacity = options[:autosized_capacity]
    @autosized_airflow = options[:autosized_airflow]
    @autosized_waterflow = options[:autosized_waterflow]
    @oa_pretreated = options[:oa_pretreated]
    @final_gross_total_capacity = options[:final_gross_total_capacity]
    @final_gross_sensible_capacity = options[:final_gross_sensible_capacity]
    @final_reference_airflow = options[:final_reference_airflow]
    @final_reference_fluidflow = options[:final_reference_fluidflow]
    @coil_ua = options[:coil_ua]
    @tu_rh_coil_mult = options[:tu_rh_coil_mult]
    @dx_capacity_increase_low_flow = options[:dx_capacity_increase_low_flow]
    @dx_capacity_decrease_high_flow = options[:dx_capacity_decrease_high_flow]
    @moist_air_heat_capacity = options[:moist_air_heat_capacity]
    @dry_air_heat_capacity = options[:dry_air_heat_capacity]
    @standard_air_density = options[:standard_air_density]
    @supply_fan_name = options[:supply_fan_name]
    @supply_fan_type = options[:supply_fan_type]
    @supply_fan_max_airflow_rate = options[:supply_fan_max_airflow_rate]
    @supply_fan_max_massflow_rate = options[:supply_fan_max_massflow_rate]
    @plant_name = options[:plant_name]
    @plant_specific_heat_capacity = options[:plant_specific_heat_capacity]
    @plant_fluid_density = options[:plant_fluid_density]
    @plant_max_mass_flow_rate = options[:plant_max_mass_flow_rate]
    @plant_design_fluid_return_temp = options[:plant_design_fluid_return_temp]
    @plant_design_fluid_supply_temp = options[:plant_design_fluid_supply_temp]
    @plant_design_fluid_temp_diff = options[:plant_design_fluid_temp_diff]
    @plant_design_capacity = options[:plant_design_capacity]
    @cap_percent_of_plant_design = options[:cap_percent_of_plant_design]
    @flow_percent_of_plant_design = options[:flow_percent_of_plant_design]
    @design_day_name_sensible_peak = options[:design_day_name_sensible_peak]
    @datetime_sensible_peak = options[:datetime_sensible_peak]
    @design_day_name_total_peak = options[:design_day_name_total_peak]
    @datetime_total_peak = options[:datetime_total_peak]
    @design_day_name_flow_peak = options[:design_day_name_flow_peak]
    @datetime_flow_peak = options[:datetime_flow_peak]
    @cap_total_peak = options[:cap_total_peak]
    @cap_sensible_peak = options[:cap_sensible_peak]
    @cap_modifier_peak = options[:cap_modifier_peak]
    @airmass_peak = options[:airmass_peak]
    @airflow_peak = options[:airflow_peak]
    @entering_drybulb_peak = options[:entering_drybulb_peak]
    @entering_wetbulb_peak = options[:entering_wetbulb_peak]
    @entering_hr_peak = options[:entering_hr_peak]
    @entering_enth_peak = options[:entering_enth_peak]
    @leaving_drybulb_peak = options[:leaving_drybulb_peak]
    @leaving_wetbulb_peak = options[:leaving_wetbulb_peak]
    @leaving_hr_peak = options[:leaving_hr_peak]
    @leaving_enth_peak = options[:leaving_enth_peak]
    @fluidmass_peak = options[:fluidmass_peak]
    @entering_plant_temp_peak = options[:entering_plant_temp_peak]
    @leaving_plant_temp_peak = options[:leaving_plant_temp_peak]
    @plant_fluid_temp_diff_peak = options[:plant_fluid_temp_diff_peak]
    @fan_heat_gain_peak = options[:fan_heat_gain_peak]
    @oa_drybulb_peak = options[:oa_drybulb_peak]
    @oa_hr_peak = options[:oa_hr_peak]
    @oa_wetbulb_peak = options[:oa_wetbulb_peak]
    @oa_airflow_peak = options[:oa_airflow_peak]
    @oa_percent_peak = options[:oa_percent_peak]
    @system_return_drybulb_peak = options[:system_return_drybulb_peak]
    @system_return_hr_peak = options[:system_return_hr_peak]
    @zone_drybulb_peak = options[:zone_drybulb_peak]
    @zone_hr_peak = options[:zone_hr_peak]
    @zone_rh_peak = options[:zone_rh_peak]
    @zone_sensible_peak = options[:zone_sensible_peak]
    @zone_latent_peak = options[:zone_latent_peak]
    @total_cap_rating = options[:total_cap_rating]
    @sensible_cap_rating = options[:sensible_cap_rating]
    @airmass_rating = options[:airmass_rating]
    @entering_drybulb_rating = options[:entering_drybulb_rating]
    @entering_wetbulb_rating = options[:entering_wetbulb_rating]
    @entering_hr_rating = options[:entering_hr_rating]
    @entering_enth_rating = options[:entering_enth_rating]
    @leaving_drybulb_rating = options[:leaving_drybulb_rating]
    @leaving_wetbulb_rating = options[:leaving_wetbulb_rating]
    @leaving_hr_rating = options[:leaving_hr_rating]
    @leaving_enth_rating = options[:leaving_enth_rating]
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

  def create_ventilation_peak_load_component
    rho = self.standard_air_density
    cfm_oa = self.oa_airflow_peak
    t_oa = self.oa_drybulb_peak
    t_zone = self.zone_drybulb_peak

    if t_oa and self.oa_hr_peak
      h_oa = calculate_enthalpy(t_oa, self.oa_hr_peak)
    end

    if t_zone and self.zone_hr_peak
      h_zone = calculate_enthalpy(t_zone, self.zone_hr_peak)
    end

    cp = self.moist_air_heat_capacity

    if cp and rho and cfm_oa and t_oa and t_zone and h_oa and h_zone
      sensible_load = cp * rho * cfm_oa * (t_oa - t_zone)
      total_load = rho * cfm_oa * (h_oa - h_zone)
      latent_load = total_load - sensible_load
      options = {
          :sensible_instant => sensible_load,
          :latent => latent_load,
          :total => total_load
      }

      PeakLoadComponent.new(options)
    else
      return nil
    end
  end

  def create_fan_peak_load_component
    if @fan_heat_gain_peak
      return PeakLoadComponent.new({:sensible_instant => @fan_heat_gain_peak})
    end
  end

  def calculate_enthalpy(t_db, w)
    (1.006 * t_db + w * (2501 + 1.86 * t_db)) * 1000
  end

  def calculate_fan_temperature_difference
    self.fan_heat_gain_peak / (self.moist_air_heat_capacity * self.airmass_peak)
  end
end




