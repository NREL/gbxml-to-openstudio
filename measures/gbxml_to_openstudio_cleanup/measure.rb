# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class GbxmlToOpenstudioCleanup < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'gbxml_to_openstudio_cleanup'
  end

  # human readable description
  def description
    return ''
  end

  # human readable description of modeling approach
  def modeler_description
    return ''
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # Set airwall to single pane simple glazing
    window_simple = OpenStudio::Model::SimpleGlazing.new(model, 3.7642, 0.78)
    window_simple.setVisibleTransmittance(0.9)
    window_construction = OpenStudio::Model::Construction.new(model)
    window_construction.insertLayer(0, window_simple)

    model.getSubSurfaces.each do |sub_surface|
      if sub_surface.isAirWall
        sub_surface.setConstruction(window_construction)
      end
    end

    return true
  end
end

# register the measure to be used by the application
GbxmlToOpenstudioCleanup.new.registerWithApplication
