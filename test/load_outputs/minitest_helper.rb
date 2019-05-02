require 'openstudio'
require 'minitest/autorun'

require_relative '../../measures/loads_output_report/loads_output_report'

module Config
  BASE_PATH = File.expand_path(__dir__)
  CLI_PATH = OpenStudio.getOpenStudioCLI
  RESOURCES = File.join(BASE_PATH + '/resources')

end