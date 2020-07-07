module EPlusOut
  module Models
    CoilSizingDetail = Struct.new(:name,
                                  :autosized_coil_airflow,
                                  :autosized_coil_capacity,
                                  :autosized_coil_water_flow,
                                  :coil_air_mass_flow_rate_at_ideal_loads_peak,
                                  :coil_air_mass_flow_rate_at_rating_conditions,
                                  :coil_air_volume_flow_rate_at_ideal_loads_peak,
                                  :coil_capacity_percentage_of_plant_design_capacity,
                                  :coil_entering_air_drybulb_at_ideal_loads_peak,
                                  :coil_entering_air_drybulb_at_rating_conditions,
                                  :coil_entering_air_enthalpy_at_ideal_loads_peak,
                                  :coil_entering_air_enthalpy_at_rating_conditions,
                                  :coil_entering_air_humidity_ratio_at_ideal_loads_peak,
                                  :coil_entering_air_humidity_ratio_at_rating_conditions,
                                  :coil_entering_air_wetbulb_at_ideal_loads_peak,
                                  :coil_entering_air_wetbulb_at_rating_conditions,
                                  :coil_entering_plant_fluid_temperature_at_ideal_loads_peak,
                                  :coil_final_gross_sensible_capacity,
                                  :coil_final_gross_total_capacity,
                                  :coil_final_reference_air_volume_flow_rate,
                                  :coil_final_reference_plant_fluid_volume_flow_rate,
                                  :coil_fluid_flow_rate_percentage_of_plant_design_flow_rate,
                                  :coil_leaving_air_drybulb_at_ideal_loads_peak,
                                  :coil_leaving_air_drybulb_at_rating_conditions,
                                  :coil_leaving_air_enthalpy_at_ideal_loads_peak,
                                  :coil_leaving_air_enthalpy_at_rating_conditions,
                                  :coil_leaving_air_humidity_ratio_at_ideal_loads_peak,
                                  :coil_leaving_air_humidity_ratio_at_rating_conditions,
                                  :coil_leaving_air_wetbulb_at_ideal_loads_peak,
                                  :coil_leaving_air_wetbulb_at_rating_conditions,
                                  :coil_leaving_plant_fluid_temperature_at_ideal_loads_peak,
                                  :coil_location,
                                  :coil_off_rating_capacity_modifier_at_ideal_loads_peak,
                                  :coil_plant_fluid_mass_flow_rate_at_ideal_loads_peak,
                                  :coil_plant_fluid_temperature_difference_at_ideal_loads_peak,
                                  :coil_sensible_capacity_at_ideal_loads_peak,
                                  :coil_sensible_capacity_at_rating_conditions,
                                  :coil_total_capacity_at_ideal_loads_peak,
                                  :coil_total_capacity_at_rating_conditions,
                                  :coil_type,
                                  :coil_u_value_times_area_value,
                                  :coil_and_fan_net_total_capacity_at_ideal_loads_peak,
                                  :dx_coil_capacity_decrease_ratio_from_too_high_flow_capacity_ratio,
                                  :dx_coil_capacity_increase_ratio_from_too_low_flow_capacity_ratio,
                                  :date_time_at_air_flow_ideal_loads_peak,
                                  :date_time_at_sensible_ideal_loads_peak,
                                  :date_time_at_total_ideal_loads_peak,
                                  :design_day_name_at_air_flow_ideal_loads_peak,
                                  :design_day_name_at_sensible_ideal_loads_peak,
                                  :design_day_name_at_total_ideal_loads_peak,
                                  :dry_air_heat_capacity,
                                  :hvac_name,
                                  :hvac_type,
                                  :moist_air_heat_capacity,
                                  :oa_pretreated_prior_to_coil_inlet,
                                  :outdoor_air_drybulb_at_ideal_loads_peak,
                                  :outdoor_air_flow_percentage_at_ideal_loads_peak,
                                  :outdoor_air_humidity_ratio_at_ideal_loads_peak,
                                  :outdoor_air_volume_flow_rate_at_ideal_loads_peak,
                                  :outdoor_air_wetbulb_at_ideal_loads_peak,
                                  :plant_design_capacity,
                                  :plant_design_fluid_return_temperature,
                                  :plant_design_fluid_supply_temperature,
                                  :plant_design_fluid_temperature_difference,
                                  :plant_fluid_density,
                                  :plant_fluid_specific_heat_capacity,
                                  :plant_maximum_fluid_mass_flow_rate,
                                  :plant_name_for_coil,
                                  :standard_air_density_adjusted_for_elevation,
                                  :supply_fan_air_heat_gain_at_ideal_loads_peak,
                                  :supply_fan_maximum_air_mass_flow_rate,
                                  :supply_fan_maximum_air_volume_flow_rate,
                                  :supply_fan_name_for_coil,
                                  :supply_fan_type_for_coil,
                                  :system_return_air_drybulb_at_ideal_loads_peak,
                                  :system_return_air_humidity_ratio_at_ideal_loads_peak,
                                  :system_sizing_method_air_flow,
                                  :system_sizing_method_capacity,
                                  :system_sizing_method_concurrence,
                                  :terminal_unit_reheat_coil_multiplier,
                                  :zone_air_drybulb_at_ideal_loads_peak,
                                  :zone_air_humidity_ratio_at_ideal_loads_peak,
                                  :zone_air_relative_humidity_at_ideal_loads_peak,
                                  :zone_latent_heat_gain_at_ideal_loads_peak,
                                  :zone_names,
                                  :zone_sensible_heat_gain_at_ideal_loads_peak) do
      include Models::Model

      Cpa = 1006 # J/(kg * C) Specific heat of air
      Hwe = 2501000 # J/kg heat of water evaporation
      Cpw = 1860 # J/kg Specific heat of water vapor

      def sensible_load
        moist_air_heat_capacity * standard_air_density_adjusted_for_elevation *
            outdoor_air_volume_flow_rate_at_ideal_loads_peak * (outdoor_air_drybulb_at_ideal_loads_peak -
            zone_air_drybulb_at_ideal_loads_peak)
      end

      def latent_load
        total_load - sensible_load
      end

      def total_load
        h_oa = calculate_enthalpy(outdoor_air_drybulb_at_ideal_loads_peak, outdoor_air_humidity_ratio_at_ideal_loads_peak)
        h_zone = calculate_enthalpy(zone_air_drybulb_at_ideal_loads_peak, zone_air_humidity_ratio_at_ideal_loads_peak)

        standard_air_density_adjusted_for_elevation * outdoor_air_volume_flow_rate_at_ideal_loads_peak *
            (h_oa - h_zone)
      end

      private
      def calculate_enthalpy(temperature_dry_bulb, humidity_ratio)
        (Cpa * temperature_dry_bulb + humidity_ratio * (Hwe + Cpw * temperature_dry_bulb))
      end
    end
  end
end