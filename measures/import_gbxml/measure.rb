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

    return true

  end
  
end

# register the measure to be used by the application
ImportGbxml.new.registerWithApplication
