class ZoneSensibleSummaryRepository
  attr_accessor :sql_file

  BASE_QUERY = "SELECT Value FROM TabularDataWithStrings WHERE ReportName == 'HVACSizingSummary'"
  PARAM_MAP = [
      {:db_name => 'Calculated Design Load', :param_name => 'calculated_design_load', :param_type => 'double'},
      {:db_name => 'User Design Load', :param_name => 'user_design_load', :param_type => 'double'},
      {:db_name => 'User Design Load per Area', :param_name => 'user_design_load_per_area', :param_type => 'double'},
      {:db_name => 'Calculated Design Air Flow', :param_name => 'calculated_design_air_flow', :param_type => 'double'},
      {:db_name => 'User Design Air Flow', :param_name => 'user_design_air_flow', :param_type => 'double'},
      {:db_name => 'Design Day Name', :param_name => 'design_day_name', :param_type => 'string'},
      {:db_name => 'Date/Time Of Peak {TIMESTAMP}', :param_name => 'date_time_of_peak', :param_type => 'string'},
      {:db_name => 'Thermostat Setpoint Temperature at Peak Load', :param_name => 'thermostat_setpoint_temperature_at_peak_load', :param_type => 'double'},
      {:db_name => 'Indoor Temperature at Peak Load', :param_name => 'indoor_temperature_at_peak_load', :param_type => 'double'},
      {:db_name => 'Indoor Humidity Ratio at Peak Load', :param_name => 'indoor_humidity_ratio_at_peak_load', :param_type => 'double'},
      {:db_name => 'Outdoor Temperature at Peak Load', :param_name => 'outdoor_temperature_at_peak_load', :param_type => 'double'},
      {:db_name => 'Outdoor Humidity Ratio at Peak Load', :param_name => 'outdoor_humidity_ratio_at_peak_load', :param_type => 'double'},
      {:db_name => 'Minimum Outdoor Air Flow Rate', :param_name => 'minimum_outdoor_air_flow_rate', :param_type => 'double'},
      {:db_name => 'Heat Gain Rate from DOAS', :param_name => 'heat_gain_rate_from_doas', :param_type => 'double'},
  ]

  def initialize(sql_file)
    self.sql_file = sql_file
  end

  def find_by_name_conditioning_type(name, conditioning_type)
    zone_names_query = "SELECT DISTINCT UPPER(RowName) FROM TabularDataWithStrings WHERE ReportName == 'HVACSizingSummary'
 AND TableName == 'Zone Sensible #{conditioning_type}'"

    zone_names = @sql_file.execAndReturnVectorOfString(zone_names_query).get

    if zone_names.include? name.upcase
      zone_query = BASE_QUERY + " AND TableName == 'Zone Sensible #{conditioning_type}' AND UPPER(RowName) == '#{name.upcase}'"
      params = {}

      PARAM_MAP.each do |param|
        query = zone_query + " AND ColumnName == '#{param[:db_name]}'"
        params[param[:param_name].to_sym] = get_optional_value(param[:param_type], query)
      end

      ZoneSensibleSummary.from_options(params)
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