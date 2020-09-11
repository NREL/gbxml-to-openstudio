module SystemsAnalysisReport
  class Config
    attr_reader :language, :units

    def initialize(opts={})
      file_path = (opts.key? :file_path) ? opts[:file_path] : "#{File.dirname(__FILE__)}/resources/build/reportConfig.json"

      file = File.open(file_path)
      data = JSON.load(file)
      @language = data['language']
      @units = Units.new(data['units'])

      if opts.key? :units
        @units = opts[:units]
      end
    end

    def to_json
      {
          language: @language,
          units: @units.to_json
      }.to_h.to_json
    end
  end

  class Units
    attr_reader :data

    CONFIG_UNITS_TO_HTML = {
        watts: "W",
        kilowatts: "kW",
        britishThermalUnitsPerSecond: "btu/s",
        britishThermalUnitsPerHour: "btu/hr",
        fahrenheit: "F",
        celsius: "C",
        kelvin: "K",
        rankine: "R",
        fahrenheitInterval: "F_diff",
        celsiusInterval: "C_diff",
        kelvinInterval: "K_diff",
        rankineInterval: "R_diff",
        kilograms: "kg",
        tonnes: "ton",
        usTonnesMass: "us_ton",
        poundsMass: "lb",
        cubicFeetPerHour: "ft3/hr",
        cubicFeetPerMinute: "ft3/min",
        cubicMetersPerHour: "m3/hr",
        cubicMetersPerSecond: "m3/s",
        litersPerHour: "l/hr",
        litersPerMinute: "l/min",
        litersPerSecond: "l/s",
        usGallonsPerHour: "us_gal/hr",
        usGallonsPerMinute: "us_gal/min",
        joulesPerGramDegreeCelsius: "J/g/C",
        britishThermalUnitsPerPoundDegreeFahrenheit: "btu/lb/F",
        joulesPerKilogramDegreeCelsius: "J/kg/C",
        kilogramsPerCubicMeter: "kg/m3",
        poundsMassPerCubicFoot: "lb/ft3",
        poundsMassPerCubicInch: "lb/in3",
        fixed: "unitless",
        percentage: "percent",
        wattsPerSquareFoot: "W/ft2",
        wattsPerSquareMeter: "W/m2",
        britishThermalUnitsPerHourSquareFoot: "btu/hr/ft2",
        cubicFeetPerMinuteSquareFoot: "ft3/min/ft2",
        litersPerSecondSquareMeter: "l/s/m2",
        cubicFeetPerMinuteTonOfRefrigeration: "ft3/min/ton_r",
        litersPerSecondKilowatt: "l/s/kW",
        squareFeet: "ft2",
        squareInches: "in2",
        squareMeters: "m2",
        squareCentimeters: "cm2",
        squareMillimeters: "mm2",
        acres: "ac",
        hectares: "ha",
        squareMetersPerKilowatt: "m2/kW",
        squareFeetPer1000BritishThermalUnitsPerHour: "ft2/kbtu/hr"
    }

    def initialize(data)
      define_methods(data)
    end

    def define_methods(data)
      data.each do |unit|
        Units.class_eval <<-EOS
          def #{unit['type'].downcase}
            '#{unit['forge_schema_unit'].split(':')[1].split('-')[0]}'
          end
        EOS
      end
    end

    def to_json
      {
          "heat_transfer_rate":"#{CONFIG_UNITS_TO_HTML[hvac_heating_load.to_sym]}",
          "temperature":"#{CONFIG_UNITS_TO_HTML[hvac_temperature.to_sym]}",
          "temperature_difference":"#{CONFIG_UNITS_TO_HTML[hvac_temperaturedifference.to_sym]}",
          "humidity_ratio":"#{CONFIG_UNITS_TO_HTML[mass.to_sym]}/#{CONFIG_UNITS_TO_HTML[mass.to_sym]}",
          "flow_rate":"#{CONFIG_UNITS_TO_HTML[hvac_airflow.to_sym]}",
          "specific_heat":"#{CONFIG_UNITS_TO_HTML[hvac_specificheat.to_sym]}",
          "density":"#{CONFIG_UNITS_TO_HTML[hvac_density.to_sym]}",
          "percent":"#{CONFIG_UNITS_TO_HTML[hvac_factor.to_sym]}",
          "outdoor_air_percentage":"#{CONFIG_UNITS_TO_HTML[hvac_factor.to_sym]}",
          "heat_transfer_rate_per_area":"#{CONFIG_UNITS_TO_HTML[hvac_heating_load_divided_by_area.to_sym]}",
          "area_per_heat_transfer_rate":"#{CONFIG_UNITS_TO_HTML[hvac_area_divided_by_heating_load.to_sym]}",
          "flow_rate_per_area":"#{CONFIG_UNITS_TO_HTML[hvac_airflow_density.to_sym]}",
          "flow_rate_per_heat_transfer_rate":"#{CONFIG_UNITS_TO_HTML[hvac_airflow_divided_by_cooling_load.to_sym]}",
          "people":"unitless",
          "area":"#{CONFIG_UNITS_TO_HTML[area.to_sym]}",
          "enthalpy": "kJ/kg",
          "specific_volume": "m3/kg",
          "pressure": "N/m2"
      }.to_h
    end
  end
end
