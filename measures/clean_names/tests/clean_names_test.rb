# insert your copyright here

require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'minitest/autorun'
require_relative '../measure.rb'
require 'fileutils'

class CleanNamesTest < Minitest::Test
  # def setup
  # end

  # def teardown
  # end

  def test_good_argument_values
    # create an instance of the measure
    measure = CleanNames.new

    # create runner with empty OSW
    osw = OpenStudio::WorkflowJSON.new
    runner = OpenStudio::Measure::OSRunner.new(osw)

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = "#{File.dirname(__FILE__)}/encoding.osm"
    model = translator.loadModel(path)
    assert(!model.empty?)
    model = model.get

    # check spaces in seed model
    spaces = model.getSpaces
    assert_equal(2, spaces.size)
    spaces.each do |space|
      name = space.nameString.force_encoding(Encoding::UTF_8)
      assert(!name.ascii_only?)
    end

    # get arguments
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

    # create hash of argument values.
    # If the argument has a default that you want to use, you don't need it in the hash
    args_hash = {}
    # using defaults values from measure.rb for other arguments

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if args_hash.key?(arg.name)
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end
    
    current_dir = Dir.pwd
    rundir = "#{File.dirname(__FILE__)}//output/rundir/"
    FileUtils.rm_rf(rundir) if File.exists?(rundir)
    FileUtils.mkdir_p(rundir)
    
    assert(!File.exists?(File.join(rundir, 'oldname_report.osm')))
    assert(!File.exists?(File.join(rundir, 'name_mapping_report.csv')))
    
    result = nil
    begin
      Dir.chdir(rundir)

      # run the measure
      measure.run(model, runner, argument_map)
      result = runner.result
      
    ensure
      Dir.chdir(current_dir)
    end

    # show the output
    show_output(result)

    # assert that it ran correctly
    assert_equal('Success', result.value.valueName)
    assert(result.info.size == 0)
    assert(result.warnings.empty?)

    # check that there are same number of spaces
    spaces = model.getSpaces
    assert_equal(2, spaces.size)
    spaces.each do |space|
      name = space.nameString.force_encoding(Encoding::UTF_8)
      assert(name.ascii_only?)
    end
    
    assert(File.exists?(File.join(rundir, 'oldname_report.osm')))
    assert(File.exists?(File.join(rundir, 'name_mapping_report.csv')))
    
    # save the model to test output directory
    output_file_path = "#{File.dirname(__FILE__)}//output/test_output.osm"
    model.save(output_file_path, true)
  end
end
