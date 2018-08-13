# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

require 'rexml/document'
require 'rexml/xpath'

# start the measure
class AdvancedImportGbxml < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Advanced Import Gbxml'
  end

  # human readable description
  def description
    return 'This measure will bring in additional gbXML data beyond what comes in with the basic OpenStudio gbXML import.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'This measure expects GbXMLReverseTranslator to already have been run on the model. This measure parses the XML and translates additional gbXML objects to OSM.'
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
    path = path.get

    # report initial condition of model
    runner.registerInitialCondition("The building started with #{model.objects.size} model objects.")

    # read in and parse xml using using rexml
    xml_string = File.read(path.to_s)
    gbxml_doc = REXML::Document.new(xml_string)

    # test looking for building area
    gbxml_area = gbxml_doc.elements["/gbXML/Campus/Building/Area"]
    runner.registerInfo("the gbXML has an area of #{gbxml_area.text.to_f}.")

=begin
    puts "**Looping through surfaces"
    gbxml_doc.elements.each('gbXML/Campus/Surface') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "Surface #{element.attributes['id']} does not have a name"
      end
    end
=end

    puts "**Looping through zones"
    gbxml_doc.elements.each('gbXML/Zone') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "Zone #{element.attributes['id']} does not have a name"
      end
    end

    puts "**Looping through spaces"
    gbxml_doc.elements.each('gbXML/Campus/Building/Space') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "Space #{element.attributes['id']} does not have a name"
      end
    end

    puts "**Looping through ZoneHVACEquipment"
    gbxml_doc.elements.each('gbXML/ZoneHVACEquipment') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "ZoneHVACEquipment #{element.attributes['id']} does not have a name"
      end
    end

    puts "**Looping through AirSystem"
    gbxml_doc.elements.each('gbXML/AirSystem') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "ZoneHVACEquipment #{element.attributes['id']} does not have a name"
      end
    end

    puts "**Looping through HydronicLoop"
    gbxml_doc.elements.each('gbXML/HydronicLoop') do |element|
      name = element.elements['Name']
      if ! name.nil?
        puts name.text
      else
        puts "ZoneHVACEquipment #{element.attributes['id']} does not have a name"
      end
    end

    # report final condition of model
    runner.registerFinalCondition("The building finished with #{model.objects.size} model objectxs.")

    return true
  end
end

# register the measure to be used by the application
AdvancedImportGbxml.new.registerWithApplication
