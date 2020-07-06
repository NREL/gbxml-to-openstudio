# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

require 'rexml/document'
require 'rexml/xpath'
require 'openstudio-standards'

# require all .rb files in resources folder
Dir[File.dirname(__FILE__) + '/resources/*.rb'].each {|file| require file}

# start the measure
class SetSimulationControl < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Set Simulation Control'
  end

  # human readable description
  def description
    return 'The measures sets simulation control, timestep and convergence parameters.'
  end

  # human readable description of modeling approach
  def modeler_description
    return ''
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    start_date = OpenStudio::Measure::OSArgument.makeStringArgument("start_date", false)
    start_date.setDisplayName("Run Period Start Date")
    args << start_date

    end_date = OpenStudio::Measure::OSArgument.makeStringArgument("end_date", false)
    end_date.setDisplayName("Run Period End Date")
    args << end_date

    heating_sizing_factor = OpenStudio::Measure::OSArgument.makeDoubleArgument("heating_sizing_factor", false)
    heating_sizing_factor.setDisplayName("Heating Sizing Factor")
    args << heating_sizing_factor

    cooling_sizing_factor = OpenStudio::Measure::OSArgument.makeDoubleArgument("cooling_sizing_factor", false)
    cooling_sizing_factor.setDisplayName("Cooling Sizing Factor")
    args << cooling_sizing_factor

    timesteps = OpenStudio::Measure::OSArgument.makeIntegerArgument("timesteps_per_hour", false)
    timesteps.setDisplayName("Timesteps Per Hour")
    args << timesteps

    do_zone_sizing = OpenStudio::Measure::OSArgument.makeBoolArgument("do_zone_sizing", false)
    do_zone_sizing.setDisplayName("Do Zone Sizing?")
    do_zone_sizing.setDefaultValue(true)
    args << do_zone_sizing

    do_system_sizing = OpenStudio::Measure::OSArgument.makeBoolArgument("do_system_sizing", false)
    do_system_sizing.setDisplayName("Do System Sizing?")
    do_system_sizing.setDefaultValue(true)
    args << do_system_sizing

    do_plant_sizing = OpenStudio::Measure::OSArgument.makeBoolArgument("do_plant_sizing", false)
    do_plant_sizing.setDisplayName("Do Plant Sizing?")
    do_plant_sizing.setDefaultValue(true)
    args << do_plant_sizing

    sim_for_sizing = OpenStudio::Measure::OSArgument.makeBoolArgument("sim_for_sizing", false)
    sim_for_sizing.setDisplayName("Run Simulation for Sizing Period?")
    sim_for_sizing.setDefaultValue(false)
    args << sim_for_sizing

    sim_for_run_period = OpenStudio::Measure::OSArgument.makeBoolArgument("sim_for_run_period", false)
    sim_for_run_period.setDisplayName("Run Simulation for Weather File Run Period?")
    sim_for_run_period.setDefaultValue(true)
    args << sim_for_run_period

    max_warmup_days = OpenStudio::Measure::OSArgument.makeIntegerArgument("max_warmup_days", false)
    max_warmup_days.setDisplayName("Maximum Number of Warmup Days")
    args << max_warmup_days

    min_warmup_days = OpenStudio::Measure::OSArgument.makeIntegerArgument("min_warmup_days", false)
    min_warmup_days.setDisplayName("Minimum Number of Warmup Days")
    args << min_warmup_days

    loads_convergence_tolerance = OpenStudio::Measure::OSArgument.makeDoubleArgument("loads_convergence_tolerance", false)
    loads_convergence_tolerance.setDisplayName("Load Convergence Tolerance")
    args << loads_convergence_tolerance

    temp_convergence_tolerance = OpenStudio::Measure::OSArgument.makeDoubleArgument("temp_convergence_tolerance", false)
    temp_convergence_tolerance.setDisplayName("Temp Convergence Tolerance")
    args << temp_convergence_tolerance

    solar_choices = OpenStudio::StringVector.new
    solar_choices << "MinimalShadowing"
    solar_choices << "FullExterior"
    solar_choices << "FullInteriorAndExterior"
    solar_choices << "FullExteriorWithReflections"
    solar_choices << "FullInteriorAndExteriorWithReflections"
    solar_distribution = OpenStudio::Measure::OSArgument.makeChoiceArgument("solar_distribution", solar_choices, false)
    solar_distribution.setDisplayName("Solar Distribution")
    args << solar_distribution

    max_hvac_iterations = OpenStudio::Measure::OSArgument.makeIntegerArgument("max_hvac_iterations", false)
    max_hvac_iterations.setDisplayName("Maximum HVAC Iterations")
    args << max_hvac_iterations

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign the user inputs to variables
    start_date = runner.getOptionalStringArgumentValue("start_date", user_arguments)
    model_set_start_date(model, start_date.get) unless start_date.empty?

    end_date = runner.getOptionalStringArgumentValue("end_date", user_arguments)
    model_set_end_date(model, end_date.get) unless end_date.empty?

    heating_sizing_factor = runner.getOptionalDoubleArgumentValue("heating_sizing_factor", user_arguments)
    model.getSizingParameters.setHeatingSizingFactor(heating_sizing_factor.get) if heating_sizing_factor.is_initialized

    cooling_sizing_factor = runner.getOptionalDoubleArgumentValue("cooling_sizing_factor", user_arguments)
    model.getSizingParameters.setCoolingSizingFactor(cooling_sizing_factor.get) if cooling_sizing_factor.is_initialized

    timesteps = runner.getOptionalIntegerArgumentValue("timesteps_per_hour", user_arguments)
    model.getTimestep.setNumberOfTimestepsPerHour(timesteps.get) unless timesteps.empty?

    simulation_control = model.getSimulationControl
    do_zone_sizing = runner.getBoolArgumentValue("do_zone_sizing", user_arguments)
    simulation_control.setDoZoneSizingCalculation(do_zone_sizing)

    do_system_sizing = runner.getBoolArgumentValue("do_system_sizing", user_arguments)
    simulation_control.setDoSystemSizingCalculation(do_system_sizing)

    do_plant_sizing = runner.getBoolArgumentValue("do_plant_sizing", user_arguments)
    simulation_control.setDoPlantSizingCalculation(do_plant_sizing)

    sim_for_sizing = runner.getBoolArgumentValue("sim_for_sizing", user_arguments)
    simulation_control.setRunSimulationforSizingPeriods(sim_for_sizing)

    sim_for_run_period = runner.getBoolArgumentValue("sim_for_run_period", user_arguments)
    simulation_control.setRunSimulationforWeatherFileRunPeriods(sim_for_run_period)

    max_warmup_days = runner.getOptionalIntegerArgumentValue("max_warmup_days", user_arguments)
    simulation_control.setMaximumNumberofWarmupDays(max_warmup_days.get) unless max_warmup_days.empty?

    min_warmup_days = runner.getOptionalIntegerArgumentValue("min_warmup_days", user_arguments)
    simulation_control.setMinimumNumberofWarmupDays(min_warmup_days.get) unless min_warmup_days.empty?

    loads_convergence_tolerance = runner.getOptionalDoubleArgumentValue("loads_convergence_tolerance", user_arguments)
    simulation_control.setLoadsConvergenceToleranceValue(loads_convergence_tolerance.get) unless loads_convergence_tolerance.empty?

    temp_convergence_tolerance = runner.getOptionalDoubleArgumentValue("temp_convergence_tolerance", user_arguments)
    simulation_control.setTemperatureConvergenceToleranceValue(temp_convergence_tolerance.get) unless temp_convergence_tolerance.empty?

    solar_distribution = runner.getOptionalStringArgumentValue("solar_distribution", user_arguments)
    simulation_control.setSolarDistribution(solar_distribution.get) unless solar_distribution.empty?

    convergence_limits = model.getConvergenceLimits
    max_hvac_iterations = runner.getOptionalIntegerArgumentValue("max_warmup_days", user_arguments)
    convergence_limits.setMaximumHVACIterations(max_hvac_iterations.get) unless max_hvac_iterations.empty?
    return true
  end

  def model_set_start_date(model, date_string)
    date = Date.parse(date_string)
    model.getRunPeriod.setBeginDayOfMonth(date.day)
    model.getRunPeriod.setBeginMonth(date.month)
  end

  def model_set_end_date(model, date_string)
    date = Date.parse(date_string)
    model.getRunPeriod.setEndDayOfMonth(date.day)
    model.getRunPeriod.setEndMonth(date.month)
  end

end

# register the measure to be used by the application
SetSimulationControl.new.registerWithApplication
