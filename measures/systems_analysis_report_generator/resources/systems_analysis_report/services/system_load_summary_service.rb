module SystemsAnalysisReport
  module Services
    class SystemLoadSummaryService
      attr_reader :repository, :name_getter

      def initialize(repository, name_getter=Strategies::SystemNameGetter)
        @repository = repository
        @name_getter = name_getter
      end

      def call(model)
        @name_getter.(model).inject([]) { |results, names| results << @repository.find(*names) }
      end
    end
  end
end