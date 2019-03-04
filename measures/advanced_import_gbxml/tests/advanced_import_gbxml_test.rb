# insert your copyright here

require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'minitest/autorun'
require_relative '../measure.rb'
require 'fileutils'

class AdvancedImportGbxml_Test < Minitest::Test

  def test_generic_gbxml

    # create an instance of the measure
    measure = AdvancedImportGbxml.new

     # create runner with empty OSW
    osw = OpenStudio::WorkflowJSON.new
    runner = OpenStudio::Measure::OSRunner.new(osw)

    # locate the gbxml
    path = OpenStudio::Path.new(File.dirname(__FILE__) + '/gbXMLStandard Test Model 2016.xml')

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
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # run the measure
    measure.run(model, runner, argument_map)
    result = runner.result

    # show the output
    show_output(result)

    # assert that it ran correctly
    assert_equal('Success', result.value.valueName)
    assert(result.warnings.size == 0)

    # save the model to test output directory
    output_file_path = OpenStudio::Path.new(File.dirname(__FILE__) + '/output/generic_test_output.osm')
    model.save(output_file_path, true)
  end

  def test_custom_gbxml_01

    # create an instance of the measure
    measure = AdvancedImportGbxml.new

    # create runner with empty OSW
    osw = OpenStudio::WorkflowJSON.new
    runner = OpenStudio::Measure::OSRunner.new(osw)

    # locate the gbxml
    path = OpenStudio::Path.new(File.dirname(__FILE__) + '/Analytical Systems 01.xml')

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
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # run the measure
    measure.run(model, runner, argument_map)
    result = runner.result

    # show the output
    show_output(result)

    # assert that it ran correctly
    assert_equal('Success', result.value.valueName)
    #assert(result.warnings.size == 0)

    # save the model to test output directory
    output_file_path = OpenStudio::Path.new(File.dirname(__FILE__) + '/output/analytical_test_output.osm')
    model.save(output_file_path, true)
  end

  def test_people_number

    # create an instance of the measure
    measure = AdvancedImportGbxml.new

    # create runner with empty OSW
    osw = OpenStudio::WorkflowJSON.new
    runner = OpenStudio::Measure::OSRunner.new(osw)

    # locate the gbxml
    path = OpenStudio::Path.new(File.dirname(__FILE__) + '/Test Villa Scenario 2_alt_a.xml')

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
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # run the measure
    measure.run(model, runner, argument_map)
    result = runner.result

    # show the output
    show_output(result)

    # assert that it ran correctly
    assert_equal('Success', result.value.valueName)
    #assert(result.warnings.size == 0)

    # save the model to test output directory
    output_file_path = OpenStudio::Path.new(File.dirname(__FILE__) + '/output/people_number_test_output.osm')
    model.save(output_file_path, true)
  end

  def test_infiltration_and_ventilation

    # create an instance of the measure
    measure = AdvancedImportGbxml.new

    # create runner with empty OSW
    osw = OpenStudio::WorkflowJSON.new
    runner = OpenStudio::Measure::OSRunner.new(osw)

    # locate the gbxml
    path = OpenStudio::Path.new(File.dirname(__FILE__) + '/VentilationAndInfiltration.xml')

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
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # run the measure
    measure.run(model, runner, argument_map)
    result = runner.result

    # show the output
    show_output(result)

    # assert that it ran correctly
    assert_equal('Success', result.value.valueName)
    #assert(result.warnings.size == 0)

    # save the model to test output directory
    output_file_path = OpenStudio::Path.new(File.dirname(__FILE__) + '/output/test_infiltration_and_ventilation.osm')
    model.save(output_file_path, true)
  end

end
