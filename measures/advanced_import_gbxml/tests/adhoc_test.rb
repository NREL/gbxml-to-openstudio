require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'minitest/autorun'
require 'minitest/assertions'
require_relative '../measure.rb'
require_relative '../resources/os_lib_schedules'
require_relative '../resources/os_lib_adv_import'
require 'fileutils'

# create an instance of the measure
measure = AdvancedImportGbxml.new

# create runner with empty OSW
osw = OpenStudio::WorkflowJSON.new
runner = OpenStudio::Measure::OSRunner.new(osw)

# locate the gbxml
path = OpenStudio::Path.new(File.dirname(__FILE__) + '/200_SpacesOneZE.xml')

# use model from gbXML instead of empty model
translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
model = translator.loadModel(path).get

# get arguments
arguments = measure.arguments(model)
argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

# create hash of argument values
# If the argument has a default that you want to use, you don't need it in the hash
args_hash = {}
args_hash['gbxml_file_name'] = path.to_s
# using defaults values from measure.rb for other arguments

# populate argument with specified hash value if specified
arguments.each do |arg|
  temp_arg_var = arg.clone
  if args_hash.has_key?(arg.name)
    temp_arg_var.setValue(args_hash[arg.name])
  end
  argument_map[arg.name] = temp_arg_var
end

# run the measure
puts "Running the measure under test"
measure.run(model, runner, argument_map)
result = runner.result

puts 'finished running measure'
# show the output
# show_output(result)

# assert that it ran correctly
# assert_equal('Success', result.value.valueName)
# assert(result.warnings.size == 0)

# save the model to test output directory
output_file_path = OpenStudio::Path.new(File.dirname(__FILE__) + '/output/generic_test_output.osm')
model.save(output_file_path, true)

