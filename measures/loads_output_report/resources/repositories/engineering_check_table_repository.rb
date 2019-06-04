require_relative '../engineering_check_table'

class EngineeringCheckTableRepository
  attr_accessor :sql_file, :names

  BASE_QUERY = "SELECT Value FROM TabularDataWithStrings"
  PARAM_MAP = [
      {:db_index => 0, :param_name => :airflow_per_floor_area, :param_type => 'double'},
      {:db_index => 1, :param_name => :airflow_per_total_cap, :param_type => 'double'},
      {:db_index => 2, :param_name => :floor_area_per_total_cap, :param_type => 'double'},
      {:db_index => 3, :param_name => :number_of_people, :param_type => 'double'},
      {:db_index => 4, :param_name => :oa_percent, :param_type => 'double'},
      {:db_index => 5, :param_name => :total_cap_per_floor_area, :param_type => 'double'}
  ]
  def initialize(sql_file)
    self.sql_file = sql_file

    names_query = "SELECT DISTINCT UPPER(ReportForString) From TabularDataWithStrings WHERE TableName LIKE 'Engineering Checks for %'"
    @names = @sql_file.execAndReturnVectorOfString(names_query).get
  end

  # @param name [String] the name of the object
  # @param conditioning [String] either "Cooling" or "Heating"
  def find_by_name_and_conditioning(name, conditioning)

    if @names.include? name.upcase
      component_query = BASE_QUERY + " WHERE TableName = 'Engineering Checks for #{conditioning}' AND UPPER(ReportForString) = '#{name.upcase}'  ORDER BY RowName ASC"
      params = {}

      result = @sql_file.execAndReturnVectorOfString(component_query)

      return nil if result.nil?

      result = result.get

      PARAM_MAP.each do |param|
        params[param[:param_name]] = cast_type(result[param[:db_index]], param[:param_type])
      end

      EngineeringCheckTable.new(params)
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