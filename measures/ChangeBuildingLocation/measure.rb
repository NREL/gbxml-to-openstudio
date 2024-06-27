# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

# Authors : Nicholas Long, David Goldwasser
# Simple measure to load the EPW file and DDY file

class ChangeBuildingLocation < OpenStudio::Measure::ModelMeasure
  Dir[File.dirname(__FILE__) + '/resources/*.rb'].each { |file| require file }
  require 'openstudio-standards'

  # define the name that a user will see, this method may be deprecated as
  # the display name in PAT comes from the name field in measure.xml
  def name
    'ChangeBuildingLocation'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    weather_file_name = OpenStudio::Measure::OSArgument.makeStringArgument('weather_file_name', true)
    weather_file_name.setDisplayName('Weather File Name')
    weather_file_name.setDescription('Name of the weather file to change to. This is the filename with the extension (e.g. NewWeather.epw). Optionally this can inclucde the full file path, but for most use cases should just be file name.')
    args << weather_file_name

    # make choice argument for climate zone
    #choices = OpenStudio::StringVector.new
    choices = OpenstudioStandards::CreateTypical.get_climate_zones
    choices << 'Lookup From Stat File'

    climate_zone = OpenStudio::Measure::OSArgument.makeChoiceArgument('climate_zone', choices, true)
    climate_zone.setDisplayName('Climate Zone.')
    climate_zone.setDefaultValue('Lookup From Stat File')
    args << climate_zone

    set_year = OpenStudio::Measure::OSArgument.makeIntegerArgument('set_year', true)
    set_year.setDisplayName('Set Calendar Year')
    set_year.setDefaultValue 0
    set_year.setDescription('This will impact the day of the week the simulation starts on. An input value of 0 will leave the year un-altered')
    args << set_year

    # make an argument for use_upstream_args
    use_upstream_args = OpenStudio::Measure::OSArgument.makeBoolArgument('use_upstream_args', true)
    use_upstream_args.setDisplayName('Use Upstream Argument Values')
    use_upstream_args.setDescription('When true this will look for arguments or registerValues in upstream measures that match arguments from this measure, and will use the value from the upstream measure in place of what is entered for this measure.')
    use_upstream_args.setDefaultValue(true)
    args << use_upstream_args

    # make choice argument for climate zone
    choices = OpenStudio::StringVector.new
    choices << 'Do Nothing'
    choices << 'TMY3,AMY'
    choices << 'AMY,TMY3'
    epw_gsub = OpenStudio::Measure::OSArgument.makeChoiceArgument('epw_gsub', choices, true)
    epw_gsub.setDisplayName('Find and replace option from existing weather file name.')
    epw_gsub.setDescription('This will override what is entered in weather file name or from upstream measures, unless Do Nothing is selected.')
    epw_gsub.setDefaultValue('Do Nothing')
    args << epw_gsub

    args
  end

  # Define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # assign the user inputs to variables
    args = runner.getArgumentValues(arguments(model), user_arguments)
    args = Hash[args.collect{ |k, v| [k.to_s, v] }]
    if !args then return false end

    # lookup and replace argument values from upstream measures
    if args['use_upstream_args'] == true
      args.each do |arg, value|
        next if arg == 'use_upstream_args' # this argument should not be changed
        value_from_osw = runner.getPastStepValuesForName(arg)
        value_from_osw = value_from_osw.collect{ |k, v| Hash[:measure_name => k, :value => v] }.first if !value_from_osw.empty?
        if !value_from_osw.empty?
          runner.registerInfo("Replacing argument named #{arg} from current measure with a value of #{value_from_osw[:value]} from #{value_from_osw[:measure_name]}.")
          new_val = value_from_osw[:value]
          # TODO: - make code to handle non strings more robust. check_upstream_measure_for_arg coudl pass bakc the argument type
          if arg == 'total_bldg_floor_area'
            args[arg] = new_val.to_f
          elsif arg == 'num_stories_above_grade'
            args[arg] = new_val.to_f
          elsif arg == 'zipcode'
            args[arg] = new_val.to_i
          else
            args[arg] = new_val
          end
        end
      end
    end

    # create initial condition
    if model.getWeatherFile.city != ''
      runner.registerInitialCondition("The initial weather file is #{model.getWeatherFile.city} and the model has #{model.getDesignDays.size} design day objects")
    else
      runner.registerInitialCondition("No weather file is set. The model has #{model.getDesignDays.size} design day objects")
    end

    # use gsub if requested
    if args['epw_gsub'] != 'Do Nothing'
      # get the orig weather file from OSM
      file_name = model.getWeatherFile.url.get.split('/').last
      runner.registerInfo(file_name)

      if model.getWeatherFile.file.is_initialized
        orig_epw = model.getWeatherFile.url.get.split('/').last
        gsub_array = args['epw_gsub'].split(',')
        # updated line below so it doesn't matter what the user argument is, it always modifies what was in the seed OSM
        args['weather_file_name'] = orig_epw.gsub(gsub_array[0], gsub_array[1])
        runner.registerInfo("Changing target weather file from #{orig_epw} to #{args['weather_file_name']}.")
      end
    end

    # find weather file, checking both the location specified in the osw
    # and the path used by ComStock meta-measure
    comstock_weather_file = File.absolute_path(File.join(Dir.pwd, '../../../weather', args['weather_file_name']))
    osw_weather_file = runner.workflow.findFile(args['weather_file_name'])
    if File.file? comstock_weather_file
      weather_file = comstock_weather_file
    elsif osw_weather_file.is_initialized
      weather_file = osw_weather_file.get.to_s
    else
      runner.registerError("Did not find #{args['weather_file_name']} in paths described in OSW file or in default ComStock workflow location of #{comstock_weather_file}.")
      return false
    end

    # Parse the EPW manually because OpenStudio can't handle multiyear weather files (or DATA PERIODS with YEARS)
    epw_file = OpenStudio::Weather::Epw.load(weather_file)

    weather_file = model.getWeatherFile
    weather_file.setCity(epw_file.city)
    weather_file.setStateProvinceRegion(epw_file.state)
    weather_file.setCountry(epw_file.country)
    weather_file.setDataSource(epw_file.data_type)
    weather_file.setWMONumber(epw_file.wmo.to_s)
    weather_file.setLatitude(epw_file.lat)
    weather_file.setLongitude(epw_file.lon)
    weather_file.setTimeZone(epw_file.gmt)
    weather_file.setElevation(epw_file.elevation)
    weather_file.setString(10, epw_file.filename)

    weather_name = "#{epw_file.city}_#{epw_file.state}_#{epw_file.country}"
    weather_lat = epw_file.lat
    weather_lon = epw_file.lon
    weather_time = epw_file.gmt
    weather_elev = epw_file.elevation

    # Add or update site data
    site = model.getSite
    site.setName(weather_name)
    site.setLatitude(weather_lat)
    site.setLongitude(weather_lon)
    site.setTimeZone(weather_time)
    site.setElevation(weather_elev)

    runner.registerInfo("city is #{epw_file.city}. State is #{epw_file.state}")

    # actual year of start date
    if args['set_year'].to_i > 0
      model.getYearDescription.setCalendarYear(args['set_year'].to_i)
      runner.registerInfo("Changing Calendar Year to #{args['set_year']},")
    end

    # Add SiteWaterMainsTemperature -- via parsing of STAT file.
    stat_file = "#{File.join(File.dirname(epw_file.filename), File.basename(epw_file.filename, '.*'))}.stat"
    unless File.exist? stat_file
      runner.registerInfo 'Could not find STAT file by filename, looking in the directory'
      stat_files = Dir["#{File.dirname(epw_file.filename)}/*.stat"]
      if stat_files.size > 1
        runner.registerError('More than one stat file in the EPW directory')
        return false
      end
      if stat_files.empty?
        runner.registerError('Cound not find the stat file in the EPW directory')
        return false
      end

      runner.registerInfo "Using STAT file: #{stat_files.first}"
      stat_file = stat_files.first
    end
    unless stat_file
      runner.registerError 'Could not find stat file'
      return false
    end

    stat_model = EnergyPlus::StatFile.new(stat_file)
    water_temp = model.getSiteWaterMainsTemperature
    water_temp.setAnnualAverageOutdoorAirTemperature(stat_model.mean_dry_bulb)
    water_temp.setMaximumDifferenceInMonthlyAverageOutdoorAirTemperatures(stat_model.delta_dry_bulb)
    runner.registerInfo("mean dry bulb is #{stat_model.mean_dry_bulb}")

    # Remove all the Design Day objects that are in the file
    model.getObjectsByType('OS:SizingPeriod:DesignDay'.to_IddObjectType).each(&:remove)

    # find the ddy files
    ddy_file = "#{File.join(File.dirname(epw_file.filename), File.basename(epw_file.filename, '.*'))}.ddy"
    unless File.exist? ddy_file
      ddy_files = Dir["#{File.dirname(epw_file.filename)}/*.ddy"]
      if ddy_files.size > 1
        runner.registerError('More than one ddy file in the EPW directory')
        return false
      end
      if ddy_files.empty?
        runner.registerError('could not find the ddy file in the EPW directory')
        return false
      end

      ddy_file = ddy_files.first
    end

    unless ddy_file
      runner.registerError "Could not find DDY file for #{ddy_file}"
      return error
    end

    ddy_model = OpenStudio::EnergyPlus.loadAndTranslateIdf(ddy_file).get

    # Warn if no design days are present in the ddy file
    if ddy_model.getDesignDays.size.zero?
      runner.registerWarning('No design days were found in the ddy file.')
    end

    ddy_model.getDesignDays.sort.each do |d|
      # grab only the ones that matter
      ddy_list = [
        /Htg 99.6. Condns DB/, # Annual heating
        /Clg .4. Condns WB=>MDB/, # Annual cooling
        /Clg .4. Condns DB=>MWB/, # Annual humidity (for cooling towers and evap coolers)
        /January .4. Condns DB=>MCWB/, # Monthly cooling (to handle solar-gain-driven cooling)
        /February .4. Condns DB=>MCWB/,
        /March .4. Condns DB=>MCWB/,
        /April .4. Condns DB=>MCWB/,
        /May .4. Condns DB=>MCWB/,
        /June .4. Condns DB=>MCWB/,
        /July .4. Condns DB=>MCWB/,
        /August .4. Condns DB=>MCWB/,
        /September .4. Condns DB=>MCWB/,
        /October .4. Condns DB=>MCWB/,
        /November .4. Condns DB=>MCWB/,
        /December .4. Condns DB=>MCWB/
      ]
      ddy_list.each do |ddy_name_regex|
        if d.name.get.to_s.match?(ddy_name_regex)
          runner.registerInfo("Adding object #{d.name}")

          # add the object to the existing model
          model.addObject(d.clone)
          break
        end
      end
    end

    # Warn if no design days were added
    if model.getDesignDays.size.zero?
      runner.registerWarning('No design days were added to the model.')
    end

    # Set climate zone
    climateZones = model.getClimateZones
    if args['climate_zone'] == 'Lookup From Stat File'

      # get climate zone from stat file
      text = nil
      File.open(stat_file) do |f|
        text = f.read.force_encoding('iso-8859-1')
      end

      # Get Climate zone.
      # - Climate type "3B" (ASHRAE Standard 196-2006 Climate Zone)**
      # - Climate type "6A" (ASHRAE Standards 90.1-2004 and 90.2-2004 Climate Zone)**
      regex = /Climate type \"(.*?)\" \(ASHRAE Standards?(.*)\)\*\*/
      match_data = text.match(regex)
      if match_data.nil?
        runner.registerWarning("Can't find ASHRAE climate zone in stat file.")
      else
        args['climate_zone'] = match_data[1].to_s.strip
      end

    end

    # report time zone for use in results.csv
    runner.registerValue('reported_climate_zone', args['climate_zone'])

    # set climate zone
    climateZones.clear
    if args['climate_zone'].include?('CEC')
      climateZones.setClimateZone('CEC', args['climate_zone'].gsub('CEC T24-CEC', ''))
      runner.registerInfo("Setting CEC Climate Zone to #{climateZones.getClimateZones('CEC').first.value}")
    else
      climateZones.setClimateZone('ASHRAE', args['climate_zone'].gsub('ASHRAE 169-2013-', ''))
      runner.registerInfo("Setting ASHRAE Climate Zone to #{climateZones.getClimateZones('ASHRAE').first.value}")
    end

    # add final condition
    runner.registerFinalCondition("The final weather file is #{model.getWeatherFile.city} and the model has #{model.getDesignDays.size} design day objects.")

    true
  end
end

# This allows the measure to be use by the application
ChangeBuildingLocation.new.registerWithApplication
