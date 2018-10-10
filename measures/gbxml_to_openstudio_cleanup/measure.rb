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

    # Remove the hardcoded airwall material on subsurfaces
    model.getSubSurfaces.each do |sub_surface|
      # @param sub_surface [OpenStudio::Model::SubSurface]
      if sub_surface.isAirWall
        sub_surface.resetConstruction
      end
    end

    return true
  end
end

# register the measure to be used by the application
GbxmlToOpenstudioCleanup.new.registerWithApplication
