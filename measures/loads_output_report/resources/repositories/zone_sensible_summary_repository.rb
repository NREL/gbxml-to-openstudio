class ZoneSensibleSummaryRepository
  attr_accessor :sql_file, :names

  BASE_QUERY = "SELECT Value FROM TabularDataWithStrings WHERE ReportName == 'HVACSizingSummary'"
  PARAM_MAP = [
      {:db_index => 0, :param_name => :calculated_design_air_flow, :param_type => 'double'},
      {:db_index => 1, :param_name => :calculated_design_load, :param_type => 'double'},
      {:db_index => 2, :param_name => :date_time_of_peak, :param_type => 'string'},
      {:db_index => 3, :param_name => :design_day_name, :param_type => 'string'},
      {:db_index => 4, :param_name => :heat_gain_rate_from_doas, :param_type => 'double'},
      {:db_index => 5, :param_name => :indoor_humidity_ratio_at_peak_load, :param_type => 'double'},
      {:db_index => 6, :param_name => :indoor_temperature_at_peak_load, :param_type => 'double'},
      {:db_index => 7, :param_name => :minimum_outdoor_air_flow_rate, :param_type => 'double'},
      {:db_index => 8, :param_name => :outdoor_humidity_ratio_at_peak_load, :param_type => 'double'},
      {:db_index => 9, :param_name => :outdoor_temperature_at_peak_load, :param_type => 'double'},
      {:db_index => 10, :param_name => :thermostat_setpoint_temperature_at_peak_load, :param_type => 'double'},
      {:db_index => 11, :param_name => :user_design_air_flow, :param_type => 'double'},
      {:db_index => 12, :param_name => :user_design_load, :param_type => 'double'},
      {:db_index => 13, :param_name => :user_design_load_per_area, :param_type => 'double'},
  ]

  def initialize(sql_file)
    self.sql_file = sql_file

    zone_names_query = "SELECT DISTINCT UPPER(RowName) FROM TabularDataWithStrings WHERE ReportName == 'HVACSizingSummary'
 AND TableName LIKE 'Zone Sensible %'"

    @names = @sql_file.execAndReturnVectorOfString(zone_names_query).get
  end

  def find_by_name_and_conditioning(name, conditioning_type)

    if @names.include? name.upcase
      zone_query = BASE_QUERY + " AND TableName == 'Zone Sensible #{conditioning_type}' AND UPPER(RowName) == '#{name.upcase}'
ORDER BY ColumnName ASC"
      params = {}

      result = @sql_file.execAndReturnVectorOfString(zone_query)

      return nil if result.nil?

      result = result.get

      PARAM_MAP.each do |param|
        params[param[:param_name]] = cast_type(result[param[:db_index]], param[:param_type])
      end

      ZoneSensibleSummary.from_options(params)
    end
  end

  private

  def cast_type(value, type)
    if type == "double"
      value = value.to_f
    end

    value
  end
end