require 'openstudio'
require 'minitest/autorun'
require 'json'
require 'open3'

require_relative '../../measures/gbxml_import_hvac/gbxml_import_hvac'
require_relative 'config'
# require_relative '../measures/loads_output_report/resources/repository'
# require_relative '../measures/loads_output_report/resources/coil_sizing_detail'


# DLM: requiring this file doesn't seem correct right here

def create_test_sizing_osw
  os_path = OpenStudio::Path.new(Config::SIZING_WORKFLOW)
  workflow_json = OpenStudio::WorkflowJSON.load(os_path).get

  workflow_json.resetFilePaths
  workflow_json.resetMeasurePaths
  workflow_json.resetSeedFile

  workflow_json.addFilePath(OpenStudio::Path.new('../../resources/weather'))
  workflow_json.addFilePath(OpenStudio::Path.new('../../../seeds'))
  workflow_json.addFilePath(OpenStudio::Path.new('../../resources/test_gbxmls'))
  workflow_json.addMeasurePath(OpenStudio::Path.new('../../../../measures'))
  # puts workflow_json
  workflow_json
end

def create_test_annual_osw
  os_path = OpenStudio::Path.new(Config::ANNUAL_WORKFLOW)
  workflow_json = OpenStudio::WorkflowJSON.load(os_path).get

  workflow_json.resetFilePaths
  workflow_json.resetMeasurePaths
  workflow_json.resetSeedFile

  workflow_json.addFilePath(OpenStudio::Path.new('../../resources/weather'))
  workflow_json.addFilePath(OpenStudio::Path.new('../../../seeds'))
  workflow_json.addFilePath(OpenStudio::Path.new('../../resources/test_gbxmls'))
  workflow_json.addMeasurePath(OpenStudio::Path.new('../../../../measures'))
  # puts workflow_json
  workflow_json
end

def adjust_gbxml_paths(osw, gbxml_path)
  osw.getMeasureSteps(OpenStudio::MeasureType.new("ModelMeasure")).each do |measure_step|
    if ["gbxml_import", "gbxml_import_advanced", "gbxml_import_hvac"].include? measure_step.measureDirName
      measure_step.setArgument("gbxml_file_name", gbxml_path)
    end
  end

  osw
end

def create_standard_osw(gbxml_name)
  workflow = OpenStudio::WorkflowJSON.new

  workflow_template = OpenStudio::WorkflowJSON.load(Config::WORKFLOW_TEMPLATE_PATH).get
  workflow.setWorkflowSteps(workflow_template.workflowSteps)

  workflow.workflowSteps.each do |step|
    step = step.to_MeasureStep.get
    step.arguments.each do |argument|
      if argument == 'gbxml_file_name'
        step.setArgument(argument, gbxml_name)
      end
    end
  end

  Config::WORKFLOW_FILE_PATHS.each do |file_path|
    workflow.addFilePath(file_path)
  end

  Config::WORKFLOW_MEASURE_PATHS.each do |measure_path|
    workflow.addMeasurePath(measure_path)
  end

  workflow
end

# generates an osw file with a given directory lookups and a seed file and weather file
#
# @param file_paths [Array<OpenStudio::Path>] directories to add for file lookup
# @param measure_paths [Array<OpenStudio::Path>] directories to add for measure lookup
# @param seed_filepath [OpenStudio::Path] filepath to seed osm file
# @param epw_filepath [OpenStudio::Path] filepath to epw file
# @return [OpenStudio::WorkflowJSON] osw file
def create_osw(file_paths: [], measure_paths: [], seed_filepath: nil, epw_filepath: nil)
  osw = OpenStudio::WorkflowJSON.new
  file_paths.each { |file_path| osw.addFilePath(file_path) }
  measure_paths.each { |measure_path| osw.addMeasurePath(measure_path) }
  osw.setSeedFile(seed_filepath) unless seed_filepath.nil?
  osw.setWeatherFile(epw_filepath) unless epw_filepath.nil?

  return osw
end

# generates an osw file with a directory lookups for project gbxml tests
#
# @return [OpenStudio::WorkflowJSON] osw file
def create_gbxml_test_osw
  file_paths = []
  file_paths << OpenStudio::Path.new('../../resources/weather')
  file_paths << OpenStudio::Path.new('../../../seeds')
  file_paths << OpenStudio::Path.new('../../resources/test_gbxmls')
  measure_paths = []
  measure_paths << OpenStudio::Path.new('../../../../measures')
  osw = create_osw(file_paths: file_paths, measure_paths: measure_paths)
  return osw
end

# adds measure steps to an osw file with measures passed in as an array
#
# @param osw [OpenStudio::WorkflowJSON] osw file without measure steps
# @param model_measure_steps [Array<OpenStudio::MeasureStep>] array of model measure steps
# @param energyplus_measure_steps [Array<OpenStudio::MeasureStep>] array of energyplus measure steps
# @param reporting_measure_steps [Array<OpenStudio::MeasureStep>] array of reporting measure steps
# @return [OpenStudio::WorkflowJSON] osw file with measure steps
def add_osw_measure_steps(osw, model_measure_steps: [], energyplus_measure_steps: [], reporting_measure_steps: [])
  if osw.nil?
    puts 'add_osw_measure_steps osw argument is empty; creating new osw'
    osw = OpenStudio::WorkflowJSON.new
  end

  unless osw.class == OpenStudio::WorkflowJSON
    puts 'add_osw_measure_steps osw argument is not a valid OpenStudio::WorkflowJSON'
    return false
  end

  unless model_measure_steps.empty?
    #puts 'attempting to add measure steps'
    #puts "input osw is a #{osw.class} and contains:\n#{osw}\n"
    #puts "input model_measure_steps is a #{model_measure_steps.class} and contains:\n#{model_measure_steps}\n"
    measure_type = OpenStudio::MeasureType.new("ModelMeasure")
    result = osw.setMeasureSteps(measure_type, model_measure_steps)
    #puts "result is #{result} output osw is a #{osw.class} and contains:\n#{osw}"
  end

  unless energyplus_measure_steps.empty?
    measure_type = OpenStudio::MeasureType.new("EnergyPlusMeasure")
    osw.setMeasureSteps(measure_type, energyplus_measure_steps)
  end

  unless reporting_measure_steps.empty?
    measure_type = OpenStudio::MeasureType.new("ReportingMeasure")
    osw.setMeasureSteps(measure_type, reporting_measure_steps)
  end

  return osw
end

# adds measure steps to an osw file for project gbxml tests
#
# @param osw [OpenStudio::WorkflowJSON] osw file without measure steps
# @param gbxml_file_name [String] filename of gbxml file
# @param weather_file_name [String] filename of weather file for 'Change Building Location' measure
# @return [OpenStudio::WorkflowJSON] osw file with measure steps
def add_gbxml_test_measure_steps(osw, gbxml_file_name, weather_file_name: 'USA_CO_Denver.Intl.AP.725650_TMY3.epw')
  if gbxml_file_name.nil? || gbxml_file_name == ''
    puts 'add_gbxml_test_measure_steps gbxml_file_name argument is empty'
    return false
  end

  # array of gbxml measures
  gbxml_measure_steps = []

  # add measure steps in order
  m = OpenStudio::MeasureStep.new("import_gbxml")
  m.setName('ImportGbxml')
  m.setArgument('gbxml_file_name', gbxml_file_name)
  gbxml_measure_steps << m

  m = OpenStudio::MeasureStep.new("advanced_import_gbxml")
  m.setName('Advanced Import Gbxml')
  m.setArgument('gbxml_file_name', gbxml_file_name)
  gbxml_measure_steps << m

  m = OpenStudio::MeasureStep.new("gbxml_hvac_import")
  m.setName('GBXML HVAC Import')
  m.setArgument('gbxml_file_name', gbxml_file_name)
  gbxml_measure_steps << m

  m = OpenStudio::MeasureStep.new("ChangeBuildingLocation")
  m.setName('Change Building Location')
  m.setArgument('weather_file_name', weather_file_name)
  gbxml_measure_steps << m

  m = OpenStudio::MeasureStep.new("SpaceTypeAndConstructionSetWizard")
  m.setName('Space Type and Construction Set Wizard')
  m.setDescription('Create space types and or construction sets for the requested building type, climate zone, and target.')
  m.setModelerDescription('The data for this measure comes from the openstudio-standards Ruby Gem. They are no longer created from the same JSON file that was used to make the OpenStudio templates. Optionally this will also set the building default space type and construction set.')
  gbxml_measure_steps << m

  m = OpenStudio::MeasureStep.new("SetThermostatSchedules")
  m.setName('Set Thermostat Schedules')
  m.setDescription('Sets zone thermostat schedules to schedules in the same file. If a zone does not have a thermostat this measure will add one.')
  m.setModelerDescription('Sets zone thermostat schedules to schedules in the same file. If a zone does not have a thermostat this measure will add one.')
  m.setArgument('cooling_sch', 'OfficeSmall CLGSETP_SCH_NO_OPTIMUM')
  m.setArgument('heating_sch', 'OfficeSmall HTGSETP_SCH_NO_OPTIMUM')
  gbxml_measure_steps << m

  # measure steps to osw
  osw = add_osw_measure_steps(osw, model_measure_steps: gbxml_measure_steps)

  return osw
end

# DLM: code for running CLI calls from openstudio-standards
def get_run_env()
  # blank out bundler and gem path modifications, will be re-setup by new call
  new_env = {}
  new_env["BUNDLER_ORIG_MANPATH"] = nil
  new_env["BUNDLER_ORIG_PATH"] = nil
  new_env["BUNDLER_VERSION"] = nil
  new_env["BUNDLE_BIN_PATH"] = nil
  new_env["RUBYLIB"] = nil
  new_env["RUBYOPT"] = nil
  
  # DLM: preserve GEM_HOME and GEM_PATH set by current bundle because we are not supporting bundle
  # requires to ruby gems will work, will fail if we require a native gem
  #new_env["GEM_PATH"] = nil
  #new_env["GEM_HOME"] = nil
  
  # DLM: for now, ignore current bundle in case it has binary dependencies in it
  #bundle_gemfile = ENV['BUNDLE_GEMFILE']
  #bundle_path = ENV['BUNDLE_PATH']    
  #if bundle_gemfile.nil? || bundle_path.nil?
    new_env['BUNDLE_GEMFILE'] = nil
    new_env['BUNDLE_PATH'] = nil
  #else
  #  new_env['BUNDLE_GEMFILE'] = bundle_gemfile
  #  new_env['BUNDLE_PATH'] = bundle_path    
  #end  
  
  return new_env
end

def run_command(command)
  stdout_str, stderr_str, status = Open3.capture3(get_run_env(), command)
  if status.success?
    puts "Command completed successfully"
    puts "stdout: #{stdout_str}"
    puts "stderr: #{stderr_str}"
    return true
  else
    puts "Error running command: '#{command}'"
    puts "stdout: #{stdout_str}"
    puts "stderr: #{stderr_str}"
    return false 
  end
end