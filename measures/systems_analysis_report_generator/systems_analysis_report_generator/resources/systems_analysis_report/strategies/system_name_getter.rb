module SystemsAnalysisReport
  module Strategies
    class SystemNameGetter
      CoolingCoilIddObjectTypes = [
          OpenStudio::Model::CoilCoolingDXMultiSpeed::iddObjectType,
          OpenStudio::Model::CoilCoolingDXSingleSpeed::iddObjectType,
          OpenStudio::Model::CoilCoolingDXTwoSpeed::iddObjectType,
          OpenStudio::Model::CoilCoolingDXTwoStageWithHumidityControlMode::iddObjectType,
          OpenStudio::Model::CoilCoolingDXVariableRefrigerantFlow::iddObjectType,
          OpenStudio::Model::CoilCoolingDXVariableSpeed::iddObjectType,
          OpenStudio::Model::CoilCoolingWater::iddObjectType,
          OpenStudio::Model::CoilCoolingWaterToAirHeatPumpEquationFit::iddObjectType,
          OpenStudio::Model::CoilCoolingWaterToAirHeatPumpVariableSpeedEquationFit::iddObjectType
      ]

      HeatingCoilIddObjectTypes = [
          OpenStudio::Model::CoilHeatingDesuperheater::iddObjectType,
          OpenStudio::Model::CoilHeatingDXMultiSpeed::iddObjectType,
          OpenStudio::Model::CoilHeatingDXSingleSpeed::iddObjectType,
          OpenStudio::Model::CoilHeatingDXVariableSpeed::iddObjectType,
          OpenStudio::Model::CoilHeatingDXVariableRefrigerantFlow::iddObjectType,
          OpenStudio::Model::CoilHeatingElectric::iddObjectType,
          OpenStudio::Model::CoilHeatingGas::iddObjectType,
          OpenStudio::Model::CoilHeatingGasMultiStage::iddObjectType,
          OpenStudio::Model::CoilHeatingWater::iddObjectType,
          OpenStudio::Model::CoilHeatingWaterToAirHeatPumpEquationFit::iddObjectType,
          OpenStudio::Model::CoilHeatingWaterToAirHeatPumpVariableSpeedEquationFit::iddObjectType
      ]

      def self.call(model)
        names = []

        model.getAirLoopHVACs.map do |air_loop|
          system_names = []
          system_names << air_loop.name.get
          system_names << self.get_air_loop_hvac_first_cooling_coil_names(air_loop)[0]
          system_names << self.get_air_loop_hvac_first_heating_coil_names(air_loop)[0]
          names << system_names
        end

        names
      end

      def self.get_air_loop_hvac_first_cooling_coil_names(air_loop_hvac)
        coils = []

        CoolingCoilIddObjectTypes.each do |idd_object_type|
          coils += air_loop_hvac.supplyComponents(idd_object_type).map { |coil| coil.name.get  }
        end

        coils
      end

      def self.get_air_loop_hvac_first_heating_coil_names(air_loop_hvac)
        coils = []

        HeatingCoilIddObjectTypes.each do |idd_object_type|
          coils += air_loop_hvac.supplyComponents(idd_object_type).map { |coil| coil.name.get  }
        end

        coils
      end
    end
  end
end