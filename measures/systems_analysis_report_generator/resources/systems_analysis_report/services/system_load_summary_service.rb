module SystemsAnalysisReport
  module Services
    class SystemLoadSummaryService
      attr_reader :repository, :name_getter

      def initialize(repository, name_getter=Strategies::SystemNameGetter)
        @repository = repository
        @name_getter = name_getter
      end

      def call(model)
        results = []

        @name_getter.(model).each do |names|
          result = @repository.find(*names)
          results << result if result
        end

        results
      end
    end
  end
end