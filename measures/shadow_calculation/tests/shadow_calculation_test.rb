require 'fileutils'
require 'minitest/autorun'
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require_relative '../measure'

# constants
DEFAULT_SHADING_CALCULATION_METHOD = 'PolygonClipping'
DEFAULT_SHADING_CALCULATION_UPDATE_FREQUENCY_METHOD = 'Periodic'
DEFAULT_SHADING_CALCULATION_UPDATE_FREQUENCY = 20
DEFAULT_MAXIMUM_FIGURES_IN_SHADOW_OVERLAP_CALCULATION = 15000
DEFAULT_POLYGON_CLIPPING_ALGORITHM = 'SutherlandHodgman'
DEFAULT_PIXEL_COUNTING_RESOLUTION = 512
DEFAULT_SKY_DIFFUSE_MODELING_ALGORITHM = 'SimpleSkyDiffuseModeling'

class ShadowCalculationTest < Minitest::Test

  # return a model, measure, runner, and arguments_name_index_hash for use in tests
  def setup

    # make an empty model
    @model = OpenStudio::Model::Model.new

    # make a ShadowCalculation object
    shadow_calculation = @model.getShadowCalculation

    # set to defaults
    shadow_calculation.setShadingCalculationMethod(
      DEFAULT_SHADING_CALCULATION_METHOD)
    shadow_calculation.setShadingCalculationUpdateFrequencyMethod(
      DEFAULT_SHADING_CALCULATION_UPDATE_FREQUENCY_METHOD)
    shadow_calculation.setShadingCalculationUpdateFrequency(
      DEFAULT_SHADING_CALCULATION_UPDATE_FREQUENCY)
    shadow_calculation.setMaximumFiguresInShadowOverlapCalculations(
      DEFAULT_MAXIMUM_FIGURES_IN_SHADOW_OVERLAP_CALCULATION)
    shadow_calculation.setPolygonClippingAlgorithm(
      DEFAULT_POLYGON_CLIPPING_ALGORITHM)
    shadow_calculation.setPixelCountingResolution(
      DEFAULT_PIXEL_COUNTING_RESOLUTION)
    shadow_calculation.setSkyDiffuseModelingAlgorithm(
      DEFAULT_SKY_DIFFUSE_MODELING_ALGORITHM)

    # create an instance of the measure
    @measure = ShadowCalculation.new

    # make a hash of argument name to argument index to get argument from name rather than index
    @arguments_name_index_hash = {}
    @measure.arguments(@model).each_with_index do |argument, i|
      @arguments_name_index_hash[argument.name.to_sym] = i
    end

    # create runner with empty OSW
    @runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)

    return @model, @measure, @runner, @arguments_name_index_hash

  end

  # def teardown
  # end

  # test the arguments method
  def test_arguments

    # get arguments
    arguments = @measure.arguments(@model)

    # test size
    assert_equal(7, arguments.size)

  end

  # test the run method by asserting that it successfully changes the object's fields
  def test_run

    # expected model
    exp_model = @model.clone(true).to_Model
    exp_shadow_calculation = exp_model.getShadowCalculation

    # actual model
    act_model = @model.clone(true).to_Model
    arguments = @measure.arguments(act_model)
    arguments_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

    # setShadingCalculationMethod
    arg_val = 'PixelCounting'
    exp_shadow_calculation.setShadingCalculationMethod(arg_val)
    arg_idx = @arguments_name_index_hash[:shading_calculation_method]
    argument = arguments[arg_idx].clone
    argument.setValue(arg_val)
    arguments_map[:shading_calculation_method.to_s] = argument

    # setShadingCalculationUpdateFrequencyMethod
    arg_val = 'Timestep'
    exp_shadow_calculation.setShadingCalculationUpdateFrequencyMethod(arg_val)
    arg_idx = @arguments_name_index_hash[:shading_calculation_update_frequency_method]
    argument = arguments[arg_idx].clone
    argument.setValue(arg_val)
    arguments_map[:shading_calculation_update_frequency_method.to_s] = argument

    # setShadingCalculationUpdateFrequency
    arg_val = DEFAULT_SHADING_CALCULATION_UPDATE_FREQUENCY * 10
    exp_shadow_calculation.setShadingCalculationUpdateFrequency(arg_val)
    arg_idx = @arguments_name_index_hash[:shading_calculation_update_frequency]
    argument = arguments[arg_idx].clone
    argument.setValue(arg_val)
    arguments_map[:shading_calculation_update_frequency.to_s] = argument

    # setMaximumFiguresInShadowOverlapCalculations
    arg_val = DEFAULT_MAXIMUM_FIGURES_IN_SHADOW_OVERLAP_CALCULATION * 10
    exp_shadow_calculation.setMaximumFiguresInShadowOverlapCalculations(arg_val)
    arg_idx = @arguments_name_index_hash[:maximum_figures_in_shadow_overlap_calculations]
    argument = arguments[arg_idx].clone
    argument.setValue(arg_val)
    arguments_map[:maximum_figures_in_shadow_overlap_calculations.to_s] = argument

    # setPolygonClippingAlgorithm
    arg_val = 'ConvexWeilerAtherton'
    exp_shadow_calculation.setPolygonClippingAlgorithm(arg_val)
    arg_idx = @arguments_name_index_hash[:polygon_clipping_algorithm]
    argument = arguments[arg_idx].clone
    argument.setValue(arg_val)
    arguments_map[:polygon_clipping_algorithm.to_s] = argument

    # setPixelCountingResolution
    arg_val = DEFAULT_PIXEL_COUNTING_RESOLUTION * 10
    exp_shadow_calculation.setPixelCountingResolution(arg_val)
    arg_idx = @arguments_name_index_hash[:pixel_counting_resolution]
    argument = arguments[arg_idx].clone
    argument.setValue(arg_val)
    arguments_map[:pixel_counting_resolution.to_s] = argument

    # setSkyDiffuseModelingAlgorithm
    arg_val = 'DetailedSkyDiffuseModeling'
    exp_shadow_calculation.setSkyDiffuseModelingAlgorithm(arg_val)
    arg_idx = @arguments_name_index_hash[:sky_diffuse_modeling_algorithm]
    argument = arguments[arg_idx].clone
    argument.setValue(arg_val)
    arguments_map[:sky_diffuse_modeling_algorithm.to_s] = argument

    # run measure
    @measure.run(act_model, @runner, arguments_map)

    # tests
    assert_equal(
      exp_model.getShadowCalculation.shadingCalculationMethod,
      act_model.getShadowCalculation.shadingCalculationMethod)
    assert_equal(
      exp_model.getShadowCalculation.shadingCalculationUpdateFrequencyMethod,
      act_model.getShadowCalculation.shadingCalculationUpdateFrequencyMethod)
    assert_equal(
      exp_model.getShadowCalculation.shadingCalculationUpdateFrequency,
      act_model.getShadowCalculation.shadingCalculationUpdateFrequency)
    assert_equal(
      exp_model.getShadowCalculation.maximumFiguresInShadowOverlapCalculations,
      act_model.getShadowCalculation.maximumFiguresInShadowOverlapCalculations)
    assert_equal(
      exp_model.getShadowCalculation.polygonClippingAlgorithm,
      act_model.getShadowCalculation.polygonClippingAlgorithm)
    assert_equal(
      exp_model.getShadowCalculation.pixelCountingResolution,
      act_model.getShadowCalculation.pixelCountingResolution)
    assert_equal(
      exp_model.getShadowCalculation.skyDiffuseModelingAlgorithm,
      act_model.getShadowCalculation.skyDiffuseModelingAlgorithm)

  end

end
