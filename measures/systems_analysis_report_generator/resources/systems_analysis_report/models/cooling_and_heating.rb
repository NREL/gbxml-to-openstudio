module SystemsAnalysisReport
  module Models
    CoolingAndHeating = Struct.new(:name, :cooling, :heating) do
      include Models::Model
    end
  end
end