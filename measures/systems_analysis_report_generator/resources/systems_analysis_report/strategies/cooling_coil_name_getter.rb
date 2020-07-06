module SystemsAnalysisReport
  module Strategies
    class CoolingCoilNameGetter
      def self.call(model)
        cooling_coils = []

        cooling_coils += model.getCoilCoolingDXMultiSpeeds
        cooling_coils += model.getCoilCoolingDXSingleSpeeds
        cooling_coils += model.getCoilCoolingDXTwoSpeeds
        cooling_coils += model.getCoilCoolingDXTwoStageWithHumidityControlModes
        cooling_coils += model.getCoilCoolingDXVariableRefrigerantFlows
        cooling_coils += model.getCoilCoolingDXVariableSpeeds
        cooling_coils += model.getCoilCoolingWaters
        cooling_coils += model.getCoilCoolingWaterToAirHeatPumpEquationFits
        cooling_coils += model.getCoilCoolingWaterToAirHeatPumpVariableSpeedEquationFits

        return cooling_coils.map { |coil| coil.name.get  }
      end
    end
  end
end