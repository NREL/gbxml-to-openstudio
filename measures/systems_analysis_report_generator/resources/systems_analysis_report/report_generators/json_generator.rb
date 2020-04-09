module SystemsAnalysisReport
  module ReportGenerators
    class JSONGenerator
      attr_reader :model, :zone_load_summarys_service, :system_load_summarys_service, :design_psychrometrics_service

      def initialize(model, zone_load_summarys_service, system_load_summarys_service, design_psychrometrics_service)
        @model = model
        @zone_load_summarys_service = zone_load_summarys_service
        @system_load_summarys_service = system_load_summarys_service
        @design_psychrometrics_service = design_psychrometrics_service
      end

      def generate
        report = SystemsAnalysisReport::Models::Report.new

        report.zone_load_summarys = @zone_load_summarys_service.(@model)
        report.system_load_summarys = @system_load_summarys_service.(@model)
        report.design_psychrometrics = @design_psychrometrics_service.(@model)

        report
      end
    end
  end
end