# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'fileutils'

require_relative '../measure.rb'
require 'minitest/autorun'

class ChangeBuildingLocation_Test < Minitest::Test
  def run_dir(test_name)
    # will make directory if it doesn't exist
    output_dir = File.expand_path('output', File.dirname(__FILE__))
    FileUtils.mkdir output_dir unless Dir.exist? output_dir

    # always generate test output in specially named 'output' directory so result files are not made part of the measure
    "#{File.dirname(__FILE__)}/output/#{test_name}"
  end

  # method to apply arguments, run measure, and assert results (only populate args hash with non-default argument values)
  def apply_measure_to_model(test_name, args, model_name = nil, result_value = 'Success', warnings_count = 0, info_count = nil, num_dsn_days = 3)
    # create an instance of the measure
    measure = ChangeBuildingLocation.new

    # create an instance of a runner with OSW
    osw_path = OpenStudio::Path.new(File.dirname(__FILE__) + '/model_test.osw')
    osw = OpenStudio::WorkflowJSON.load(osw_path).get
    runner = OpenStudio::Measure::OSRunner.new(osw)

    # get model
    if model_name.nil?
      # make an empty model
      model = OpenStudio::Model::Model.new
    else
      # load the test model
      translator = OpenStudio::OSVersion::VersionTranslator.new
      path = OpenStudio::Path.new(File.dirname(__FILE__) + '/' + model_name)
      model = translator.loadModel(path)
      assert(!model.empty?)
      model = model.get
    end

    # get arguments
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if args.key?(arg.name)
        assert(temp_arg_var.setValue(args[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # temporarily change directory to the run directory and run the measure (because of sizing run)
    start_dir = Dir.pwd
    begin
      unless Dir.exist?(run_dir(test_name))
        Dir.mkdir(run_dir(test_name))
      end
      Dir.chdir(run_dir(test_name))

      # run the measure
      measure.run(model, runner, argument_map)
      result = runner.result
    ensure
      Dir.chdir(start_dir)

      # delete sizing run dir
      FileUtils.rm_rf(run_dir(test_name))
    end

    # show the output
    puts "measure results for #{test_name}"
    show_output(result)

    # assert that it ran correctly
    if result_value.nil? then result_value = 'Success' end
    assert_equal(result_value, result.value.valueName)

    # check count of warning and info messages
    unless info_count.nil? then assert(result.info.size == info_count) end
    unless warnings_count.nil? then assert(result.warnings.size == warnings_count) end

    # if 'Fail' passed in make sure at least one error message (while not typical there may be more than one message)
    if result_value == 'Fail' then assert(result.errors.size >= 1) end

    # For tests expected to succeed, check for design days in the model
    if result.value.valueName == 'Success'
      assert_equal(num_dsn_days, model.getDesignDays.size, "Expected #{num_dsn_days} but found #{model.getDesignDays.size}.")
    end

    # save the model to test output directory
    output_file_path = OpenStudio::Path.new(File.dirname(__FILE__) + "/output/#{test_name}_test_output.osm")
    model.save(output_file_path, true)
  end

  def test_weather_file
    args = {}
    args['weather_file_name'] = 'USA_MA_Boston-Logan.Intl.AP.725090_TMY3.epw' # seems to search directory of OSW even with empty file_paths
    apply_measure_to_model(__method__.to_s.gsub('test_', ''), args, 'model_test.osm', nil, nil, nil)
  end

  def test_weather_file_WA_Renton
    args = {}
    args['weather_file_name'] = 'USA_WA_Renton.Muni.AP.727934_TMY3.epw' # seems to search directory of OSW even with empty file_paths
    args['set_year'] = 2012
    apply_measure_to_model(__method__.to_s.gsub('test_', ''), args, 'model_test.osm', nil, 2, nil, 0)
  end

  def test_weather_file_WA_Renton_test_as_deer
    args = {}
    args['weather_file_name'] = 'USA_WA_Renton.Muni.AP.727934_TMY3.epw' # seems to search directory of OSW even with empty file_paths
    args['climate_zone'] = 'CEC T24-CEC5'
    args['use_upstream_args'] = false
    apply_measure_to_model(__method__.to_s.gsub('test_', ''), args, 'model_test.osm', nil, 2, nil, 0)
  end

  def test_multiyear_weather_file
    args = {}
    args['weather_file_name'] = 'multiyear.epw' # seems to search directory of OSW even with empty file_paths
    apply_measure_to_model(__method__.to_s.gsub('test_', ''), args, 'model_test.osm', nil, nil, nil)
  end

  def test_weather_file_bad
    args = {}
    args['weather_file_name'] = 'BadFileName.epw' # seems to search directory of OSW even with empty file_paths
    apply_measure_to_model(__method__.to_s.gsub('test_', ''), args, 'model_test.osm', 'Fail', nil, nil)
  end

  def test_weather_file_monthly_design_days
    args = {}
    args['weather_file_name'] = 'CA_LOS-ANGELES-IAP_722950S_12.epw' # seems to search directory of OSW even with empty file_paths
    apply_measure_to_model(__method__.to_s.gsub('test_', ''), args, 'model_test.osm', nil, nil, nil, 10)
  end

  def test_swap
    args = {}
    args['weather_file_name'] = 'USA_MA_Boston-Logan.Intl.AP.725090_TMY3.epw'
    args['epw_gsub'] = 'TMY3,AMY'
    apply_measure_to_model(__method__.to_s.gsub('test_', ''), args, 'model_test_with_epw.osm', nil, nil)
  end
end
