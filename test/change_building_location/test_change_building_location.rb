require_relative 'minitest_helper'

class TestChangeBuildingLocation < Minitest::Test

  def test_run_measure
    measure = ChangeBuildingLocation.new

    model = OpenStudio::Model::Model.new
    osw = OpenStudio::WorkflowJSON.new
    osw.addFilePath('test/change_building_location/resources/weather_files')
    runner = OpenStudio::Measure::OSRunner.new(osw)

    args = OpenStudio::Measure::OSArgumentVector.new
    weather_file_name = OpenStudio::Measure::OSArgument.makeStringArgument('weather_file_name', true)
    weather_file_name.setValue("USA_MA_Boston-Logan.Intl.AP.725090_TMY3.epw")

    args << weather_file_name

    arg_map = OpenStudio::Measure.convertOSArgumentVectorToMap(args)
    measure.run(model, runner, arg_map)
    # puts model.getDesignDays
    # model.save(OpenStudio::Path.new("out.osm"))
  end
end
