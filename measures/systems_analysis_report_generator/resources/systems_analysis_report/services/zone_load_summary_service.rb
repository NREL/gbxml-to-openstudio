module SystemsAnalysisReport
  module Services
    class ZoneLoadSummaryService
      attr_reader :repository, :name_getter

      def initialize(repository, name_getter=Strategies::ZoneNameGetter)
        @repository = repository
        @name_getter = name_getter
      end

      def call(model)
        @name_getter.(model).inject([]) { |results, name| results << @repository.find(name) }
      end
    end
  end
end