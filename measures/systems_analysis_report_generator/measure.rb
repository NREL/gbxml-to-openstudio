require_relative 'resources/systems_analysis_report'

class SystemsAnalysisReportGenerator < OpenStudio::Measure::ReportingMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Systems Analysis Report Generator'
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
  def arguments
    args = OpenStudio::Measure::OSArgumentVector.new

    # this measure does not require any user arguments, return an empty list

    return args
  end
  
  # define the outputs that the measure will create
  def outputs
    outs = OpenStudio::Measure::OSOutputVector.new

    # this measure does not produce machine readable outputs with registerValue, return an empty list

    return outs
  end
  
  # return a vector of IdfObject's to request EnergyPlus objects needed by the run method
  # Warning: Do not change the name of this method to be snake_case. The method must be lowerCamelCase.
  def energyPlusOutputRequests(runner, user_arguments)
    super(runner, user_arguments)

    # return result
  end

  # define what happens when the measure is run
  def run(runner, user_arguments)
    super(runner, user_arguments)

    model, sql_file = SystemsAnalysisReportGenerator.get_model_and_sql_file(runner)
    container = SystemsAnalysisReport.container(model, sql_file)
    data = container.json_generator.generate.to_json
    input_dir = "#{File.dirname(__FILE__)}/resources/build"
    SystemsAnalysisReport::Strategies::HtmlInjector.(input_dir, data)

    sql_file.close

    return true
  end

  def self.get_model_and_sql_file(runner)
    model = runner.lastOpenStudioModel
    sql_file = runner.lastEnergyPlusSqlFile

    if model.empty?
      runner.registerError('Cannot find last model.')
    end

    if sql_file.empty?
      runner.registerError('Cannot find last sql file.')
    end

    return model.get, sql_file.get
  end
end

# register the measure to be used by the application
SystemsAnalysisReportGenerator.new.registerWithApplication
