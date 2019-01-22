require_relative '../coil_sizing_detail'

class CoilSizingDetailRepository
  attr_accessor :sql_file

  BASE_QUERY = "SELECT Value FROM TabularDataWithStrings WHERE ReportName == 'CoilSizingDetails'"
  PARAM_MAP = [
      {:db_name => 'Coil Type', :param_name => 'coil_type', :param_type => 'string'},
      {:db_name => 'Coil Location', :param_name => 'coil_location', :param_type => 'string'},
      {:db_name => 'HVAC Type', :param_name => 'hvac_type', :param_type => 'string'},
      {:db_name => 'HVAC Name', :param_name => 'hvac_name', :param_type => 'string'},
      {:db_name => 'Zone Name(s)', :param_name => 'zone_names', :param_type => 'string'},
      {:db_name => 'System Sizing Method Concurrence', :param_name => 'sizing_method_concurrence', :param_type => 'string'},
      {:db_name => 'System Sizing Method Capacity', :param_name => 'sizing_method_capacity', :param_type => 'string'},
      {:db_name => 'System Sizing Method Air Flow', :param_name => 'sizing_method_airflow', :param_type => 'string'},
      {:db_name => 'Autosized Coil Capacity?', :param_name => 'autosized_capacity', :param_type => 'string'},
      {:db_name => 'Autosized Coil Airflow?', :param_name => 'autosized_airflow', :param_type => 'string'},
      {:db_name => 'Autosized Coil Water Flow?', :param_name => 'autosized_waterflow', :param_type => 'string'},
      {:db_name => 'OA Pretreated prior to coil inlet?', :param_name => 'oa_pretreated', :param_type => 'string'},
      {:db_name => 'Coil Final Gross Total Capacity', :param_name => 'final_gross_total_capacity', :param_type => 'double'},
      {:db_name => 'Coil Final Gross Sensible Capacity', :param_name => 'final_gross_sensible_capacity', :param_type => 'double'},
      {:db_name => 'Coil Final Reference Air Volume Flow Rate', :param_name => 'final_reference_airflow', :param_type => 'double'},
      {:db_name => 'Coil Final Reference Plant Fluid Volume Flow Rate', :param_name => 'final_reference_fluidflow', :param_type => 'double'},
      {:db_name => 'Coil U-value Times Area Value', :param_name => 'coil_ua', :param_type => 'double'},
      {:db_name => 'Terminal Unit Reheat Coil Multiplier', :param_name => 'tu_rh_coil_mult', :param_type => 'double'},
      {:db_name => 'DX Coil Capacity Increase Ratio from Too Low Flow/Capacity Ratio', :param_name => 'dx_capacity_increase_low_flow', :param_type => 'double'},
      {:db_name => 'DX Coil Capacity Decrease Ratio from Too High Flow/Capacity Ratio', :param_name => 'dx_capacity_decrease_high_flow', :param_type => 'double'},
      {:db_name => 'Moist Air Heat Capacity', :param_name => 'moist_air_heat_capacity', :param_type => 'double'},
      {:db_name => 'Dry Air Heat Capacity', :param_name => 'dry_air_heat_capacity', :param_type => 'double'},
      {:db_name => 'Standard Air Density Adjusted for Elevation', :param_name => 'standard_air_density', :param_type => 'double'},
      {:db_name => 'Supply Fan Name for Coil', :param_name => 'supply_fan_name', :param_type => 'string'},
      {:db_name => 'Supply Fan Type for Coil', :param_name => 'supply_fan_type', :param_type => 'string'},
      {:db_name => 'Supply Fan Maximum Air Volume Flow Rate', :param_name => 'supply_fan_max_airflow_rate', :param_type => 'double'},
      {:db_name => 'Supply Fan Maximum Air Mass Flow Rate', :param_name => 'supply_fan_max_massflow_rate', :param_type => 'double'},
      {:db_name => 'Plant Name for Coil', :param_name => 'plant_name', :param_type => 'string'},
      {:db_name => 'Plant Fluid Specific Heat Capacity', :param_name => 'plant_specific_heat_capacity', :param_type => 'double'},
      {:db_name => 'Plant Fluid Density', :param_name => 'plant_fluid_density', :param_type => 'double'},
      {:db_name => 'Plant Maximum Fluid Mass Flow Rate', :param_name => 'plant_max_mass_flow_rate', :param_type => 'double'},
      {:db_name => 'Plant Design Fluid Return Temperature', :param_name => 'plant_design_fluid_return_temp', :param_type => 'double'},
      {:db_name => 'Plant Design Fluid Supply Temperature', :param_name => 'plant_design_fluid_supply_temp', :param_type => 'double'},
      {:db_name => 'Plant Design Fluid Temperature Difference', :param_name => 'plant_design_fluid_temp_diff', :param_type => 'double'},
      {:db_name => 'Plant Design Capacity', :param_name => 'plant_design_capacity', :param_type => 'double'},
      {:db_name => 'Coil Capacity Percentage of Plant Design Capacity', :param_name => 'cap_percent_of_plant_design', :param_type => 'double'},
      {:db_name => 'Coil Fluid Flow Rate Percentage of Plant Design Flow Rate', :param_name => 'flow_percent_of_plant_design', :param_type => 'double'},
      {:db_name => 'Design Day Name at Sensible Ideal Loads Peak', :param_name => 'design_day_name_sensible_peak', :param_type => 'string'},
      {:db_name => 'Date/Time at Sensible Ideal Loads Peak', :param_name => 'datetime_sensible_peak', :param_type => 'string'},
      {:db_name => 'Design Day Name at Total Ideal Loads Peak', :param_name => 'design_day_name_total_peak', :param_type => 'string'},
      {:db_name => 'Date/Time at Total Ideal Loads Peak', :param_name => 'datetime_total_peak', :param_type => 'string'},
      {:db_name => 'Design Day Name at Air Flow Ideal Loads Peak', :param_name => 'design_day_name_flow_peak', :param_type => 'string'},
      {:db_name => 'Date/Time at Air Flow Ideal Loads Peak', :param_name => 'datetime_flow_peak', :param_type => 'string'},
      {:db_name => 'Coil Total Capacity at Ideal Loads Peak', :param_name => 'cap_total_peak', :param_type => 'double'},
      {:db_name => 'Coil Sensible Capacity at Ideal Loads Peak', :param_name => 'cap_sensible_peak', :param_type => 'double'},
      {:db_name => 'Coil Off-Rating Capacity Modifier at Ideal Loads Peak', :param_name => 'cap_modifier_peak', :param_type => 'double'},
      {:db_name => 'Coil Air Mass Flow Rate at Ideal Loads Peak', :param_name => 'airmass_peak', :param_type => 'double'},
      {:db_name => 'Coil Air Volume Flow Rate at Ideal Loads Peak', :param_name => 'airflow_peak', :param_type => 'double'},
      {:db_name => 'Coil Entering Air Drybulb at Ideal Loads Peak', :param_name => 'entering_drybulb_peak', :param_type => 'double'},
      {:db_name => 'Coil Entering Air Wetbulb at Ideal Loads Peak', :param_name => 'entering_wetbulb_peak', :param_type => 'double'},
      {:db_name => 'Coil Entering Air Humidity Ratio at Ideal Loads Peak', :param_name => 'entering_hr_peak', :param_type => 'double'},
      {:db_name => 'Coil Entering Air Enthalpy at Ideal Loads Peak', :param_name => 'entering_enth_peak', :param_type => 'double'},
      {:db_name => 'Coil Leaving Air Drybulb at Ideal Loads Peak', :param_name => 'leaving_drybulb_peak', :param_type => 'double'},
      {:db_name => 'Coil Leaving Air Wetbulb at Ideal Loads Peak', :param_name => 'leaving_wetbulb_peak', :param_type => 'double'},
      {:db_name => 'Coil Leaving Air Humidity Ratio at Ideal Loads Peak', :param_name => 'leaving_hr_peak', :param_type => 'double'},
      {:db_name => 'Coil Leaving Air Enthalpy at Ideal Loads Peak', :param_name => 'leaving_enth_peak', :param_type => 'double'},
      {:db_name => 'Coil Plant Fluid Mass Flow Rate at Ideal Loads Peak', :param_name => 'fluidmass_peak', :param_type => 'double'},
      {:db_name => 'Coil Entering Plant Fluid Temperature at Ideal Loads Peak', :param_name => 'entering_plant_temp_peak', :param_type => 'double'},
      {:db_name => 'Coil Leaving Plant Fluid Temperature at Ideal Loads Peak', :param_name => 'leaving_plant_temp_peak', :param_type => 'double'},
      {:db_name => 'Coil Plant Fluid Temperature Difference at Ideal Loads Peak', :param_name => 'plant_fluid_temp_diff_peak', :param_type => 'double'},
      {:db_name => 'Supply Fan Air Heat Gain at Ideal Loads Peak', :param_name => 'fan_heat_gain_peak', :param_type => 'double'},
      {:db_name => 'Outdoor Air Drybulb at Ideal Loads Peak', :param_name => 'oa_drybulb_peak', :param_type => 'double'},
      {:db_name => 'Outdoor Air Humidity Ratio at Ideal Loads Peak', :param_name => 'oa_hr_peak', :param_type => 'double'},
      {:db_name => 'Outdoor Air Wetbulb at Ideal Loads Peak', :param_name => 'oa_wetbulb_peak', :param_type => 'double'},
      {:db_name => 'Outdoor Air Volume Flow Rate at Ideal Loads Peak', :param_name => 'oa_airflow_peak', :param_type => 'double'},
      {:db_name => 'Outdoor Air Flow Percentage at Ideal Loads Peak', :param_name => 'oa_percent_peak', :param_type => 'double'},
      {:db_name => 'System Return Air Drybulb at Ideal Loads Peak', :param_name => 'system_return_drybulb_peak', :param_type => 'double'},
      {:db_name => 'System Return Air Humidity Ratio at Ideal Loads Peak', :param_name => 'system_return_hr_peak', :param_type => 'double'},
      {:db_name => 'Zone Air Drybulb at Ideal Loads Peak', :param_name => 'zone_drybulb_peak', :param_type => 'double'},
      {:db_name => 'Zone Air Humidity Ratio at Ideal Loads Peak', :param_name => 'zone_hr_peak', :param_type => 'double'},
      {:db_name => 'Zone Air Relative Humidity at Ideal Loads Peak', :param_name => 'zone_rh_peak', :param_type => 'double'},
      {:db_name => 'Zone Sensible Heat Gain at Ideal Loads Peak', :param_name => 'zone_sensible_peak', :param_type => 'double'},
      {:db_name => 'Zone Latent Heat Gain at Ideal Loads Peak', :param_name => 'zone_latent_peak', :param_type => 'double'},
      {:db_name => 'Coil Total Capacity at Rating Conditions', :param_name => 'total_cap_rating', :param_type => 'double'},
      {:db_name => 'Coil Sensible Capacity at Rating Conditions', :param_name => 'sensible_cap_rating', :param_type => 'double'},
      {:db_name => 'Coil Air Mass Flow Rate at Rating Conditions', :param_name => 'airmass_rating', :param_type => 'double'},
      {:db_name => 'Coil Entering Air Drybulb at Rating Conditions', :param_name => 'entering_drybulb_rating', :param_type => 'double'},
      {:db_name => 'Coil Entering Air Wetbulb at Rating Conditions', :param_name => 'entering_wetbulb_rating', :param_type => 'double'},
      {:db_name => 'Coil Entering Air Humidity Ratio at Rating Conditions', :param_name => 'entering_hr_rating', :param_type => 'double'},
      {:db_name => 'Coil Entering Air Enthalpy at Rating Conditions', :param_name => 'entering_enth_rating', :param_type => 'double'},
      {:db_name => 'Coil Leaving Air Drybulb at Rating Conditions', :param_name => 'leaving_drybulb_rating', :param_type => 'double'},
      {:db_name => 'Coil Leaving Air Wetbulb at Rating Conditions', :param_name => 'leaving_wetbulb_rating', :param_type => 'double'},
      {:db_name => 'Coil Leaving Air Humidity Ratio at Rating Conditions', :param_name => 'leaving_hr_rating', :param_type => 'double'},
      {:db_name => 'Coil Leaving Air Enthalpy at Rating Conditions', :param_name => 'leaving_enth_rating', :param_type => 'double'},
  ]

  def initialize(sql_file)
    self.sql_file = sql_file
  end

  def find_by_name(name)
    coil_names_query = "SELECT DISTINCT UPPER(RowName) From TabularDataWithStrings WHERE ReportName == 'CoilSizingDetails'"
    coil_names = @sql_file.execAndReturnVectorOfString(coil_names_query).get

    if coil_names.include? name.upcase
      coil_query = BASE_QUERY + " AND UPPER(RowName) == '#{name.upcase}'"
      params = {}

      PARAM_MAP.each do |param|
        query = coil_query + " AND ColumnName == '#{param[:db_name]}'"
        params[param[:param_name].to_sym] = get_optional_value(param[:param_type], query)
      end

      CoilSizingDetail.new(params)
    end
  end

  def get_all
    coil_names_query = "SELECT DISTINCT RowName From TabularDataWithStrings WHERE ReportName == 'CoilSizingDetails'"
    coil_sizing_details = []

    @sql_file.execAndReturnVectorOfString(coil_names_query).find_by_name.each do |coil_name|
      coil_sizing_details << find_by_name(coil_name)
    end

    return coil_sizing_details
  end

  private
  def get_optional_value(param_type, query)
    if param_type == 'string'
      result = self.sql_file.execAndReturnFirstString(query)
    elsif param_type == 'double'
      result = self.sql_file.execAndReturnFirstDouble(query)
    end

    if result.is_initialized
      result = result.get
    else
      result = nil
    end

    return result
  end
end