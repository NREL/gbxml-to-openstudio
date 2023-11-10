class VRFCondenser < HVACObject
  attr_accessor :condenser, :condenser_loop_ref, :condenser_loop

  def initialize
    self.name = "VRF Condenser"
  end

  def self.create_from_xml(model_manager, xml)
    vrf_condenser = new
    vrf_condenser.model_manager = model_manager

    name = xml.elements['Name']
    vrf_condenser.set_name(xml.elements['Name'].text) unless name.nil?
    vrf_condenser.set_id(xml.attributes['id']) unless xml.attributes['id'].nil?
    vrf_condenser.set_cad_object_id(xml.elements['CADObjectId'].text) unless xml.elements['CADObjectId'].nil?

    cw_loop_ref = xml.elements['HydronicLoopId[@hydronicLoopType="CondenserWater"]']
    unless cw_loop_ref.nil?
      vrf_condenser.condenser_loop_ref = xml.elements['HydronicLoopId'].attributes['hydronicLoopIdRef']
    end

    vrf_condenser
  end

  def resolve_references
    if self.condenser_loop_ref
      cw_loop = self.model_manager.cw_loops[self.condenser_loop_ref]
      self.condenser_loop = cw_loop if cw_loop
    end
  end

  def build
    self.model_manager = model_manager
    self.model = model_manager.model
    self.condenser = add_condenser

    self.condenser.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    self.condenser.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?
  end

  def post_build
    if self.condenser_loop
      # water-cooled VRF
      self.condenser.setHeatingPerformanceCurveOutdoorTemperatureType('DryBulbTemperature')
      self.condenser.setCondenserType('WaterCooled')
      self.condenser_loop.plant_loop.addDemandBranchForComponent(self.condenser) if self.condenser_loop

      # comment this out to test with AC curves
      self.condenser.setCoolingCapacityRatioModifierFunctionofLowTemperatureCurve(wc_clg_cap_f_temp_low)
      self.condenser.setCoolingCapacityRatioBoundaryCurve(wc_clg_cap_boundary)
      self.condenser.setCoolingCapacityRatioModifierFunctionofHighTemperatureCurve(wc_clg_cap_f_temp_high)
      self.condenser.setCoolingEnergyInputRatioModifierFunctionofLowTemperatureCurve(wc_clg_eir_f_temp_low)
      self.condenser.setCoolingEnergyInputRatioBoundaryCurve(wc_clg_eir_boundary)
      self.condenser.setCoolingEnergyInputRatioModifierFunctionofHighTemperatureCurve(wc_clg_eir_f_temp_high)
      self.condenser.setCoolingEnergyInputRatioModifierFunctionofLowPartLoadRatioCurve(wc_clg_eir_f_plr_low)
      self.condenser.setCoolingEnergyInputRatioModifierFunctionofHighPartLoadRatioCurve(wc_clg_eir_f_plr_high)
      self.condenser.setCoolingCombinationRatioCorrectionFactorCurve(wc_clg_comb_ratio_corr)
      self.condenser.setCoolingPartLoadFractionCorrelationCurve(wc_clg_plf_corr)
      self.condenser.setMinimumHeatPumpPartLoadRatio(0.2)
      self.condenser.setPipingCorrectionFactorforLengthinCoolingModeCurve(wc_clg_piping_length_corr)
      self.condenser.setHeatingCapacityRatioModifierFunctionofLowTemperatureCurve(wc_htg_cap_f_temp_low)
      self.condenser.setHeatingCapacityRatioBoundaryCurve(wc_htg_cap_boundary)
      self.condenser.setHeatingCapacityRatioModifierFunctionofHighTemperatureCurve(wc_htg_cap_f_temp_high)
      self.condenser.setHeatingEnergyInputRatioModifierFunctionofLowTemperatureCurve(wc_htg_eir_f_temp_low)
      self.condenser.setHeatingEnergyInputRatioBoundaryCurve(wc_htg_eir_boundary)
      self.condenser.setHeatingEnergyInputRatioModifierFunctionofHighTemperatureCurve(wc_htg_eir_f_temp_high)
      self.condenser.setHeatingEnergyInputRatioModifierFunctionofLowPartLoadRatioCurve(wc_htg_eir_f_plr_low)
      self.condenser.setHeatingEnergyInputRatioModifierFunctionofHighPartLoadRatioCurve(wc_htg_eir_f_plr_high)
      self.condenser.setHeatingCombinationRatioCorrectionFactorCurve(wc_htg_comb_ratio_corr)
      self.condenser.setHeatingPartLoadFractionCorrelationCurve(wc_htg_plf_corr)
      self.condenser.setDefrostEnergyInputRatioModifierFunctionofTemperatureCurve(wc_htg_defrost)
      self.condenser.setPipingCorrectionFactorforLengthinHeatingModeCurve(wc_htg_piping_length_corr)

      # uncomment to test with AC curves
      # self.condenser.coolingEnergyInputRatioModifierFunctionofLowPartLoadRatioCurve.get.to_CurveCubic.get.setMinimumValueofx(self.condenser.minimumHeatPumpPartLoadRatio)
      # self.condenser.heatingEnergyInputRatioModifierFunctionofLowPartLoadRatioCurve.get.to_CurveCubic.get.setMinimumValueofx(self.condenser.minimumHeatPumpPartLoadRatio)
    else
      # air-cooled vrf
      # align EIRfPLR curve with heat pump min PLR
      self.condenser.coolingEnergyInputRatioModifierFunctionofLowPartLoadRatioCurve.get.to_CurveCubic.get.setMinimumValueofx(self.condenser.minimumHeatPumpPartLoadRatio)
      self.condenser.heatingEnergyInputRatioModifierFunctionofLowPartLoadRatioCurve.get.to_CurveCubic.get.setMinimumValueofx(self.condenser.minimumHeatPumpPartLoadRatio)
    end
  end

  private

  def add_condenser
    condenser = OpenStudio::Model::AirConditionerVariableRefrigerantFlow.new(model)
    condenser.setName(self.name) unless self.name.nil?
    condenser.additionalProperties.setFeature('id', self.id) unless self.id.nil?
    condenser.additionalProperties.setFeature('CADObjectId', self.cad_object_id) unless self.cad_object_id.nil?

    condenser
  end

  def wc_clg_cap_f_temp_low
    coeffs_ip = [
      -2.6980300,
      0.1027334,
      -0.0007143,
      0.0003602,
      -0.0000028,
      -0.0000002
    ]

    coeffs_si = Curves.convert_biquadratic_temp_coeffs_ip_to_si(coeffs_ip)

    min_x_f = 59.0
    max_x_f = 75.0
    min_y_f = 50.0
    max_y_f = 85.0

    return Curves.make_curve_biquadratic(self.model,
                                           coeffs_si,
                                           "WSVRF_ClgCapFTempLow",
                                           OpenStudio.convert(min_x_f,'F','C').get,
                                           OpenStudio.convert(max_x_f,'F','C').get,
                                           OpenStudio.convert(min_y_f,'F','C').get,
                                           OpenStudio.convert(max_y_f,'F','C').get)
  end

  def wc_clg_cap_f_temp_high
    coeffs_ip = [
      -2.3881110,
      0.1027532,
      -0.0006745,
      -0.0014355,
      -0.0000010,
      -0.0000621
    ]

    coeffs_si = Curves.convert_biquadratic_temp_coeffs_ip_to_si(coeffs_ip)

    min_x_f = 59.0
    max_x_f = 75.0
    min_y_f = 90.0
    max_y_f = 110.0

    return Curves.make_curve_biquadratic(self.model,
                                           coeffs_si,
                                           "WSVRF_ClgCapFTempHigh",
                                           OpenStudio.convert(min_x_f,'F','C').get,
                                           OpenStudio.convert(max_x_f,'F','C').get,
                                           OpenStudio.convert(min_y_f,'F','C').get,
                                           OpenStudio.convert(max_y_f,'F','C').get)
  end

  def wc_clg_cap_boundary
    coeffs_ip = [
      86,0,0,0
    ]

    coeffs_si = Curves.convert_cubic_temp_coeffs_ip_to_si(coeffs_ip)

    min_x_f = 59
    max_x_f = 75

    return Curves.make_curve_cubic(self.model,
                                     coeffs_si,
                                     "WSVRF_ClgCapBoundary",
                                     OpenStudio.convert(min_x_f,'F','C').get,
                                     OpenStudio.convert(max_x_f,'F','C').get)
  end

  def wc_clg_eir_f_temp_low
    coeffs_ip = [
      -1.0613700,
      0.0696207,
      -0.0005361,
      -0.0114361,
      0.0002386,
      -0.0001688,
    ]

    coeffs_si = Curves.convert_biquadratic_temp_coeffs_ip_to_si(coeffs_ip)

    min_x_f = 59.0
    max_x_f = 75.0
    min_y_f = 50.0
    max_y_f = 85.0

    return Curves.make_curve_biquadratic(self.model,
                                           coeffs_si,
                                           "WSVRF_ClgEIRFTempLow",
                                           OpenStudio.convert(min_x_f,'F','C').get,
                                           OpenStudio.convert(max_x_f,'F','C').get,
                                           OpenStudio.convert(min_y_f,'F','C').get,
                                           OpenStudio.convert(max_y_f,'F','C').get)
  end

  def wc_clg_eir_f_temp_high
    coeffs_ip = [
      -3.5991610,
      0.1188687,
      -0.0007926,
      0.0119617,
      0.0001617,
      -0.0003495,
    ]

    coeffs_si = Curves.convert_biquadratic_temp_coeffs_ip_to_si(coeffs_ip)

    min_x_f = 59.0
    max_x_f = 75.0
    min_y_f = 90.0
    max_y_f = 110.0

    return Curves.make_curve_biquadratic(self.model,
                                           coeffs_si,
                                           "WSVRF_ClgEIRFTempHigh",
                                           OpenStudio.convert(min_x_f,'F','C').get,
                                           OpenStudio.convert(max_x_f,'F','C').get,
                                           OpenStudio.convert(min_y_f,'F','C').get,
                                           OpenStudio.convert(max_y_f,'F','C').get)
  end

  def wc_clg_eir_boundary
    coeffs_ip = [
      86,0,0,0
    ]

    coeffs_si = Curves.convert_cubic_temp_coeffs_ip_to_si(coeffs_ip)

    min_x_f = 59
    max_x_f = 75

    return Curves.make_curve_cubic(self.model,
                                     coeffs_si,
                                     "WSVRF_ClgEIRBoundary",
                                     OpenStudio.convert(min_x_f,'F','C').get,
                                     OpenStudio.convert(max_x_f,'F','C').get)
  end

  def wc_clg_eir_f_plr_low
    coeffs = [
      0.111297,
      0.117905,
      0.770798,
      0.000000,
    ]

    min_x = 0.2
    max_x = 1.0

    return Curves.make_curve_cubic(self.model,
                                           coeffs,
                                           "WSVRF_ClgEIRFPLRLow",
                                           min_x,
                                           max_x)
  end

  def wc_clg_eir_f_plr_high
    coeffs = [
      1,0,0,0
    ]

    min_x = 1.0
    max_x = 1.5

    return Curves.make_curve_cubic(self.model,
                                           coeffs,
                                           "WSVRF_ClgEIRFPLRHigh",
                                           min_x,
                                           max_x)
  end

  def wc_clg_comb_ratio_corr
    coeffs = [
      1,0
    ]

    return Curves.make_curve_linear(self.model, coeffs, "WSVRF_ClgCombRatioCorrection",100,150)
  end

  def wc_clg_plf_corr
    coeffs = [
      0.85, 0.15, 0
    ]

    return Curves.make_curve_quadratic(self.model, coeffs, "WSVRF_ClgPLFCorrection")
  end

  def wc_clg_piping_length_corr
    coeffs_ip = [
      1.7661, -5.1543E-4, 1.7328E-7, -1.2548, 5.024E-1, -5.1683E-5
    ]

    coeffs_si = Curves.convert_biquadratic_x_ft_to_m(coeffs_ip)

    min_x_ft = 0
    max_x_ft = 600
    min_y = 0
    max_y = 100

    return Curves.make_curve_biquadratic(self.model,
                                           coeffs_si,
                                           "WCVRF_ClgPipingCorrection",
                                           OpenStudio.convert(min_x_ft,"ft","m").get,
                                           OpenStudio.convert(max_x_ft,"ft","m").get,
                                           min_y,
                                           max_y)
  end

  def wc_htg_cap_f_temp_low
    coeffs_ip = [
      -3.1546820,
      0.1033258,
      -0.0007634,
      0.0159748,
      0.0000284,
      -0.0001086
    ]

    coeffs_si = Curves.convert_biquadratic_temp_coeffs_ip_to_si(coeffs_ip)

    min_x_f = 59.0
    max_x_f = 79.0
    min_y_f = 50.0
    max_y_f = 60.0

    return Curves.make_curve_biquadratic(self.model,
                                           coeffs_si,
                                           "WSVRF_HtgCapFTempLow",
                                           OpenStudio.convert(min_x_f,'F','C').get,
                                           OpenStudio.convert(max_x_f,'F','C').get,
                                           OpenStudio.convert(min_y_f,'F','C').get,
                                           OpenStudio.convert(max_y_f,'F','C').get)
  end

  def wc_htg_cap_f_temp_high
    coeffs_ip = [
      -2.4191940,
      0.1080541,
      -0.0008475,
      -0.0002298,
      0.0000011,
      0.0000002
    ]

    coeffs_si = Curves.convert_biquadratic_temp_coeffs_ip_to_si(coeffs_ip)

    min_x_f = 59.0
    max_x_f = 79.0
    min_y_f = 65.0
    max_y_f = 110.0

    return Curves.make_curve_biquadratic(self.model,
                                           coeffs_si,
                                           "WSVRF_HtgCapFTempHigh",
                                           OpenStudio.convert(min_x_f,'F','C').get,
                                           OpenStudio.convert(max_x_f,'F','C').get,
                                           OpenStudio.convert(min_y_f,'F','C').get,
                                           OpenStudio.convert(max_y_f,'F','C').get)
  end

  def wc_htg_cap_boundary
    coeffs_ip = [
      63,0,0,0
    ]

    coeffs_si = Curves.convert_cubic_temp_coeffs_ip_to_si(coeffs_ip)

    min_x_f = 59
    max_x_f = 79

    return Curves.make_curve_cubic(self.model,
                                     coeffs_si,
                                     "WSVRF_HtgCapBoundary",
                                     OpenStudio.convert(min_x_f,'F','C').get,
                                     OpenStudio.convert(max_x_f,'F','C').get)
  end

  def wc_htg_eir_f_temp_low
    coeffs_ip = [
      -3.4799440,
      0.1441891,
      -0.0009553,
      -0.0165525,
      0.0001225,
      -0.0000583
    ]

    coeffs_si = Curves.convert_biquadratic_temp_coeffs_ip_to_si(coeffs_ip)

    min_x_f = 59.0
    max_x_f = 79.0
    min_y_f = 50.0
    max_y_f = 60.0

    return Curves.make_curve_biquadratic(self.model,
                                           coeffs_si,
                                           "WSVRF_HtgEIRFTempLow",
                                           OpenStudio.convert(min_x_f,'F','C').get,
                                           OpenStudio.convert(max_x_f,'F','C').get,
                                           OpenStudio.convert(min_y_f,'F','C').get,
                                           OpenStudio.convert(max_y_f,'F','C').get)
  end

  def wc_htg_eir_f_temp_high
    coeffs_ip = [
      -0.4974960,
      0.1049789,
      -0.0006845,
      -0.0534024,
      0.0002915,
      -0.0000454
    ]

    coeffs_si = Curves.convert_biquadratic_temp_coeffs_ip_to_si(coeffs_ip)

    min_x_f = 59.0
    max_x_f = 79.0
    min_y_f = 65.0
    max_y_f = 110.0

    return Curves.make_curve_biquadratic(self.model,
                                           coeffs_si,
                                           "WSVRF_HtgEIRFTempHigh",
                                           OpenStudio.convert(min_x_f,'F','C').get,
                                           OpenStudio.convert(max_x_f,'F','C').get,
                                           OpenStudio.convert(min_y_f,'F','C').get,
                                           OpenStudio.convert(max_y_f,'F','C').get)
  end

  def wc_htg_eir_boundary
    coeffs_ip = [
      63,0,0,0
    ]

    coeffs_si = Curves.convert_cubic_temp_coeffs_ip_to_si(coeffs_ip)

    min_x_f = 59
    max_x_f = 75

    return Curves.make_curve_cubic(self.model,
                                     coeffs_si,
                                     "WSVRF_HtgEIRBoundary",
                                     OpenStudio.convert(min_x_f,'F','C').get,
                                     OpenStudio.convert(max_x_f,'F','C').get)
  end

  def wc_htg_eir_f_plr_low
    coeffs = [
      3.6836662,
      0.3845370,
      0.5786260,
      0.0000000
    ]

    min_x = 0.2
    max_x = 1.0

    return Curves.make_curve_cubic(self.model,
                                           coeffs,
                                           "WSVRF_HtgEIRFPLRLow",
                                           min_x,
                                           max_x)
  end

  def wc_htg_eir_f_plr_high
    coeffs = [
      1,0,0,0
    ]

    min_x = 1.0
    max_x = 1.5

    return Curves.make_curve_cubic(self.model,
                                           coeffs,
                                           "WSVRF_HtgEIRFPLRHigh",
                                           min_x,
                                           max_x)
  end

  def wc_htg_comb_ratio_corr
    coeffs = [
      1,0,0,0
    ]

    return Curves.make_curve_cubic(self.model, coeffs, "WSVRF_HtgCombRatioCorrection",0,100)
  end

  def wc_htg_plf_corr
    coeffs = [
      0.85, 0.15, 0
    ]

    return Curves.make_curve_quadratic(self.model, coeffs, "WSVRF_HtgPLFCorrection")
  end

  def wc_htg_piping_length_corr
    coeffs_ip = [
      1.0055, -2.3122E-4, 7.641E-8, 0
    ]

    coeffs_si = Curves.convert_cubic_ft_to_m(coeffs_ip)

    min_x_ft = 0
    max_x_ft = 600

    return Curves.make_curve_cubic(self.model,
                                     coeffs_si,
                                     "WCVRF_HtgPipingCorrection",
                                     OpenStudio.convert(min_x_ft,"ft","m").get,
                                     OpenStudio.convert(max_x_ft,"ft","m").get)
  end

  def wc_htg_defrost
    coeffs_ip = [
      1,0,0,0,0,0
    ]
    coeffs_si = Curves.convert_biquadratic_temp_coeffs_ip_to_si(coeffs_ip)

    min_x_f = 64.0
    max_x_f = 86.0
    min_y_f = 64.0
    max_y_f = 104.0

    return Curves.make_curve_biquadratic(self.model,
                                           coeffs_si,
                                           "WSVRF_HtgDefrostEIRfTemp",
                                           OpenStudio.convert(min_x_f,'F','C').get,
                                           OpenStudio.convert(max_x_f,'F','C').get,
                                           OpenStudio.convert(min_y_f,'F','C').get,
                                           OpenStudio.convert(max_y_f,'F','C').get)
  end

end
