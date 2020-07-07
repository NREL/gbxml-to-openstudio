module SystemsAnalysisReport
  module Configuration
    class JSONWriter
      CONFIG_UNITS_TO_HTML = {
      "watts": "W",
      "kilowatts": "kW",
      "britishThermalUnitsPerSecond": "btu/s",
      "britishThermalUnitsPerHour": "btu/hr",
      "fahrenheit": "F",
      "celsius": "C",
      "kelvin": "K",
      "rankine": "R",
      "fahrenheitInterval": "F",
      "celsiusInterval": "C",
      "kelvinInterval": "K",
      "rankineInterval": "R",
      "kilograms": "kg",
      "tonnes": "ton",
      "usTonnesMass": "us_ton",
      "poundsMass": "lb",
      "cubicFeetPerHour": "ft3/hr",
      "cubicFeetPerMinute": "ft3/min",
      "cubicMetersPerHour": "m3/hr",
      "cubicMetersPerSecond": "m3/s",
      "litersPerHour": "l/hr",
      "litersPerMinute": "l/min",
      "litersPerSecond": "l/s",
      "usGallonsPerHour": "us_gal/hr",
      "usGallonsPerMinute": "us_gal/min",
      "joulesPerGramDegreeCelsius": "J/g/C",
      "britishThermalUnitsPerPoundDegreeFahrenheit": "btu/lb/F",
      "joulesPerKilogramDegreeCelsius": "J/kg/C",
      "kilogramsPerCubicMeter": "kg/m3",
      "poundsMassPerCubicFoot": "lb/ft3",
      "poundsMassPerCubicInch": "lb/in3",
      "fixed": "unitless",
      "percentage": "percent",
      "wattsPerSquareFoot": "W/ft2",
      "wattsPerSquareMeter": "W/m2",
      "britishThermalUnitsPerHourSquareFoot": "btu/hr/ft2",
      "cubicFeetPerMinuteSquareFoot": "ft3/min/ft2",
      "litersPerSecondSquareMeter": "l/s/m2",
      "cubicFeetPerMinuteTonOfRefrigeration": "ft3/min/ton_r",
      "litersPerSecondKilowatt": "l/s/kW",
      "squareFeet": "ft2",
      "squareInches": "in2",
      "squareMeters": "m2",
      "squareCentimeters": "cm2",
      "squareMillimeters": "mm2",
      "acres": "ac",
      "hectares": "ha",
      "squareMetersPerKilowatt": "m2/kW",
      "squareFeetPer1000BritishThermalUnitsPerHour": "ft2/kbtu/hr"
      }

      def self.call(config)
        units = config.units
        {"language": "#{config.language}",
        "units": {
          "heat_transfer_rate":"#{CONFIG_UNITS_TO_HTML[units.hvac_heating_load.to_sym]}",
          "temperature":"#{CONFIG_UNITS_TO_HTML[units.hvac_temperature.to_sym]}",
          "temperature_difference":"#{CONFIG_UNITS_TO_HTML[units.hvac_temperaturedifference.to_sym]}",
          "humidity_ratio":"#{CONFIG_UNITS_TO_HTML[units.mass.to_sym]}/#{CONFIG_UNITS_TO_HTML[units.mass.to_sym]}",
          "flow_rate":"#{CONFIG_UNITS_TO_HTML[units.hvac_airflow.to_sym]}",
          "specific_heat":"#{CONFIG_UNITS_TO_HTML[units.hvac_specificheat.to_sym]}",
          "density":"#{CONFIG_UNITS_TO_HTML[units.hvac_density.to_sym]}",
          "percent":"#{CONFIG_UNITS_TO_HTML[units.hvac_factor.to_sym]}",
          "outdoor_air_percentage":"#{CONFIG_UNITS_TO_HTML[units.hvac_factor.to_sym]}",
          "heat_transfer_rate_per_area":"#{CONFIG_UNITS_TO_HTML[units.hvac_heating_load_divided_by_area.to_sym]}",
          "area_per_heat_transfer_rate":"#{CONFIG_UNITS_TO_HTML[units.hvac_area_divided_by_heating_load.to_sym]}",
          "flow_rate_per_area":"#{CONFIG_UNITS_TO_HTML[units.hvac_airflow_density.to_sym]}",
          "flow_rate_per_heat_transfer_rate":"#{CONFIG_UNITS_TO_HTML[units.hvac_airflow_divided_by_cooling_load.to_sym]}",
          "people":"unitless",
          "area":"#{CONFIG_UNITS_TO_HTML[units.hvac_airflow_divided_by_cooling_load.to_sym]}"
        }}.to_h.to_json
      end
    end
  end
end

# require 'json'
# require_relative 'config'
# file_path = "/Users/npflaum/Documents/GitHub/SystemsAnalysisReports/measure/systems_analysis_report_generator/resources/build/reportConfig.json"
# config = SystemsAnalysisReport::Config.new({file_path: file_path})
# puts SystemsAnalysisReport::Configuration::JSONWriter.(config)