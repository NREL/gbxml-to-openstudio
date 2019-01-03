class ComponentLoadSummary
  attr_accessor :sql_file

  BASE_QUERY = "SELECT Value FROM TabularDataWithStrings"
  LOAD_ROW_NAMES = ['People', 'Lights', 'Equipment', 'Refrigeration', 'Water Use Equipment', 'HVAC Equipment Losses', 'Power Generation Equipment',
                    'DOAS Direct to Zone', 'Infiltration', 'Zone Ventilation', 'Interzone Mixing', 'Roof', 'Interzone Ceiling', 'Other Roof', 'Exterior Wall',
                    'Interzone Wall', 'Ground Contact Wall', 'Other Wall', 'Exterior Floor', 'Interzone Floor', 'Ground Contact Floor', 'Other Floor',
                    'Fenestration Conduction', 'Fenestration Solar', 'Opaque Door', 'Grand Total']
  LOAD_COLUMN_NAMES = ['Sensible - Instant', 'Sensible - Delayed', 'Sensible - Return Air', 'Latent', 'Total']
  PEAK_ROW_NAMES =     ["Time of Peak Load", "Outside  Dry Bulb Temperature", "Outside  Wet Bulb Temperature", "Outside Humidity Ratio at Peak",
                        "Zone Dry Bulb Temperature", "Zone Relative Humidity", "Zone Humidity Ratio at Peak", "Supply Air Temperature", "Mixed Air Temperature",
                        "Main Fan Air Flow", "Outside Air Flow", "Peak Sensible Load with Sizing Factor", "Difference Due to Sizing Factor", "Peak Sensible Load",
                        "Estimated Instant + Delayed Sensible Load", "Difference Between Peak and Estimated Sensible Load"]

  def initialize(sql_file)
    self.sql_file = sql_file
  end

  def get_cooling_load_summary(report_for_string)
    cooling_zone_query = BASE_QUERY + " WHERE ReportForString == '#{report_for_string}' AND TableName == 'Estimated Cooling Peak Load Components'"
    loads = {}

    LOAD_ROW_NAMES.each do |row_name|
      row_loads = {}

      LOAD_COLUMN_NAMES.each do |column_name|
        load_query = cooling_zone_query + " AND RowName == '#{row_name}' AND ColumnName == '#{column_name}'"

        load_result = self.sql_file.execAndReturnFirstDouble(load_query)

        if load_result.is_initialized
          row_loads[column_name] = load_result.get
        end
      end

      loads[row_name] = row_loads
    end

    return loads
  end

  def get_heating_load_summary(report_for_string)
    cooling_zone_query = BASE_QUERY + " WHERE ReportForString == '#{report_for_string}' AND TableName == 'Estimated Heating Peak Load Components'"
    loads = {}

    LOAD_ROW_NAMES.each do |row_name|
      row_loads = {}

      LOAD_COLUMN_NAMES.each do |column_name|
        load_query = cooling_zone_query + " AND RowName == '#{row_name}' AND ColumnName == '#{column_name}'"

        load_result = self.sql_file.execAndReturnFirstDouble(load_query)

        if load_result.is_initialized
          row_loads[column_name] = load_result.get
        end
      end

      loads[row_name] = row_loads
    end

    return loads
  end

  def get_peak_cooling_conditions(report_for_string)
    cooling_peak_conditions_query = BASE_QUERY + " WHERE ReportForString == '#{report_for_string}' AND TableName == 'Cooling Peak Conditions'"
    peak_conditions = {}

    ## Get cooling peak conditions
    PEAK_ROW_NAMES.each do |row_name|

      load_query = cooling_peak_conditions_query + " AND RowName == '#{row_name}' AND ColumnName == 'Value'"
      runner.registerInfo(load_query)
      if row_name == 'Time of Peak Load'
        load_result = self.sql_file.execAndReturnFirstString(load_query)
      else
        load_result = self.sql_file.execAndReturnFirstDouble(load_query)
      end

      if load_result.is_initialized
        peak_conditions[row_name] = load_result.get
      end
    end
  end

  def get_peak_heating_conditions(report_for_string)
    heating_peak_conditions_query = BASE_QUERY + " WHERE ReportForString == '#{report_for_string}' AND TableName == 'Heating Peak Conditions'"
    peak_conditions = {}

    PEAK_ROW_NAMES.each do |row_name|

      load_query = heating_peak_conditions_query + " AND RowName == '#{row_name}' AND ColumnName == 'Value'"
      runner.registerInfo(load_query)
      if row_name == 'Time of Peak Load'
        load_result = self.sql_file.execAndReturnFirstString(load_query)
      else
        load_result = self.sql_file.execAndReturnFirstDouble(load_query)
      end

      if load_result.is_initialized
        peak_conditions[row_name] = load_result.get
      end
    end
  end

  def get_loads_and_peak_conditions(report_for_string)
    loads_and_peaks = {"cooling": {"loads": {}, "peak_conditions": {}}, "heating": {"loads": {}, "peak_conditions": {}}}
    loads_and_peaks[:cooling][:loads] = get_cooling_load_summary(report_for_string)
    loads_and_peaks[:heating][:loads] = get_cooling_load_summary(report_for_string)
    loads_and_peaks[:cooling][:peak_conditions] = get_cooling_load_summary(report_for_string)
    loads_and_peaks[:heating][:peak_conditions] = get_cooling_load_summary(report_for_string)

    return loads_and_peaks
  end
end