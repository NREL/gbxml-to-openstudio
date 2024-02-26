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

    workspace.getObjectsByType('Output:SQLite'.to_IddObjectType)[0].setString(1, 'None') # Unit Conversion for Tabular Data
    workspace.getObjectsByType('Output:Table:SummaryReports'.to_IddObjectType)[0].setString(0, 'AllSummaryAndSizingPeriod') # Report 1 Name
    workspace.getObjectsByType('OutputControl:Table:Style'.to_IddObjectType)[0].setString(0, 'XMLandHTML') # Column Separator
    workspace.getObjectsByType('OutputControl:Table:Style'.to_IddObjectType)[0].setString(1, 'InchPound') if runner.unitsPreference == 'IP' # Unit Conversion

    return true
  end
end

# register the measure to be used by the application
AddXMLOutputControlStyle.new.registerWithApplication
