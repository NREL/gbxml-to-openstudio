module SystemsAnalysisReport
  module Models
    ZoneLoadSummary = Struct.new(:peak_condition, :engineering_check, :estimated_peak_load_component_table) do
      include Models::Model

    end
  end
end