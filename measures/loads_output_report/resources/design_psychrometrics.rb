class DesignPsychrometrics
  attr_accessor :sql_file

  BASE_QUERY = "SELECT Value FROM TabularDataWithStrings"
  COLUMNS = [
      'Date/Time at Total Ideal Loads Peak', 'Coil Air Volume Flow Rate at Ideal Loads Peak', 'Zone Air Drybulb at Ideal Loads Peak',
      'Zone Air Humidity Ratio at Ideal Loads Peak', 'Zone Air Relative Humidity at Ideal Loads Peak', 'System Return Air Drybulb at Ideal Loads Peak',
      'System Return Air Humidity Ratio at Ideal Loads Peak', 'Outdoor Air Drybulb at Ideal Loads Peak', 'Outdoor Air Humidity Ratio at Ideal Loads Peak',
      'Coil Entering Air Drybulb at Ideal Loads Peak', 'Coil Entering Air Humidity Ratio at Ideal Loads Peak', 'Coil Leaving Air Drybulb at Ideal Loads Peak',
      'Coil Leaving Air Humidity Ratio at Ideal Loads Peak', 'Zone Sensible Heat Gain at Ideal Loads Peak', 'Outdoor Air Volume Flow Rate at Ideal Loads Peak',
      'Outdoor Air Flow Percentage at Ideal Loads Peak', 'Moist Air Heat Capacity', 'Standard Air Density Adjusted for Elevation',
      'Supply Fan Air Heat Gain at Ideal Loads Peak', 'Moist Air Heat Capacity', 'Supply Fan Maximum Air Mass Flow Rate'
  ]

  def initialize(sql_file)
    self.sql_file = sql_file
  end

  def get_design_psychrometrics(coil_name)
    coil_sizing_query = BASE_QUERY + " WHERE ReportName == 'CoilSizingDetails' AND RowName == #{coil_name}'"
    psychrometrics = {}

    COLUMNS.each do |column_name|
      query = coil_sizing_query + " AND ColumnName == '#{column_name}'"

      result = self.sql_file.execAndReturnFirstDouble(query)

      if result.is_initialized
        psychrometrics[column_name] = result.get
      end
    end

    coil_sizing_query +

    fan_heat_gain = psychrometrics['Supply Fan Air Heat Gain at Ideal Loads Peak']
    air_specific_heat = psychrometrics['Moist Air Heat Capacity']
    mass_flow_rate = psychrometrics['Supply Fan Maximum Air Mass Flow Rate']
    psychrometrics['supply_fan_temperature_difference'] = fan_heat_gain / (air_specific_heat * mass_flow_rate)

    return psychrometrics
  end

end