# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class ShadowCalculation < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Shadow Calculation'
  end

  # human readable description
  def description
    return "This measure sets the fields of the ShadowCalculation object, which is used to control some details of EnergyPlus’s solar, shadowing, and daylighting models."
  end

  # human readable description of modeling approach
  def modeler_description
    return "The ShadowCalculation class does not have a public constructor because it is a unique ModelObject."
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    shading_calculation_methods = OpenStudio::StringVector.new
    shading_calculation_methods << 'PolygonClipping'
    shading_calculation_methods << 'PixelCounting'
    # # TODO
    # shading_calculation_methods << 'Scheduled'
    # shading_calculation_methods << 'Imported'
    shading_calculation_method = OpenStudio::Measure::OSArgument.makeChoiceArgument('shading_calculation_method', shading_calculation_methods, true)
    shading_calculation_method.setDisplayName('Shading Calculation Method')
    shading_calculation_method.setDefaultValue('PolygonClipping')
    args << shading_calculation_method

    shading_calculation_update_frequency_methods = OpenStudio::StringVector.new
    shading_calculation_update_frequency_methods << 'Periodic'
    shading_calculation_update_frequency_methods << 'Timestep'
    shading_calculation_update_frequency_method = OpenStudio::Measure::OSArgument.makeChoiceArgument('shading_calculation_update_frequency_method', shading_calculation_update_frequency_methods, false)
    shading_calculation_update_frequency_method.setDisplayName('Shading Calculation Update Frequency Method')
    # shading_calculation_update_frequency_method.setDefaultValue('Periodic')
    args << shading_calculation_update_frequency_method

    shading_calculation_update_frequency = OpenStudio::Measure::OSArgument::makeIntegerArgument('shading_calculation_update_frequency', false)
    shading_calculation_update_frequency.setDisplayName('Shading Calculation Update Frequency (days)')
    shading_calculation_update_frequency.setDescription('Shading Calculation Update Frequency Method = Periodic')
    shading_calculation_update_frequency.setDefaultValue(20)
    args << shading_calculation_update_frequency

    maximum_figures_in_shadow_overlap_calculations = OpenStudio::Measure::OSArgument::makeIntegerArgument('maximum_figures_in_shadow_overlap_calculations', false)
    maximum_figures_in_shadow_overlap_calculations.setDisplayName('Maximum Figures in Shadow Overlap Calculations')
    maximum_figures_in_shadow_overlap_calculations.setDescription('Shading Calculation Method = PolygonClipping')
    maximum_figures_in_shadow_overlap_calculations.setDefaultValue(15000)
    args << maximum_figures_in_shadow_overlap_calculations

    polygon_clipping_algorithms = OpenStudio::StringVector.new
    polygon_clipping_algorithms << 'SutherlandHodgman'
    polygon_clipping_algorithms << 'ConvexWeilerAtherton'
    polygon_clipping_algorithms << 'SlaterBarskyandSutherlandHodgman'
    polygon_clipping_algorithm = OpenStudio::Measure::OSArgument::makeChoiceArgument('polygon_clipping_algorithm', polygon_clipping_algorithms, false)
    polygon_clipping_algorithm.setDisplayName('Polygon Clipping Algorithm')
    polygon_clipping_algorithm.setDescription('Shading Calculation Method = PolygonClipping')
    # polygon_clipping_algorithm.setDefaultValue('SutherlandHodgman')
    args << polygon_clipping_algorithm

    pixel_counting_resolution = OpenStudio::Measure::OSArgument::makeIntegerArgument('pixel_counting_resolution', false)
    pixel_counting_resolution.setDisplayName('Pixel Counting Resolution')
    pixel_counting_resolution.setDescription('Shading Calculation Method = PixelCounting')
    pixel_counting_resolution.setDefaultValue(512)
    args << pixel_counting_resolution

    # This field applies to the shading calculation update frequency method called “Periodic.” When the method called “Timestep” is used the diffuse sky modeling always uses DetailedSkyDiffuseModeling.
    sky_diffuse_modeling_algorithms = OpenStudio::StringVector.new
    sky_diffuse_modeling_algorithms << 'SimpleSkyDiffuseModeling'
    sky_diffuse_modeling_algorithms << 'DetailedSkyDiffuseModeling'
    sky_diffuse_modeling_algorithm = OpenStudio::Measure::OSArgument::makeChoiceArgument('sky_diffuse_modeling_algorithm', sky_diffuse_modeling_algorithms, false)
    sky_diffuse_modeling_algorithm.setDisplayName('Sky Diffuse Modeling Algorithm')
    # sky_diffuse_modeling_algorithm.setDefaultValue('SimpleSkyDiffuseModeling')
    args << sky_diffuse_modeling_algorithm

    # # TODO requires Shading Calculation Method = Imported
    # output_external_shading_calculation_results = OpenStudio::Measure::OSArgument::makeBoolArgument('output_external_shading_calculation_results', true)
    # output_external_shading_calculation_results.setDisplayName('Output External Shading Calculation Results')
    # output_external_shading_calculation_results.setDefaultValue(false)
    # args << output_external_shading_calculation_results

    # # TODO requires Shading Zone Group, a vector of ThermalZones
    # disable_self_shading_within_shading_zone_groups = OpenStudio::Measure::OSArgument::makeBoolArgument('disable_self_shading_within_shading_zone_groups', true)
    # disable_self_shading_within_shading_zone_groups.setDisplayName('Disable Self-Shading Within Shading Zone Groups')
    # disable_self_shading_within_shading_zone_groups.setDefaultValue(false)
    # args << disable_self_shading_within_shading_zone_groups

    # # TODO requires Shading Zone Group, a vector of ThermalZones
    # disable_self_shading_from_shading_zone_groupsto_other_zones = OpenStudio::Measure::OSArgument::makeBoolArgument('disable_self_shading_from_shading_zone_groupsto_other_zones', true)
    # disable_self_shading_from_shading_zone_groupsto_other_zones.setDisplayName('Disable Self-Shading From Shading Zone Groups to Other Zones')
    # disable_self_shading_from_shading_zone_groupsto_other_zones.setDefaultValue(false)
    # args << disable_self_shading_from_shading_zone_groupsto_other_zones

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
    shading_calculation_method = runner.getStringArgumentValue('shading_calculation_method', user_arguments)
    if runner.getOptionalStringArgumentValue('shading_calculation_update_frequency_method', user_arguments).is_initialized
      shading_calculation_update_frequency_method = runner.getStringArgumentValue('shading_calculation_update_frequency_method', user_arguments)
    else
      shading_calculation_update_frequency_method = false
    end
    if runner.getOptionalIntegerArgumentValue('shading_calculation_update_frequency', user_arguments).is_initialized
      shading_calculation_update_frequency = runner.getIntegerArgumentValue('shading_calculation_update_frequency', user_arguments)
    else
      shading_calculation_update_frequency = false
    end
    if runner.getOptionalIntegerArgumentValue('maximum_figures_in_shadow_overlap_calculations', user_arguments).is_initialized
      maximum_figures_in_shadow_overlap_calculations = runner.getIntegerArgumentValue('maximum_figures_in_shadow_overlap_calculations', user_arguments)
    else
      maximum_figures_in_shadow_overlap_calculations = false
    end
    if runner.getOptionalStringArgumentValue('polygon_clipping_algorithm', user_arguments).is_initialized
      polygon_clipping_algorithm = runner.getStringArgumentValue('polygon_clipping_algorithm', user_arguments)
    else
      polygon_clipping_algorithm = false
    end
    if runner.getOptionalIntegerArgumentValue('pixel_counting_resolution', user_arguments).is_initialized
      pixel_counting_resolution = runner.getIntegerArgumentValue('pixel_counting_resolution', user_arguments)
    else
      pixel_counting_resolution = false
    end
    if runner.getOptionalStringArgumentValue('sky_diffuse_modeling_algorithm', user_arguments).is_initialized
      sky_diffuse_modeling_algorithm = runner.getStringArgumentValue('sky_diffuse_modeling_algorithm', user_arguments)
    else
      sky_diffuse_modeling_algorithm = false
    end
    # output_external_shading_calculation_results = runner.getBoolArgumentValue('output_external_shading_calculation_results', user_arguments)
    # disable_self_shading_within_shading_zone_groups = runner.getBoolArgumentValue('disable_self_shading_within_shading_zone_groups', user_arguments)
    # disable_self_shading_from_shading_zone_groups_to_other_zones = runner.getBoolArgumentValue('disable_self_shading_from_shading_zone_groups_to_other_zones', user_arguments)

    # get object or create one if it does not yet exist
    shadow_calculation = model.getShadowCalculation

    # report initial condition
    runner.registerInitialCondition("#{shadow_calculation}")

    # set object
    shadow_calculation.setShadingCalculationMethod(shading_calculation_method)
    shadow_calculation.setMaximumFiguresInShadowOverlapCalculations(
      maximum_figures_in_shadow_overlap_calculations
    ) if maximum_figures_in_shadow_overlap_calculations
    shadow_calculation.setPolygonClippingAlgorithm(
      polygon_clipping_algorithm
    ) if polygon_clipping_algorithm
    shadow_calculation.setPixelCountingResolution(
      pixel_counting_resolution
    ) if pixel_counting_resolution
    shadow_calculation.setShadingCalculationUpdateFrequencyMethod(
      shading_calculation_update_frequency_method
    ) if shading_calculation_update_frequency_method
    shadow_calculation.setShadingCalculationUpdateFrequency(
      shading_calculation_update_frequency
    ) if shading_calculation_update_frequency
    shadow_calculation.setSkyDiffuseModelingAlgorithm(
      sky_diffuse_modeling_algorithm
    ) if sky_diffuse_modeling_algorithm

    # report final condition
    runner.registerFinalCondition("#{shadow_calculation}")

    return true
  end
end

# register the measure to be used by the application
ShadowCalculation.new.registerWithApplication
