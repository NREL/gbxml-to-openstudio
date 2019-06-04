require_relative '../coil_sizing_detail'

class CoilSizingDetailRepository
  attr_accessor :sql_file, :instances, :names

  BASE_QUERY = "SELECT Value FROM TabularDataWithStrings WHERE ReportName == 'CoilSizingDetails'"
  PARAM_MAP = [
      {:db_index => 0, :param_name => :autosized_airflow, :param_type => 'string'},
      {:db_index => 1, :param_name => :autosized_capacity, :param_type => 'string'},
      {:db_index => 2, :param_name => :autosized_waterflow, :param_type => 'string'},
      {:db_index => 3, :param_name => :airmass_peak, :param_type => 'double'},
      {:db_index => 4, :param_name => :airmass_rating, :param_type => 'double'},
      {:db_index => 5, :param_name => :airflow_peak, :param_type => 'double'},
      {:db_index => 6, :param_name => :cap_percent_of_plant_design, :param_type => 'double'},
      {:db_index => 7, :param_name => :entering_drybulb_peak, :param_type => 'double'},
      {:db_index => 8, :param_name => :entering_drybulb_rating, :param_type => 'double'},
      {:db_index => 9, :param_name => :entering_enth_peak, :param_type => 'double'},
      {:db_index => 10, :param_name => :entering_enth_rating, :param_type => 'double'},
      {:db_index => 11, :param_name => :entering_hr_peak, :param_type => 'double'},
      {:db_index => 12, :param_name => :entering_hr_rating, :param_type => 'double'},
      {:db_index => 13, :param_name => :entering_wetbulb_peak, :param_type => 'double'},
      {:db_index => 14, :param_name => :entering_wetbulb_rating, :param_type => 'double'},
      {:db_index => 15, :param_name => :entering_plant_temp_peak, :param_type => 'double'},
      {:db_index => 16, :param_name => :final_gross_sensible_capacity, :param_type => 'double'},
      {:db_index => 17, :param_name => :final_gross_total_capacity, :param_type => 'double'},
      {:db_index => 18, :param_name => :final_reference_airflow, :param_type => 'double'},
      {:db_index => 19, :param_name => :final_reference_fluidflow, :param_type => 'double'},
      {:db_index => 20, :param_name => :flow_percent_of_plant_design, :param_type => 'double'},
      {:db_index => 21, :param_name => :leaving_drybulb_peak, :param_type => 'double'},
      {:db_index => 22, :param_name => :leaving_drybulb_rating, :param_type => 'double'},
      {:db_index => 23, :param_name => :leaving_enth_peak, :param_type => 'double'},
      {:db_index => 24, :param_name => :leaving_enth_rating, :param_type => 'double'},
      {:db_index => 25, :param_name => :leaving_hr_peak, :param_type => 'double'},
      {:db_index => 26, :param_name => :leaving_hr_rating, :param_type => 'double'},
      {:db_index => 27, :param_name => :leaving_wetbulb_peak, :param_type => 'double'},
      {:db_index => 28, :param_name => :leaving_wetbulb_rating, :param_type => 'double'},
      {:db_index => 29, :param_name => :leaving_plant_temp_peak, :param_type => 'double'},
      {:db_index => 30, :param_name => :coil_location, :param_type => 'string'},
      {:db_index => 31, :param_name => :cap_modifier_peak, :param_type => 'double'},
      {:db_index => 32, :param_name => :fluidmass_peak, :param_type => 'double'},
      {:db_index => 33, :param_name => :plant_fluid_temp_diff_peak, :param_type => 'double'},
      {:db_index => 34, :param_name => :cap_sensible_peak, :param_type => 'double'},
      {:db_index => 35, :param_name => :sensible_cap_rating, :param_type => 'double'},
      {:db_index => 36, :param_name => :cap_total_peak, :param_type => 'double'},
      {:db_index => 37, :param_name => :total_cap_rating, :param_type => 'double'},
      {:db_index => 38, :param_name => :coil_type, :param_type => 'string'},
      {:db_index => 39, :param_name => :coil_ua, :param_type => 'double'},
      {:db_index => 40, :param_name => :coil_and_fan_cap_peak, :param_type => 'double'},
      {:db_index => 41, :param_name => :dx_capacity_decrease_high_flow, :param_type => 'double'},
      {:db_index => 42, :param_name => :dx_capacity_increase_low_flow, :param_type => 'double'},
      {:db_index => 43, :param_name => :datetime_flow_peak, :param_type => 'string'},
      {:db_index => 44, :param_name => :datetime_sensible_peak, :param_type => 'string'},
      {:db_index => 45, :param_name => :datetime_total_peak, :param_type => 'string'},
      {:db_index => 46, :param_name => :design_day_name_flow_peak, :param_type => 'string'},
      {:db_index => 47, :param_name => :design_day_name_sensible_peak, :param_type => 'string'},
      {:db_index => 48, :param_name => :design_day_name_total_peak, :param_type => 'string'},
      {:db_index => 49, :param_name => :dry_air_heat_capacity, :param_type => 'double'},
      {:db_index => 50, :param_name => :hvac_name, :param_type => 'string'},
      {:db_index => 51, :param_name => :hvac_type, :param_type => 'string'},
      {:db_index => 52, :param_name => :moist_air_heat_capacity, :param_type => 'double'},
      {:db_index => 53, :param_name => :oa_pretreated, :param_type => 'string'},
      {:db_index => 54, :param_name => :oa_drybulb_peak, :param_type => 'double'},
      {:db_index => 55, :param_name => :oa_percent_peak, :param_type => 'double'},
      {:db_index => 56, :param_name => :oa_hr_peak, :param_type => 'double'},
      {:db_index => 57, :param_name => :oa_airflow_peak, :param_type => 'double'},
      {:db_index => 58, :param_name => :oa_wetbulb_peak, :param_type => 'double'},
      {:db_index => 59, :param_name => :plant_design_capacity, :param_type => 'double'},
      {:db_index => 60, :param_name => :plant_design_fluid_return_temp, :param_type => 'double'},
      {:db_index => 61, :param_name => :plant_design_fluid_supply_temp, :param_type => 'double'},
      {:db_index => 62, :param_name => :plant_design_fluid_temp_diff, :param_type => 'double'},
      {:db_index => 63, :param_name => :plant_fluid_density, :param_type => 'double'},
      {:db_index => 64, :param_name => :plant_specific_heat_capacity, :param_type => 'double'},
      {:db_index => 65, :param_name => :plant_max_mass_flow_rate, :param_type => 'double'},
      {:db_index => 66, :param_name => :plant_name, :param_type => 'string'},
      {:db_index => 67, :param_name => :standard_air_density, :param_type => 'double'},
      {:db_index => 68, :param_name => :fan_heat_gain_peak, :param_type => 'double'},
      {:db_index => 69, :param_name => :supply_fan_max_massflow_rate, :param_type => 'double'},
      {:db_index => 70, :param_name => :supply_fan_max_airflow_rate, :param_type => 'double'},
      {:db_index => 71, :param_name => :supply_fan_name, :param_type => 'string'},
      {:db_index => 72, :param_name => :supply_fan_type, :param_type => 'string'},
      {:db_index => 73, :param_name => :system_return_drybulb_peak, :param_type => 'double'},
      {:db_index => 74, :param_name => :system_return_hr_peak, :param_type => 'double'},
      {:db_index => 75, :param_name => :sizing_method_airflow, :param_type => 'string'},
      {:db_index => 76, :param_name => :sizing_method_capacity, :param_type => 'string'},
      {:db_index => 77, :param_name => :sizing_method_concurrence, :param_type => 'string'},
      {:db_index => 78, :param_name => :tu_rh_coil_mult, :param_type => 'double'},
      {:db_index => 79, :param_name => :zone_drybulb_peak, :param_type => 'double'},
      {:db_index => 80, :param_name => :zone_hr_peak, :param_type => 'double'},
      {:db_index => 81, :param_name => :zone_rh_peak, :param_type => 'double'},
      {:db_index => 82, :param_name => :zone_latent_peak, :param_type => 'double'},
      {:db_index => 83, :param_name => :zone_names, :param_type => 'string'},
      {:db_index => 84, :param_name => :zone_sensible_peak, :param_type => 'double'},
  ]

  def initialize(sql_file)
    @sql_file = sql_file
    @instances = {}

    coil_names_query = "SELECT DISTINCT UPPER(RowName) From TabularDataWithStrings WHERE ReportName == 'CoilSizingDetails'"
    @names = @sql_file.execAndReturnVectorOfString(coil_names_query).get
  end

  def find_by_name(name)

    # if self.instances.key?(name)
    #   return self.instances[name]
    # end

    if @names.include? name.upcase
      coil_query = BASE_QUERY + " AND UPPER(RowName) == '#{name.upcase}' ORDER BY ColumnName ASC"
      params = {}

      result = @sql_file.execAndReturnVectorOfString(coil_query)

      return nil if result.nil?

      result = result.get

      PARAM_MAP.each do |param|
        params[param[:param_name]] = cast_type(result[param[:db_index]], param[:param_type])
      end

      coil_sizing_detail = CoilSizingDetail.new(params)
      @instances[name] = coil_sizing_detail
      coil_sizing_detail
    end
  end

  def get_all
    coil_names_query = "SELECT DISTINCT RowName From TabularDataWithStrings WHERE ReportName == 'CoilSizingDetails'"
    coil_sizing_details = []

    @sql_file.execAndReturnVectorOfString(coil_names_query).get.each do |coil_name|
      coil_sizing_details << find_by_name(coil_name)
    end

    coil_sizing_details
  end

  private

  def cast_type(value, type)
    if type == "double"
      value = value.to_f
    end

    value
  end
end