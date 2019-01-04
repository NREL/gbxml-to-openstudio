require_relative '../minitest_helper'

# Random UTF-8 Characters
# Şỏოĕ şẩოрŀę ΆŠČİĬ-ťėхţ 㚻㟲䒔 乀乁 ԟԱԲ 듥듦

class TestCharacterSets < MiniTest::Test
  def test_create_osws
    osw = create_gbxml_test_osw
    osw = add_gbxml_test_measure_steps(osw, 'CAVBoxAllVariations.xml')
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/in.osw'
    osw.saveAs(osw_in_path)
    # rename the .osw once written, as the .saveAs method can't handle chinese characters
    osw_rename_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/模型/in.osw'
    File.rename(osw_in_path, osw_rename_path)

    osw = create_gbxml_test_osw
    osw = add_gbxml_test_measure_steps(osw, 'chinese_gbxml.xml')
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/in_gbxml.osw'
    osw.saveAs(osw_in_path)

    osw = create_gbxml_test_osw
    osw = add_gbxml_test_measure_steps(osw, '模型.xml')
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/measure_arg.osw'
    osw.saveAs(osw_in_path)

    osw = create_gbxml_test_osw
    osw = add_gbxml_test_measure_steps(osw, 'CAVBoxAllVariations.xml', weather_file_name: '듥듦.epw')
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/weather.osw'
    osw.saveAs(osw_in_path)

    osw = create_gbxml_test_osw
    osw = add_gbxml_test_measure_steps(osw, 'CAVBoxAllVariations.xml')
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/chinese_characters.osw'
    osw.saveAs(osw_in_path)
    # rename the .osw once written, as the .saveAs method can't handle chinese characters
    osw_rename_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/模型.osw'
    File.rename(osw_in_path, osw_rename_path)
  end

  def test_in_measure_arg
    # Import gbXML measure has gbXML path arg with UTF-8 chars
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/measure_arg.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" run -w \"#{osw_in_path}\""
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
    assert(space.get.name.get == '模型')

    # OSM seems to store as ASCII-8Bit rather than UTF-8.
    # Part of our workflow relies on the C++ translator and then later grabbing those elements by name in measures
    # Not the most stable solution but it's temporary until we get Revit IDs into OSM additionalProperties
    # Moreover, users can adjust the measures themselves and I imagine they'll grab objects by name often
    # This works -> assert(space.get.name.get.force_encoding('UTF-8') == '模型')
  end

  def test_in_osw_path
    # set osw_path to find location of osw to run
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/듥듦/in.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/듥듦/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end

  def test_in_cli_path
  # set osw_path to find location of osw to run
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/模型.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" run -w \"#{osw_in_path}\""
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
    cmd = "\"#{TestConfig::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end

  def test_sql_file
    osw_in_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/in_gbxml.osw'
    cmd = "\"#{TestConfig::CLI_PATH}\" run -w \"#{osw_in_path}\""
    assert(run_command(cmd))

    osw_out_path = TestConfig::TEST_OUTPUT_PATH + '/character_sets/out.osw'
    osw_out = JSON.parse(File.read(osw_out_path))

    assert(osw_out['completed_status'] == 'Success')
  end
end