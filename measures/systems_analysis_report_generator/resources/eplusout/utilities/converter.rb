module EPlusOut
  module Utilities
    class Converter
      attr_reader :base_converter

      UNIT_ADAPTER = {
          "ft2" => "ft^2",
          "Btu/h-ft2" => "Btu/h*ft^2",
          "ft3/min" => "ft^3/min",
          "ft3/min-ft2" => "ft^3/min*ft^2",
          "ft3-h/min-Btu" => "ft^3*h/min*Btu",
          "ft2-h/Btu" => "ft^2*h/Btu",
          "Btu/h-F" => "Btu/h*R",
          "Btu/lbm-R" => "Btu/lb*R",
          "lb/ft3" => "lb/ft^3",
          "deltaF" => "R",
      }

      def initialize(base_converter=OpenStudio)
        @base_converter = base_converter
      end

      def convert(original, from_unit, to_unit)
        adapted_from_unit = (UNIT_ADAPTER.include? from_unit) ? UNIT_ADAPTER[from_unit] : from_unit

        begin
          base_converter.convert(original, adapted_from_unit, to_unit).get
        rescue
          original
        end
      end
    end
  end
end
