# insert your copyright here

require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'minitest/autorun'
require_relative '../measure.rb'
require_relative '../resources/os_lib_schedules'
require_relative '../resources/os_lib_adv_import'
require 'fileutils'

class AdvancedImportGbxml_Test < Minitest::Test

  def test_generic_gbxml

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
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    # run the measure
    puts "Running the measure under test"
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC, unit=:float_second)
    measure.run(model, runner, argument_map)
    finish = Process.clock_gettime(Process::CLOCK_MONOTONIC, unit=:float_second)
    puts "Measure took #{finish - start} seconds to run"

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

  def test_merge_schedule_ruleset
    model = OpenStudio::Model::Model.new
    expected_schedule_ruleset = OpenStudio::Model::ScheduleRuleset.new(model)

    hours = [3, 5, 7, 12, 15]
    values = [0, 1, 0, 1, 0]
    hours.each_with_index do |hour, i|
      time = OpenStudio::Time.new(0, hour, 0)
      expected_schedule_ruleset.defaultDaySchedule.addValue(time, values[i])
    end

    merged_schedule_ruleset = OpenStudio::Model::ScheduleRuleset.new(model)
    winter_design_day = OpenStudio::Model::ScheduleDay.new(model)
    winter_design_day.addValue(OpenStudio::Time.new(0, 24, 0), 0)

    summer_design_day = OpenStudio::Model::ScheduleDay.new(model)
    summer_design_day.addValue(OpenStudio::Time.new(0, 24, 0), 1)

    merged_schedule_ruleset.setWinterDesignDaySchedule(winter_design_day)
    merged_schedule_ruleset.setSummerDesignDaySchedule(summer_design_day)

    OsLib_Schedules.merge_schedule_rulesets(merged_schedule_ruleset, expected_schedule_ruleset)

    # Default day should match the expected schedule ruleset
    assert(merged_schedule_ruleset.defaultDaySchedule.values == expected_schedule_ruleset.defaultDaySchedule.values)
    assert(merged_schedule_ruleset.defaultDaySchedule.times == expected_schedule_ruleset.defaultDaySchedule.times)

    # The merge should not effect the design day schedules
    assert(merged_schedule_ruleset.winterDesignDaySchedule.times == winter_design_day.times)
    assert(merged_schedule_ruleset.winterDesignDaySchedule.values == winter_design_day.values)

    assert(merged_schedule_ruleset.summerDesignDaySchedule.times == summer_design_day.times)
    assert(merged_schedule_ruleset.summerDesignDaySchedule.values == summer_design_day.values)

  end

  def test_schedule_ruleset_edit_value_map
    model = OpenStudio::Model::Model.new
    schedule_ruleset = OpenStudio::Model::ScheduleRuleset.new(model)
    schedule_ruleset.defaultDaySchedule.addValue(OpenStudio::Time.new(0,1,0), 1)
    schedule_ruleset.defaultDaySchedule.addValue(OpenStudio::Time.new(0,24,0), 2)
    schedule_day = OpenStudio::Model::ScheduleDay.new(model, 2)
    schedule_rule = OpenStudio::Model::ScheduleRule.new(schedule_ruleset, schedule_day)

    OsLib_Schedules.schedule_ruleset_edit(schedule_ruleset, new_value_map: [[0, 1], [2, 0]])
    assert(schedule_ruleset.defaultDaySchedule.values == [1,0])
    assert(schedule_rule.daySchedule.values == [0.0])
  end

  def test_schedule_ruleset_edit_start_time_diff
    model = OpenStudio::Model::Model.new
    schedule_ruleset = OpenStudio::Model::ScheduleRuleset.new(model)
    default_day_expected_times = [OpenStudio::Time.new(0,20,0), OpenStudio::Time.new(0,24,0)]
    schedule_rule_expected_times = [OpenStudio::Time.new(0,1,30), OpenStudio::Time.new(0,24,0)]

    schedule_ruleset.defaultDaySchedule.addValue(OpenStudio::Time.new(0,1,0), 1)
    schedule_ruleset.defaultDaySchedule.addValue(OpenStudio::Time.new(0,20,0), 2)

    schedule_day = OpenStudio::Model::ScheduleDay.new(model, 2)
    schedule_day.addValue(OpenStudio::Time.new(0,3,0),0)
    schedule_rule = OpenStudio::Model::ScheduleRule.new(schedule_ruleset, schedule_day)

    OsLib_Schedules.schedule_ruleset_edit(schedule_ruleset, start_time_diff: 90)

    # Tests that value drops off if it is pushed before midnight from the start time
    assert(schedule_ruleset.defaultDaySchedule.times == default_day_expected_times)

    # Tests that the value is shifted back the appropriate amount of time
    assert(schedule_rule.daySchedule.times == schedule_rule_expected_times)

  end

  def test_assign_zone_attributes
    osw = OpenStudio::WorkflowJSON.new
    runner = OpenStudio::Measure::OSRunner.new(osw)

    model = OpenStudio::Model::Model.new

    zones = {"aim0123"=>{:name=>"ThermalZone1", :design_heat_t=>70.0, :design_cool_t=>74.0}}
    t_zone = OpenStudio::Model::ThermalZone.new(model)
    t_zone.setName("ThermalZone1")

    OsLib_AdvImport.assign_zone_attributes(runner, model, zones)
    heating_summer_dd = t_zone.thermostatSetpointDualSetpoint.get.getHeatingSchedule.get.to_ScheduleRuleset.get.summerDesignDaySchedule
    heating_winter_dd = t_zone.thermostatSetpointDualSetpoint.get.getHeatingSchedule.get.to_ScheduleRuleset.get.winterDesignDaySchedule
    heating_default_day = t_zone.thermostatSetpointDualSetpoint.get.getHeatingSchedule.get.to_ScheduleRuleset.get.defaultDaySchedule
    cooling_summer_dd = t_zone.thermostatSetpointDualSetpoint.get.getCoolingSchedule.get.to_ScheduleRuleset.get.summerDesignDaySchedule
    cooling_winter_dd = t_zone.thermostatSetpointDualSetpoint.get.getCoolingSchedule.get.to_ScheduleRuleset.get.winterDesignDaySchedule
    cooling_default_day = t_zone.thermostatSetpointDualSetpoint.get.getCoolingSchedule.get.to_ScheduleRuleset.get.defaultDaySchedule

    heating_day = OpenStudio::Model::ScheduleDay.new(model)
    heating_day.addValue(OpenStudio::Time.new(0,24,0), OpenStudio.convert(70.0, "F", "C").get)
    cooling_day = OpenStudio::Model::ScheduleDay.new(model)
    cooling_day.addValue(OpenStudio::Time.new(0,24,0), OpenStudio.convert(74.0, "F", "C").get)

    assert(data_fields_equal?(heating_day, heating_summer_dd))
    assert(data_fields_equal?(heating_day, heating_winter_dd))
    assert(data_fields_equal?(heating_day, heating_default_day))
    assert(data_fields_equal?(cooling_day, cooling_summer_dd))
    assert(data_fields_equal?(cooling_day, cooling_winter_dd))
    assert(data_fields_equal?(cooling_day, cooling_default_day))
  end

  def data_fields_equal?(obj1, obj2)
    if obj1.iddObjectType.valueName != obj2.iddObjectType.valueName
      return false
    end

    obj1.dataFields.each do |data_field|
      if data_field > 1
        unless obj1.getString(data_field).get == obj2.getString(data_field).get
          return false
        end
      end
    end

    return true
  end
end
