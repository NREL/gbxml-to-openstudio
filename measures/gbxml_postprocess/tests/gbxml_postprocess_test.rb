# insert your copyright here

require 'fileutils'
require 'minitest/autorun'
require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require_relative '../measure.rb'

class GbxmlPostprocessTest < Minitest::Test

  def setup

    # make new model
    @model = OpenStudio::Model::Model.new

    # add objects
    @model.getOutputSQLite
    @model.getOutputTableSummaryReports
    @model.getOutputControlTableStyle

    # create an instance of the measure
    @measure = GbxmlPostprocess.new

    # create runner with empty OSW
    @runner = OpenStudio::Measure::OSRunner.new(OpenStudio::WorkflowJSON.new)

    return @model, @measure, @runner

  end

  # def teardown
  # end

  def test_run

    # run measure
    arguments_map = OpenStudio::Measure.convertOSArgumentVectorToMap(@measure.arguments(@model))
    @measure.run(@model, @runner, arguments_map)

    # tests
    # TODO test subsurface airwall construction
    assert_equal(@model.getOutputSQLite.unitConversionforTabularData, 'None')
    assert_equal(@model.getOutputTableSummaryReports.getString(1).to_s, 'AllSummaryAndSizingPeriod')
    assert_equal(@model.getOutputControlTableStyle.columnSeparator, 'XMLandHTML')
    assert_equal(@model.getOutputControlTableStyle.unitConversion, 'InchPound')

  end

end
