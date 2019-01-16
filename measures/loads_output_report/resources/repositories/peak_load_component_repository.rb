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

  # @param type [String] whether it's a "zone", "airloop" or "facility"
  # @param name [String] the name of the object
  # @param conditioning_type [String] "heating" or "cooling"
  # @param component [String] of the type of load (i.e. "People", "Lights", "Equipment")
  def get(type, name, conditioning_type, component)
    component_query = BASE_QUERY + " WHERE ReportName = '#{type} Component Load Summary' AND TableName =
          'Estimated #{conditioning_type} Peak Load Components' AND ReportForString = '#{name}' AND RowName = '#{component}'"

    params = {}

    PARAM_MAP.each do |param|
      query = component_query + " AND ColumnName == '#{param[:db_name]}'"

      result = self.sql_file.execAndReturnFirstDouble(query)
      puts result
      if result.is_initialized
        params[param[:param_sym]] = result.get
      end
    end

    PeakLoadComponent.new(params)
  end

  # Do I need this method and the following commented out methods?
  # Should I just provide the single get method?
  def get_zone_cooling_component(name, component)
    get('zone', name, 'cooling', component)
  end

  # def get_zone_heating_component(name, component)
  #   component_query = BASE_QUERY + " WHERE ReportName = 'Zone Component Load Summary' AND TableName = 'Estimated Heating Peak Load Components'"
  #   query = component_query + " AND ReportForString = '#{name}' AND RowName = '#{component}'"
  #
  #   result = self.sql_file.execAndReturnFirstDouble(query)
  #
  #   if result.is_initialized
  #     return result.get
  #   else
  #     return nil
  #   end
  # end
  #
  # def get_air_cooling_component(name, component)
  #   component_query = BASE_QUERY + " WHERE ReportName = 'Air Component Load Summary' AND TableName = 'Estimated Cooling Peak Load Components'"
  #   query = component_query + " AND ReportForString = '#{name}' AND RowName = '#{component}'"
  #
  #   result = self.sql_file.execAndReturnFirstDouble(query)
  #
  #   if result.is_initialized
  #     return result.get
  #   else
  #     return nil
  #   end
  # end
  #
  # def get_air_heating_component(name, component)
  #   component_query = BASE_QUERY + " WHERE ReportName = 'Air Component Load Summary' AND TableName = 'Estimated Heating Peak Load Components'"
  #   query = component_query + " AND ReportForString = '#{name}' AND RowName = '#{component}'"
  #
  #   result = self.sql_file.execAndReturnFirstDouble(query)
  #
  #   if result.is_initialized
  #     return result.get
  #   else
  #     return nil
  #   end
  # end
  #
  # def get_facility_cooling_component(component)
  #   component_query = BASE_QUERY + " WHERE ReportName = 'Facility Component Load Summary' AND TableName = 'Estimated Cooling Peak Load Components'"
  #   query = component_query + " AND RowName = '#{component}'"
  #
  #   result = self.sql_file.execAndReturnFirstDouble(query)
  #
  #   if result.is_initialized
  #     return result.get
  #   else
  #     return nil
  #   end
  # end
  #
  # def get_facility_heating_component(component)
  #   component_query = BASE_QUERY + " WHERE ReportName = 'Facility Component Load Summary' AND TableName = 'Estimated Heating Peak Load Components'"
  #   query = component_query + " AND RowName = '#{component}'"
  #
  #   result = self.sql_file.execAndReturnFirstDouble(query)
  #
  #   if result.is_initialized
  #     return result.get
  #   else
  #     return nil
  #   end
  # end
end