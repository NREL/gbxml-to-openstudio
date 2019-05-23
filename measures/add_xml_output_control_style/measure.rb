# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/
require 'openstudio'
# start the measure
class AddXMLOutputControlStyle < OpenStudio::Measure::EnergyPlusMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Add XML Output Control Style'
  end

  # human readable description
  def description
    return 'Add OutputControl:Table:Style to output an XML output'
  end

  # human readable description of modeling approach
  def modeler_description
    return ''
  end

  # define the arguments that the user will input
  def arguments(workspace)
    args = OpenStudio::Measure::OSArgumentVector.new

    gbxml_file_name = OpenStudio::Measure::OSArgument.makeStringArgument("gbxml_file_name", true)
    gbxml_file_name.setDisplayName("gbXML filename")
    gbxml_file_name.setDescription("Filename or full path to gbXML file.")
    args << gbxml_file_name

    return args
  end

  # define what happens when the measure is run
  #     # @type [OpenStudio::Workspace] workspace
  def run(workspace, runner, user_arguments)
    super(workspace, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(workspace), user_arguments)
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
    xml_string = File.read(path.to_s)
    gbxml_doc = REXML::Document.new(xml_string)

    use_si = gbxml_doc.elements['gbXML'].attributes['useSIUnitsForResults'] == "true" ? true : false

    workspace.getObjectsByType('OutputControl:Table:Style'.to_IddObjectType)[0].setString(0, 'All')
    workspace.getObjectsByType('OutputControl:Table:Style'.to_IddObjectType)[0].setString(1, 'InchPound') unless use_si
    workspace.getObjectsByType('Output:Table:SummaryReports'.to_IddObjectType)[0].setString(0, 'AllSummaryAndSizingPeriod')

    return true
  end
end

# register the measure to be used by the application
AddXMLOutputControlStyle.new.registerWithApplication
