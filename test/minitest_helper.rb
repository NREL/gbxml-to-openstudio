require 'openstudio'
require 'minitest/autorun'
require 'json'
require 'open3'

require_relative 'test_config'

# DLM: requiring this file doesn't seem correct right here
require_relative '../measures/gbxml_hvac_import/resources/model_manager/model_manager'

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
    #puts "stdout: #{stdout_str}"
    #puts "stderr: #{stderr_str}"
    return true
  else
    puts "Error running command: '#{command}'"
    puts "stdout: #{stdout_str}"
    puts "stderr: #{stderr_str}"
    return false 
  end
end