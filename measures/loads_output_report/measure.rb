# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

require 'openstudio'

model = OpenStudio::Model::Model.new()

# start the measure
class LoadsOutputReport < OpenStudio::Measure::ReportingMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Loads Output Report'
  end

  # human readable description
  def description
    return 'This measure develops a json file containing the pertinent load calculation information'
  end

  # human readable description of modeling approach
  def modeler_description
    return ''
  end

  # define the arguments that the user will input
  def arguments
    args = OpenStudio::Measure::OSArgumentVector.new

    # this measure does not require any user arguments, return an empty list

    return args
  end
  
  # define the outputs that the measure will create
  def outputs
    outs = OpenStudio::Measure::OSOutputVector.new

    # this measure does not produce machine readable outputs with registerValue, return an empty list

    return outs
  end
  
  # return a vector of IdfObject's to request EnergyPlus objects needed by the run method
  # Warning: Do not change the name of this method to be snake_case. The method must be lowerCamelCase.
  def energyPlusOutputRequests(runner, user_arguments)
    super(runner, user_arguments)

    result = OpenStudio::IdfObjectVector.new

    # use the built-in error checking
    if !runner.validateUserArguments(arguments, user_arguments)
      return result
    end

    request = OpenStudio::IdfObject.load('Output:Variable,,Site Outdoor Air Drybulb Temperature,Hourly;').get
    result << request

    return result
  end

  # define what happens when the measure is run
  def run(runner, user_arguments)
    super(runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments, user_arguments)
      return false
    end

    # get the last model and sql file
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError('Cannot find last model.')
      return false
    end
    model = model.get

    sql_file = runner.lastEnergyPlusSqlFile
    if sql_file.empty?
      runner.registerError('Cannot find last sql file.')
      return false
    end
    sql_file = sql_file.get
    model.setSqlFile(sql_file)

    ## Get cooling peak load components for each space
    base_query = "SELECT Value FROM TabularDataWithStrings"
    load_row_names = ['People', 'Lights', 'Equipment', 'Refrigeration', 'Water Use Equipment', 'HVAC Equipment Losses', 'Power Generation Equipment',
                 'DOAS Direct to Zone', 'Infiltration', 'Zone Ventilation', 'Interzone Mixing', 'Roof', 'Interzone Ceiling', 'Other Roof', 'Exterior Wall',
                 'Interzone Wall', 'Ground Contact Wall', 'Other Wall', 'Exterior Floor', 'Interzone Floor', 'Ground Contact Floor', 'Other Floor',
                 'Fenestration Conduction', 'Fenestration Solar', 'Opaque Door', 'Grand Total']
    load_column_names = ['Sensible - Instant', 'Sensible - Delayed', 'Sensible - Return Air', 'Latent', 'Total']
    peak_row_names =     ["Time of Peak Load", "Outside  Dry Bulb Temperature", "Outside  Wet Bulb Temperature", "Outside Humidity Ratio at Peak",
                          "Zone Dry Bulb Temperature", "Zone Relative Humidity", "Zone Humidity Ratio at Peak", "Supply Air Temperature", "Mixed Air Temperature",
                          "Main Fan Air Flow", "Outside Air Flow", "Peak Sensible Load with Sizing Factor", "Difference Due to Sizing Factor", "Peak Sensible Load",
                          "Estimated Instant + Delayed Sensible Load", "Difference Between Peak and Estimated Sensible Load"]
    peak_column_name = ['Value']

    component_loads = {}

    model.getThermalZones().each do |zone|
      zone_name = zone.name.get
      cooling_zone_query = base_query + " WHERE ReportForString == '#{zone_name.upcase}' AND TableName == 'Estimated Cooling Peak Load Components'"
      heating_zone_query = base_query + " WHERE ReportForString == '#{zone_name.upcase}' AND TableName == 'Estimated Cooling Peak Load Components'"

      space_loads = {"cooling": {"loads": {}, "peak_conditions": {}}, "heating": {"loads": {}, "peak_conditions": {}}}

      ## Get cooling loads
      load_row_names.each do |row_name|
        row_loads = {}

        load_column_names.each do |column_name|
          load_query = cooling_zone_query + " AND RowName == '#{row_name}' AND ColumnName == '#{column_name}'"

          load_result = sql_file.execAndReturnFirstDouble(load_query)

          if load_result.is_initialized
            row_loads[column_name] = load_result.get
          end
        end

        space_loads[:cooling][:loads][row_name] = row_loads
      end

      # Get heating loads
      load_row_names.each do |row_name|
        row_loads = {}

        load_column_names.each do |column_name|
          load_query = heating_zone_query + " AND RowName == '#{row_name}' AND ColumnName == '#{column_name}'"

          load_result = sql_file.execAndReturnFirstDouble(load_query)

          if load_result.is_initialized
            row_loads[column_name] = load_result.get
          end
        end

        space_loads[:heating][:loads][row_name] = row_loads
      end

      ## Get peak load components
      cooling_peak_conditions_query = base_query + " WHERE ReportForString == '#{zone_name.upcase}' AND TableName == 'Cooling Peak Conditions'"
      heating_peak_conditions_query = base_query + " WHERE ReportForString == '#{zone_name.upcase}' AND TableName == 'Heating Peak Conditions'"

      ## Get cooling peak conditions
      peak_row_names.each do |row_name|

        load_query = cooling_peak_conditions_query + " AND RowName == '#{row_name}' AND ColumnName == 'Value'"
        runner.registerInfo(load_query)
        load_result = sql_file.execAndReturnFirstDouble(load_query)

        if load_result.is_initialized
          space_loads[:cooling][:peak_conditions][row_name] = load_result.get
        end
      end

      ## Get heating peak conditions
      peak_row_names.each do |row_name|

        load_query = heating_peak_conditions_query + " AND RowName == '#{row_name}' AND ColumnName == 'Value'"
        runner.registerInfo(load_query)
        load_result = sql_file.execAndReturnFirstDouble(load_query)

        if load_result.is_initialized
          space_loads[:heating][:peak_conditions][row_name] = load_result.get
        end
      end

      zone.spaces.each do |space|
        id = space.additionalProperties.getFeatureAsString('CADObjectId')

        if id.is_initialized
          component_loads[id.get] = space_loads
        end
      end

    end

    ## Add Engineering Checks
    #
    ## Add Conditions at time of peak

    json_out = File.open("../loads_out.json", "w")
    json_out.write(component_loads.to_json)

    # close the sql file
    sql_file.close

    return true
  end
end

# register the measure to be used by the application
LoadsOutputReport.new.registerWithApplication
