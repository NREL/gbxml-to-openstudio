require_relative 'minitest_helper'
require 'fileutils'
require 'tmpdir'

class TestChangeBuildingLocation < Minitest::Test

  WEATHER_FILES_DIR = 'test/change_building_location/resources/weather_files'.freeze

  # build an argument map with defaults, overridden by the values in arg_values
  def argument_map(measure, model, arg_values)
    arguments = measure.arguments(model)
    arg_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)
    arguments.each do |argument|
      value = arg_values[argument.name]
      next if value.nil?

      temp_argument = argument.clone
      assert(temp_argument.setValue(value))
      arg_map[argument.name] = temp_argument
    end
    arg_map
  end

  def test_run_measure
    measure = ChangeBuildingLocation.new

    model = OpenStudio::Model::Model.new
    osw = OpenStudio::WorkflowJSON.new
    osw.addFilePath(WEATHER_FILES_DIR)
    runner = OpenStudio::Measure::OSRunner.new(osw)

    arg_map = argument_map(measure, model, 'weather_file_name' => 'USA_MA_Boston-Logan.Intl.AP.725090_TMY3.epw')
    measure.run(model, runner, arg_map)

    assert_equal('Success', runner.result.value.valueName)
    refute_empty(model.getDesignDays)
  end

  def test_run_measure_with_ashrae_tau_2017_ddy
    epw_name = 'USA_CO_Denver.Intl.AP.725650_TMY3.epw'
    base_name = File.basename(epw_name, '.epw')

    Dir.mktmpdir('ashrae_tau_2017') do |weather_dir|
      FileUtils.cp(File.join(WEATHER_FILES_DIR, epw_name), weather_dir)
      FileUtils.cp(File.join(WEATHER_FILES_DIR, "#{base_name}.stat"), weather_dir)

      ddy_file = File.join(weather_dir, "#{base_name}.ddy")
      File.write(ddy_file, File.read(File.join(WEATHER_FILES_DIR, "#{base_name}.ddy")).gsub('ASHRAETau,', 'ASHRAETau2017,'))
      assert_includes(File.read(ddy_file), 'ASHRAETau2017')

      # the unmodified ddy file cannot be translated prior to OpenStudio 3.10.0
      if Gem::Version.new(OpenStudio.openStudioVersion) < Gem::Version.new('3.10.0')
        raw_ddy_model = OpenStudio::EnergyPlus.loadAndTranslateIdf(ddy_file)
        assert(raw_ddy_model.empty? || raw_ddy_model.get.getDesignDays.empty?,
               'Expected the ASHRAETau2017 ddy file to fail to translate on this OpenStudio version.')
      end

      measure = ChangeBuildingLocation.new
      model = OpenStudio::Model::Model.new
      osw = OpenStudio::WorkflowJSON.new
      osw.addFilePath(weather_dir)
      runner = OpenStudio::Measure::OSRunner.new(osw)

      arg_map = argument_map(measure, model, 'weather_file_name' => epw_name)
      measure.run(model, runner, arg_map)

      assert_equal('Success', runner.result.value.valueName)
      assert(runner.result.stepInfo.any? { |info| info.include?('ASHRAETau2017') },
             'Expected the measure to report replacing the ASHRAETau2017 Solar Model Indicator.')
      refute_empty(model.getDesignDays, 'Expected design days to be added from the ASHRAETau2017 ddy file.')
    end
  end
end
