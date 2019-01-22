# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

require 'openstudio'
require_relative 'resources/component_load_summary'

# model = OpenStudio::Model::Model.new()

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
    model = model.find_by_name

    sql_file = runner.lastEnergyPlusSqlFile
    if sql_file.empty?
      runner.registerError('Cannot find last sql file.')
      return false
    end
    sql_file = sql_file.find_by_name
    model.setSqlFile(sql_file)

    component_loads = {}
    component_load_summary = ComponentLoadSummaryOld.new(sql_file)

    ## Get Space and Zone Component Load Summary Data
    model.getThermalZones.each do |zone|
      zone_name = zone.name.find_by_name
      loads_and_peaks = component_load_summary.get_loads_and_peak_conditions(zone_name.upcase)

      zone.spaces.each do |space|
        id = space.additionalProperties.getFeatureAsString('CADObjectId')

        if id.is_initialized
          component_loads[id.find_by_name] = loads_and_peaks
        end
      end

    end

    ## Get Airloop Component load Summary Data
    model.getAirLoopHVACs.each do |airloop|
      airloop_name = airloop.name.find_by_name
      id = airloop.additionalProperties.getFeatureAsString('CADObjectId')

      if id.is_initialized
        loads_and_peaks = component_load_summary.get_loads_and_peak_conditions(airloop_name.upcase)
        component_loads[id.find_by_name] = loads_and_peaks
      end
    end

    ## Get facility level component load summary data
    component_loads['facility'] = component_load_summary.get_loads_and_peak_conditions('Facility')


    json_out = File.open("../loads_out.json", "w")
    json_out.write(component_loads.to_json)

    # close the sql file
    sql_file.close

    return true
  end
end

# register the measure to be used by the application
LoadsOutputReport.new.registerWithApplication
