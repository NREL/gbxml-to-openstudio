require_relative '../peak_load_component'

class PeakLoadComponentRepository
  attr_accessor :sql_file

  BASE_QUERY = "SELECT Value FROM TabularDataWithStrings"
  PARAM_MAP = [
      {:db_name => 'Sensible - Instant', :param_sym => :sensible_instant},
      {:db_name => 'Sensible - Delayed', :param_sym => :sensible_delayed},
      {:db_name => 'Sensible - Return Air', :param_sym => :sensible_return_air},
      {:db_name => 'Latent', :param_sym => :latent},
      {:db_name => 'Total', :param_sym => :total},
      {:db_name => '%Grand Total', :param_sym => :percent_grand_total},
      {:db_name => 'Related Area', :param_sym => :related_area},
      {:db_name => 'Total per Area', :param_sym => :total_per_area},
  ]

  def initialize(sql_file)
    @sql_file = sql_file
  end

  # @param name [String] the name of the object
  # @param conditioning_type [String] "heating" or "cooling"
  # @param component [String] of the type of load (i.e. "People", "Lights", "Equipment")
  def find(name, conditioning_type, component)
    names_query = "SELECT DISTINCT UPPER(ReportForString) From TabularDataWithStrings WHERE TableName == 'Estimated #{conditioning_type} Peak Load Components'"
    names = @sql_file.execAndReturnVectorOfString(names_query).get

    return unless names.include? name.upcase

    component_query = BASE_QUERY + " WHERE TableName = 'Estimated #{conditioning_type} Peak Load Components'
AND UPPER(ReportForString) = '#{name.upcase}' AND RowName = '#{component}'"

    params = {}

    PARAM_MAP.each do |param|
      query = component_query + " AND ColumnName == '#{param[:db_name]}'"

      result = self.sql_file.execAndReturnFirstDouble(query)
      if result.is_initialized
        params[param[:param_sym]] = result.get
      end
    end

    PeakLoadComponent.new(params)
  end
end