# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class ImportGbxml < OpenStudio::Measure::ModelMeasure

  # human readable name
  def name
    return "ImportGbxml"
  end

  # human readable description
  def description
    return "Import a gbXML file"
  end

  # human readable description of modeling approach
  def modeler_description
    return "Import a gbXML file"
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # the name of the space to add to the model
    gbxml_file_name = OpenStudio::Measure::OSArgument.makeStringArgument("gbxml_file_name", true)
    gbxml_file_name.setDisplayName("gbXML filename")
    gbxml_file_name.setDescription("Filename or full path to gbXML file.")
    args << gbxml_file_name

    # the boolean argument to determine whether to rename the building and thermal zones
    rename_objects = OpenStudio::Measure::OSArgument.makeBoolArgument("rename_objects", false)
    rename_objects.setDisplayName("Rename thermal zones and building?")
    rename_objects.setDefaultValue(true)
    args << rename_objects

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign the user inputs to variables
    gbxml_file_name = runner.getStringArgumentValue("gbxml_file_name", user_arguments)

    rename_objects = runner.getBoolArgumentValue("rename_objects", user_arguments)

    # check the space_name for reasonableness
    if gbxml_file_name.empty?
      runner.registerError("Empty gbXML filename was entered.")
      return false
    end
    
    # find the gbXML file
    path = runner.workflow.findFile(gbxml_file_name)
    if path.empty?
      runner.registerError("Could not find gbXML filename '#{gbxml_file_name}'.")
      return false
    end
    
    # translate gbXML to model
    translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
    new_model = translator.loadModel(path.get)
    if new_model.empty?
      runner.registerError("Could not translate gbXML filename '#{gbxml_file_name}' to OSM.")
      return false
    end
    new_model = new_model.get
    
    # temporarily remove space types from gbxml
    new_model.getSpaceTypes.each do |space_type|
      space_type.remove
    end

    # # add fake space type at the building level
    # space_type = OpenStudio::Model::SpaceType.new(new_model)
    # space_type.setStandardsBuildingType('Office')
    # space_type.setStandardsSpaceType('WholeBuilding - Md Office')
    #
    # building = new_model.getBuilding
    # building.setSpaceType(space_type)
    # building.setStandardsBuildingType('Office')

    # pull original weather file object over
    weatherFile = new_model.getOptionalWeatherFile
    if not weatherFile.empty?
      weatherFile.get.remove
    end
    originalWeatherFile = model.getOptionalWeatherFile
    if not originalWeatherFile.empty?
      originalWeatherFile.get.clone(new_model)
    end
    runner.registerInfo("Replacing alternate model's weather file object.")

    # pull original design days over
    new_model.getDesignDays.each { |designDay|
      designDay.remove
    }
    model.getDesignDays.each { |designDay|
      designDay.clone(new_model)
    }
    runner.registerInfo("Replacing alternate model's design day objects.")

    # pull over original water main temps
    new_model.getSiteWaterMainsTemperature.remove
    model.getSiteWaterMainsTemperature.clone(new_model)
    runner.registerInfo("Replacing alternate model's water main temperature object.")

    # pull over original climate zone
    new_model.getClimateZones.remove
    model.getClimateZones.clone(new_model)
    runner.registerInfo("Replacing alternate model's ASHRAE Climate Zone.")

    # swap underlying data in model with underlying data in new_model
    # model = new_model DOES NOT work
    # model.swap(new_model) IS NOT reliable
    
    # alternative swap
    # remove existing objects from model
    handles = OpenStudio::UUIDVector.new
    model.objects.each do |obj|
      handles << obj.handle
    end
    model.removeObjects(handles)
    # add new file to empty model
    model.addObjects( new_model.toIdfFile.objects )

    model.setCalendarYear(1997)

    # set building name to Display Name instead of gbXMLId and set thermal zone name to Display Name if all thermal zone names are unique.
    # otherwise, set the name equal to display_name (gbxml_id). Workaround for https://github.com/NREL/gbxml-to-openstudio/issues/108
    if rename_objects

      display_name = 'displayName'
      gbxml_id = 'gbXMLId'

      # set building name to Display Name feature
      model.getBuilding.setName(model.getBuilding.additionalProperties.getFeatureAsString(display_name).get)

      # check gbxml zone names for uniqueness here, then issue warnings
      thermal_zones = model.getThermalZones
      thermal_zones_names = []
      thermal_zones.each do |thermal_zone|
        thermal_zones_names << thermal_zone.additionalProperties.getFeatureAsString(display_name).get
      end

      if thermal_zones_names.count() == thermal_zones_names.uniq.count()
        gbxml_zone_names_uniq = true
      else
        gbxml_zone_names_uniq = false
      end

      if gbxml_zone_names_uniq
        runner.registerWarning("gbXML Zone names are unique, renaming with Name.")
      else
        runner.registerWarning("gbXML Zone names are not unique, renaming with Name and ID.")
      end

      # rename thermal zones
      thermal_zones.each do |thermal_zone|
        case gbxml_zone_names_uniq
        when true
          new_name = thermal_zone.additionalProperties.getFeatureAsString(display_name).get
        when false
          new_name = thermal_zone.additionalProperties.getFeatureAsString(display_name).get + " (" + thermal_zone.additionalProperties.getFeatureAsString(gbxml_id).get + ")"
        end
        thermal_zone.setName(new_name)
      end


    end
  return true

  end
  
end

# register the measure to be used by the application
ImportGbxml.new.registerWithApplication
