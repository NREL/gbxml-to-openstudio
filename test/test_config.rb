require 'openstudio'
require 'json'

module TestConfig
  BASE_PATH = File.expand_path(__dir__ + '/..')
  CLI_PATH = OpenStudio.getOpenStudioCLI
  GBXML_FILES = File.join(BASE_PATH + '/test/resources/test_gbxmls')
  REVIT_MODELS = File.join(BASE_PATH + '/test/resources/revit_test_models')
  TEST_OUTPUT_PATH = File.join(BASE_PATH + '/test/output_models')
  WEATHER_FILE_PATH = 'USA_CO_Denver.Intl.AP.725650_TMY3.epw'
  WORKFLOW_FILE_PATHS = ['../../weather', '../../seeds', '../../gbxmls']
  WORKFLOW_MEASURE_PATHS = ['../../measures']
  WORKFLOW_TEMPLATE_PATH = File.join(BASE_PATH + '/test/resources/workflow_template.osw')

  # generates an osw file with a given directory lookups and a seed file and weather file
  #
  # @param file_paths [Array<OpenStudio::Path>] directories to add for file lookup
  # @param measure_paths [Array<OpenStudio::Path>] directories to add for measure lookup
  # @param seed_filepath [OpenStudio::Path] filepath to seed osm file
  # @param epw_filepath [OpenStudio::Path] filepath to epw file
  # @return [OpenStudio::WorkflowJSON] osw file
  def self.create_osw(file_paths: [], measure_paths: [], seed_filepath: nil, epw_filepath: nil)
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
  def self.create_gbxml_test_osw
    file_paths = []
    file_paths << OpenStudio::Path.new('../../../weather')
    file_paths << OpenStudio::Path.new('../../../seeds')
    file_paths << OpenStudio::Path.new('../../resources/test_gbxmls')
    measure_paths = []
    measure_paths << OpenStudio::Path.new('../../../measures')
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
  def self.add_osw_measure_steps(osw, model_measure_steps: [], energyplus_measure_steps: [], reporting_measure_steps: [])
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
  # @return [OpenStudio::WorkflowJSON] osw file with measure steps
  def self.add_gbxml_test_measure_steps(osw, gbxml_file_name)
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
    m.setArgument('weather_file_name', 'USA_CO_Denver.Intl.AP.725650_TMY3.epw')
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

end