module SystemsAnalysisReport
  module Services
    class DesignPsychrometricService
      attr_reader :repository, :name_getter

      def initialize(repository, name_getter=Strategies::CoolingCoilNameGetter)
        @repository = repository
        @name_getter = name_getter
      end

      def call(model)
        @name_getter.(model).inject([]) { |results, names| results << @repository.find(*names) }
      end
    end
  end
end