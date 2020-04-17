module SystemsAnalysisReport
  module Services
    class ZoneLoadSummaryService
      attr_reader :repository, :name_getter

      def initialize(repository, name_getter=Strategies::ZoneNameGetter)
        @repository = repository
        @name_getter = name_getter
      end

      def call(model)
        results = []

        @name_getter.(model).each do |name|
          result = @repository.find(name)
          results << result if result
        end

        results
      end
    end
  end
end