# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

require 'rexml/document'
require 'rexml/xpath'
# require_relative 'resources/model_manager/rb'
require_relative 'gbxml_hvac_import'
# require all .rb files in resources folder
# Dir[File.dirname(__FILE__) + '/resources/*/*.rb'].each { |file| require file }

# start the measure
class GBXMLHVACImport < OpenStudio::Measure::ModelMeasure
  require 'openstudio-standards'

  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'GBXML HVAC Import'
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
    # puts '*** Starting the HVAC Measure ***'

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

    puts '*** Starting the HVAC Measure ***'
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
    # xml_string = File.read(path.to_s)
    # gbxml_doc = REXML::Document.new(xml_string)
    model_manager = ModelManager.new(model, path)
    model_manager.load_gbxml
    model_manager.resolve_read_relationships
    model_manager.build

    # test looking for building area
    # gbxml_area = gbxml_doc.elements["/gbXML/Campus/Building/Area"]
    # runner.registerInfo("the gbXML has an area of #{gbxml_area.text.to_f}.")

    # std = Standard.build('90.1-2013')
    #
    # gbxml_doc.elements.each("gbXML/HydronicLoop[@loopType='CondenserWater']") do |element|
    #   CondenserLoop.create_cw_loop_from_xml(model, std, element)
    # end
    #
    # gbxml_doc.elements.each("gbXML/HydronicLoop[@loopType='PrimaryChilledWater']") do |element|
    #   ChilledWaterLoop.create_chw_loop_from_xml(model, std, element)
    # end
    #
    # gbxml_doc.elements.each("gbXML/HydronicLoop[@loopType='HotWater']") do |element|
    #   HotWaterLoop.create_hw_loop_from_xml(model, std, element)
    # end
    #
    # gbxml_doc.elements.each("gbXML/AirSystem") do |element|
    #   AirSystem.create_air_system_from_xml(model, std, element)
    # end
    #
    # gbxml_doc.elements.each("gbXML/ZoneHVACEquipment") do |element|
    #   ZoneHVACEquipment.equipment_type_mapping(model, std, element)
    # end
    #
    # gbxml_doc.elements.each("gbXML/Zone") do |element|
    #   Zone.map_to_zone_hvac_equipment(model, element)
    # end

    Helpers.clean_up_model(model)

    return true
  end
end

# register the measure to be used by the application
GBXMLHVACImport.new.registerWithApplication
