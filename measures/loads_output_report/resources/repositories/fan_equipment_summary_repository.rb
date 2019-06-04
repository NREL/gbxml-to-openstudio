class FanEquipmentSummaryRepository
  attr_accessor :sql_file, :names

  BASE_QUERY = "SELECT Value FROM TabularDataWithStrings WHERE ReportName == 'EquipmentSummary' AND TableName == 'Fans'"
  PARAM_MAP = [
      {:db_index => 0, :param_name => :date_time_for_fan_sizing_peak, :param_type => 'string'},
      {:db_index => 1, :param_name => :delta_pressure, :param_type => 'double'},
      {:db_index => 2, :param_name => :design_day_name_for_fan_sizing_peak, :param_type => 'string'},
      {:db_index => 3, :param_name => :end_use, :param_type => 'string'},
      {:db_index => 4, :param_name => :fan_energy_index, :param_type => 'double'},
      {:db_index => 5, :param_name => :max_air_flow_rate, :param_type => 'double'},
      {:db_index => 6, :param_name => :motor_heat_in_air_fraction, :param_type => 'double'},
      {:db_index => 7, :param_name => :rated_electric_power, :param_type => 'double'},
      {:db_index => 8, :param_name => :rated_power_per_max_air_flow_rate, :param_type => 'double'},
      {:db_index => 9, :param_name => :total_efficiency, :param_type => 'double'},
      {:db_index => 10, :param_name => :type, :param_type => 'string'},
  ]

  def initialize(sql_file)
    self.sql_file = sql_file

    fan_names_query = "SELECT DISTINCT UPPER(RowName) FROM TabularDataWithStrings WHERE ReportName == 'EquipmentSummary' AND TableName == 'Fans'"
    @names = @sql_file.execAndReturnVectorOfString(fan_names_query).get
  end

  def find_by_name(name)

    if @names.include? name.upcase
      fan_query = BASE_QUERY + " AND UPPER(RowName) == '#{name.upcase}' ORDER BY ColumnName ASC"
      params = {}

      result = @sql_file.execAndReturnVectorOfString(fan_query)

      return nil if result.nil?

      result = result.get

      PARAM_MAP.each do |param|
        params[param[:param_name]] = cast_type(result[param[:db_index]], param[:param_type])
      end

      FanEquipmentSummary.from_options(params)
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