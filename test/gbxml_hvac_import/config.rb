require 'openstudio'
require 'json'

module Config
  BASE_PATH = File.expand_path(__dir__)
  CLI_PATH = OpenStudio.getOpenStudioCLI
  GBXML_FILES = File.join(BASE_PATH + '/resources/test_gbxmls')
  REVIT_MODELS = File.join(BASE_PATH + '/resources/revit_test_models')
  TEST_OUTPUT_PATH = File.join(BASE_PATH + '/output_models')
  TEST_RESOURCES = File.join(BASE_PATH + '/resources')
  WEATHER_FILE_PATH = 'USA_CO_Denver.Intl.AP.725650_TMY3.epw'
  # WORKFLOW_FILE_PATHS = ['../../weather', '../../seeds', '../../gbxmls']
  WORKFLOW_MEASURE_PATHS = ['../../../../measures']
  WORKFLOW_TEMPLATE_PATH = File.join(BASE_PATH + '/test/resources/workflow_template.osw')
end

