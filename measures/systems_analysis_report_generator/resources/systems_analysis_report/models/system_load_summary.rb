module SystemsAnalysisReport
  module Models
    SystemLoadSummary = Struct.new(:name, :peak_condition, :engineering_check, :estimated_peak_load_component_table,
                                   :temperature, :airflow) do

      include Models::Model
    end
  end
end