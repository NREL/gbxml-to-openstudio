require_relative '../minitest_helper'

# Random UTF-8 Characters
# Şỏოĕ şẩოрŀę ΆŠČİĬ-ťėхţ 㚻㟲䒔 乀乁 ԟԱԲ 듥듦

class TestCharacterSets < MiniTest::Test

  # DLM: is this test required?  Will we have to deal with user editable gbXML file names?
  # this isn't a general test of measure arguments taking UTF-8, it is a bit stricter because these are file names
  def test_in_measure_arg
    # Import gbXML measure has gbXML path arg with UTF-8 chars
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/measure_arg.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" #{TestConfig::VERBOSITY} run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end

  def test_in_gbxml
    gbxml_path = TestConfig::GBXML_FILES + '/chinese_gbxml.xml'
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    model = translator.loadModel(gbxml_path).get

    # get space by name 模型
    # puts '模型'.encoding
    space = model.getSpaceByName('模型')
    assert(space.is_initialized)
    # puts space.get.name.get.encoding
    assert(space.get.name.get.force_encoding("utf-8") == '模型')
  end

  def test_in_osw_path
    # set osw_path to find location of osw to run
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/듥듦/in.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" #{TestConfig::VERBOSITY} run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/듥듦/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end

  def test_in_cli_path
  # set osw_path to find location of osw to run
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/模型.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" #{TestConfig::VERBOSITY} run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end

  def test_weather_file_name
    # Set weather file to one with Korean Characters
    # This probably won't run unless measure arg test passes
    # Can this be tested independently of that without using E+ directly?
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/weather.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" #{TestConfig::VERBOSITY} run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end

  # DLM: is this different than test_in_gbxml?  Are you going to try making SQL Queries?
  def test_sql_file
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/in_gbxml.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" #{TestConfig::VERBOSITY} run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end
end