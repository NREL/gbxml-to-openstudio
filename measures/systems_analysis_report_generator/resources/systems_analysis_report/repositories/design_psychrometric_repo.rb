module SystemsAnalysisReport
  module Repositories
    class DesignPsychrometricRepo
      attr_reader :coil_sizing_details, :mapper

      def initialize(coil_sizing_details, mapper=Mappers::DesignPsychrometricMapper.new)
        @coil_sizing_details = coil_sizing_details
        @mapper = mapper
      end

      def find(name)
        design_psychrometric = nil
        coil_sizing_detail = @coil_sizing_details.find_by_name(name)

        if coil_sizing_detail
          design_psychrometric = @mapper.(coil_sizing_detail)
          design_psychrometric.name = name
        end

        design_psychrometric
      end
    end
  end
end