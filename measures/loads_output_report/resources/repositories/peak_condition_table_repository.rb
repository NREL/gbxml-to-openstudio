require_relative '../peak_condition_table'

class PeakConditionTableRepository
  attr_accessor :sql_file

  BASE_QUERY = "SELECT Value FROM TabularDataWithStrings"
  PARAM_MAP = [
      {:db_name => 'Time of Peak Load', :param_name => 'time_of_peak_load', :param_type => 'string'},
      {:db_name => 'Outside  Dry Bulb Temperature', :param_name => 'oa_drybulb', :param_type => 'double'},
      {:db_name => 'Outside  Wet Bulb Temperature', :param_name => 'oa_wetbulb', :param_type => 'double'},
      {:db_name => 'Outside Humidity Ratio at Peak', :param_name => 'oa_hr', :param_type => 'double'},
      {:db_name => 'Zone Dry Bulb Temperature', :param_name => 'zone_drybulb', :param_type => 'double'},
      {:db_name => 'Zone Relative Humidity', :param_name => 'zone_rh', :param_type => 'double'},
      {:db_name => 'Zone Humidity Ratio at Peak', :param_name => 'zone_hr', :param_type => 'double'},
      {:db_name => 'Supply Air Temperature', :param_name => 'sat', :param_type => 'double'},
      {:db_name => 'Mixed Air Temperature', :param_name => 'mat', :param_type => 'double'},
      {:db_name => 'Main Fan Air Flow', :param_name => 'fan_flow', :param_type => 'double'},
      {:db_name => 'Outside Air Flow', :param_name => 'oa_flow', :param_type => 'double'},
      {:db_name => 'Peak Sensible Load with Sizing Factor', :param_name => 'sensible_peak_sf', :param_type => 'double'},
      {:db_name => 'Difference Due to Sizing Factor', :param_name => 'sf_diff', :param_type => 'double'},
      {:db_name => 'Peak Sensible Load', :param_name => 'sensible_peak', :param_type => 'double'},
      {:db_name => 'Estimated Instant + Delayed Sensible Load', :param_name => 'estimate_instant_delayed_sensible', :param_type => 'double'},
      {:db_name => 'Difference Between Peak and Estimated Sensible Load', :param_name => 'peak_estimate_diff', :param_type => 'double'},
  ]

  def initialize(sql_file)
    @sql_file = sql_file
  end

  # @param name [String] the name of the object
  # @param conditioning [String] either "Cooling" or "Heating"
  def find_by_name_type_and_conditioning(name, conditioning)
    names_query = "SELECT DISTINCT UPPER(ReportForString) From TabularDataWithStrings WHERE TableName == '#{conditioning} Peak Conditions'"
    names = @sql_file.execAndReturnVectorOfString(names_query).get

    if names.include? name.upcase
      component_query = BASE_QUERY + " WHERE TableName = '#{conditioning} Peak Conditions' AND UPPER(ReportForString) = '#{name.upcase}'"
      params = {}

      PARAM_MAP.each do |param|
        query = component_query + " AND RowName == '#{param[:db_name]}'"
        params[param[:param_name].to_sym] = get_optional_value(param[:param_type], query)
      end

      PeakConditionTable.new(params)
    end
  end

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