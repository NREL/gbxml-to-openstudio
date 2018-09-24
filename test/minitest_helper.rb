require 'openstudio'
require 'minitest/autorun'
require 'json'

require_relative '../measures/gbxml_hvac_import/resources/model_manager/model_manager'
require_relative 'test_config'

def create_standard_osw(gbxml_name)
  workflow = OpenStudio::WorkflowJSON.new

  workflow_template = OpenStudio::WorkflowJSON.load(TestConfig::WORKFLOW_TEMPLATE_PATH).get
  workflow.setWorkflowSteps(workflow_template.workflowSteps)

  workflow.workflowSteps.each do |step|
    step = step.to_MeasureStep.get
    step.arguments.each do |argument|
      if argument == 'gbxml_file_name'
        step.setArgument(argument, gbxml_name)
      end
    end
  end

  TestConfig::WORKFLOW_FILE_PATHS.each do |file_path|
    workflow.addFilePath(file_path)
  end

  TestConfig::WORKFLOW_MEASURE_PATHS.each do |measure_path|
    workflow.addMeasurePath(measure_path)
  end

  workflow
end

# create_standard_osw('blah.xml')