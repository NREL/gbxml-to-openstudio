class ChangeBuildingLocation < OpenStudio::Measure::ModelMeasure

  def name
    'ChangeBuildingLocation'
  end

  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    weather_file_name = OpenStudio::Measure::OSArgument.makeStringArgument('weather_file_name', true)
    weather_file_name.setDisplayName('Weather File Name')
    weather_file_name.setDescription('Name of the weather file to change to. This is the filename with the extension (e.g. NewWeather.epw). Optionally this can inclucde the full file path, but for most use cases should just be file name.')

    args << weather_file_name
    args
  end

  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    unless runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    weather_file_name = runner.getStringArgumentValue("weather_file_name", user_arguments)
    weather_file_path = runner.workflow.findFile(weather_file_name)

    if weather_file_path.empty?
      runner.registerError("Could not find gbXML filename '#{gbxml_file_name}'.")
      return false
    end

    weather_file_path = runner.workflow.findFile(weather_file_name).get

    epw_file = OpenStudio::EpwFile.load(weather_file_path).get
    OpenStudio::Model::WeatherFile.setWeatherFile(model, epw_file)

    water_temp = model.getSiteWaterMainsTemperature
    # water_temp.setAnnualAverageOutdoorAirTemperature(15)
    water_temp.setMaximumDifferenceInMonthlyAverageOutdoorAirTemperatures(10)

    ddy_file = "#{File.join(File.dirname(weather_file_path.to_s), File.basename(weather_file_path.filename.to_s, '.*'))}.ddy"

    unless ddy_file
      runner.registerError "Could not find DDY file for #{ddy_file}"
      return false
    end

    ddy_model = OpenStudio::EnergyPlus.loadAndTranslateIdf(ddy_file).get
    all_ddys = ddy_model.getObjectsByType('OS:SizingPeriod:DesignDay'.to_IddObjectType)
    htg_ddys = all_ddys.select {|ddy| ddy.name.get =~ /(99.6. Condns)/}
    htg_ddys = all_ddys.select {|ddy| ddy.name.get =~ /(99. Condns)/} if htg_ddys.empty?

    clg_ddys = all_ddys.select {|ddy| ddy.name.get =~ /(.4. Condns)/}
    # clg_ddys = all_ddys.select {|ddy| ddy.name.get =~ /(1. Condns)/} if clg_ddys.empty?
    clg_ddys = all_ddys.select {|ddy| ddy.name.get =~ /(2. Condns)/} if clg_ddys.empty?

    (htg_ddys + clg_ddys).each { |ddy| model.addObject(ddy) }

    true
  end
end

# This allows the measure to be use by the application
ChangeBuildingLocation.new.registerWithApplication
