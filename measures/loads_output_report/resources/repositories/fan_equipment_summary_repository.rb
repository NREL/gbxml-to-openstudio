class FanEquipmentSummaryRepository
  attr_accessor :sql_file

  BASE_QUERY = "SELECT Value FROM TabularDataWithStrings WHERE ReportName == 'EquipmentSummary' AND TableName == 'Fans'"
  PARAM_MAP = [
      {:db_name => 'Type', :param_name => 'type', :param_type => 'string'},
      {:db_name => 'Total Efficiency', :param_name => 'total_efficiency', :param_type => 'double'},
      {:db_name => 'Delta Pressure', :param_name => 'delta_pressure', :param_type => 'double'},
      {:db_name => 'Max Air Flow Rate', :param_name => 'max_air_flow_rate', :param_type => 'double'},
      {:db_name => 'Rated Electric Power', :param_name => 'rated_electric_power', :param_type => 'double'},
      {:db_name => 'Rated Power Per Max Air Flow Rate', :param_name => 'rated_power_per_max_air_flow_rate', :param_type => 'double'},
      {:db_name => 'Motor Heat In Air Fraction', :param_name => 'motor_heat_in_air_fraction', :param_type => 'double'},
      {:db_name => 'End Use', :param_name => 'end_use', :param_type => 'string'},
      {:db_name => 'Design Day Name for Fan Sizing Peak', :param_name => 'design_day_name_for_fan_sizing_peak', :param_type => 'string'},
      {:db_name => 'Date/Time for Fan Sizing Peak', :param_name => 'date_time_for_fan_sizing_peak', :param_type => 'string'},
  ]
  def initialize(sql_file)
    self.sql_file = sql_file
  end

  def find_by_name(name)
    fan_names_query = "SELECT DISTINCT UPPER(RowName) FROM TabularDataWithStrings WHERE ReportName == 'EquipmentSummary' AND TableName == 'Fans'"

    fan_names = @sql_file.execAndReturnVectorOfString(fan_names_query).get

    if fan_names.include? name.upcase
      fan_query = BASE_QUERY + " AND UPPER(RowName) == '#{name.upcase}'"
      params = {}

      PARAM_MAP.each do |param|
        query = fan_query + " AND ColumnName == '#{param[:db_name]}'"
        params[param[:param_name].to_sym] = get_optional_value(param[:param_type], query)
      end

      FanEquipmentSummary.from_options(params)
    end
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