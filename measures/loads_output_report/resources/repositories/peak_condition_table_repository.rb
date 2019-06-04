require_relative '../peak_condition_table'

class PeakConditionTableRepository
  attr_accessor :sql_file, :names

  BASE_QUERY = "SELECT Value FROM TabularDataWithStrings"
  PARAM_MAP = [
      {:db_index => 0, :param_name => :peak_estimate_diff, :param_type => 'double'},
      {:db_index => 1, :param_name => :sf_diff, :param_type => 'double'},
      {:db_index => 2, :param_name => :estimate_instant_delayed_sensible, :param_type => 'double'},
      {:db_index => 3, :param_name => :fan_flow, :param_type => 'double'},
      {:db_index => 4, :param_name => :mat, :param_type => 'double'},
      {:db_index => 5, :param_name => :oa_drybulb, :param_type => 'double'},
      {:db_index => 6, :param_name => :oa_wetbulb, :param_type => 'double'},
      {:db_index => 7, :param_name => :oa_flow, :param_type => 'double'},
      {:db_index => 8, :param_name => :oa_hr, :param_type => 'double'},
      {:db_index => 9, :param_name => :sensible_peak, :param_type => 'double'},
      {:db_index => 10, :param_name => :sensible_peak_sf, :param_type => 'double'},
      {:db_index => 11, :param_name => :sat, :param_type => 'double'},
      {:db_index => 12, :param_name => :time_of_peak_load, :param_type => 'string'},
      {:db_index => 13, :param_name => :zone_drybulb, :param_type => 'double'},
      {:db_index => 14, :param_name => :zone_hr, :param_type => 'double'},
      {:db_index => 15, :param_name => :zone_rh, :param_type => 'double'},
  ]

  def initialize(sql_file)
    @sql_file = sql_file

    names_query = "SELECT DISTINCT UPPER(ReportForString) From TabularDataWithStrings WHERE TableName LIKE '% Peak Conditions'"
    @names = @sql_file.execAndReturnVectorOfString(names_query).get
  end

  # @param name [String] the name of the object
  # @param conditioning [String] either "Cooling" or "Heating"
  def find_by_name_and_conditioning(name, conditioning)

    if names.include? name.upcase
      component_query = BASE_QUERY + " WHERE TableName = '#{conditioning} Peak Conditions' AND
UPPER(ReportForString) = '#{name.upcase}' ORDER BY RowName ASC"
      params = {}

      result = @sql_file.execAndReturnVectorOfString(component_query)

      return nil if result.nil?

      result = result.get

      PARAM_MAP.each do |param|
        params[param[:param_name]] = cast_type(result[param[:db_index]], param[:param_type])
      end

      PeakConditionTable.new(params)
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