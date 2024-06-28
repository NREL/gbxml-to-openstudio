# Helper module for curve creation
module Curves

  def self.make_curve_linear(model, coeffs, name, min_x, max_x, min_out=nil, max_out=nil)
    curve = OpenStudio::Model::CurveLinear.new(model)
    curve.setName(name)
    curve.setCoefficient1Constant(coeffs[0])
    curve.setCoefficient2x(coeffs[1])
    curve.setMinimumValueofx(min_x) unless min_x.nil?
    curve.setMaximumValueofx(max_x) unless max_x.nil?
    curve.setMinimumCurveOutput(min_out) unless min_out.nil?
    curve.setMaximumCurveOutput(max_out) unless max_out.nil?
    return curve
  end

  def self.make_curve_quad_linear(model, coeffs, name, min_w, max_w, min_x, max_x, min_y, max_y, min_z, max_z)
    curve = OpenStudio::Model::CurveQuadLinear.new(model)
    curve.setName(name)
    curve.setCoefficient1Constant(coeffs[0])
    curve.setCoefficient2w(coeffs[1])
    curve.setCoefficient3x(coeffs[2])
    curve.setCoefficient4y(coeffs[3])
    curve.setCoefficient5z(coeffs[4])
    curve.setMinimumValueofw(min_w) unless min_w.nil?
    curve.setMaximumValueofw(max_w) unless max_w.nil?
    curve.setMinimumValueofx(min_x) unless min_x.nil?
    curve.setMaximumValueofx(max_x) unless max_x.nil?
    curve.setMinimumValueofy(min_y) unless min_y.nil?
    curve.setMaximumValueofy(max_y) unless max_y.nil?
    curve.setMinimumValueofz(min_z) unless min_z.nil?
    curve.setMaximumValueofz(max_z) unless max_z.nil?
    return curve
  end

  def self.make_curve_quint_linear(model, coeffs, name, min_v, max_v, min_w, max_w, min_x, max_x, min_y, max_y, min_z, max_z)
    curve = OpenStudio::Model::CurveQuintLinear.new(model)
    curve.setName(name)
    curve.setCoefficient1Constant(coeffs[0])
    curve.setCoefficient2v(coeffs[1])
    curve.setCoefficient3w(coeffs[2])
    curve.setCoefficient4x(coeffs[3])
    curve.setCoefficient5y(coeffs[4])
    curve.setCoefficient6z(coeffs[5])
    curve.setMinimumValueofv(min_v) unless min_v.nil?
    curve.setMaximumValueofv(max_v) unless max_v.nil?
    curve.setMinimumValueofw(min_w) unless min_w.nil?
    curve.setMaximumValueofw(max_w) unless max_w.nil?
    curve.setMinimumValueofx(min_x) unless min_x.nil?
    curve.setMaximumValueofx(max_x) unless max_x.nil?
    curve.setMinimumValueofy(min_y) unless min_y.nil?
    curve.setMaximumValueofy(max_y) unless max_y.nil?
    curve.setMinimumValueofz(min_z) unless min_z.nil?
    curve.setMaximumValueofz(max_z) unless max_z.nil?
    return curve
  end

  def self.make_curve_cubic(model, coeffs, name, min_x, max_x, min_out=nil, max_out=nil)
    curve = OpenStudio::Model::CurveCubic.new(model)
    curve.setName(name)
    curve.setCoefficient1Constant(coeffs[0])
    curve.setCoefficient2x(coeffs[1])
    curve.setCoefficient3xPOW2(coeffs[2])
    curve.setCoefficient4xPOW3(coeffs[3])
    curve.setMinimumValueofx(min_x) unless min_x.nil?
    curve.setMaximumValueofx(max_x) unless max_x.nil?
    curve.setMinimumCurveOutput(min_out) unless min_out.nil?
    curve.setMaximumCurveOutput(max_out) unless max_out.nil?
    return curve
  end

  def self.make_curve_biquadratic(model, coeffs, name, min_x, max_x, min_y=nil, max_y=nil, min_out=nil, max_out=nil)
    curve = OpenStudio::Model::CurveBiquadratic.new(model)
    curve.setName(name)
    curve.setCoefficient1Constant(coeffs[0])
    curve.setCoefficient2x(coeffs[1])
    curve.setCoefficient3xPOW2(coeffs[2])
    curve.setCoefficient4y(coeffs[3])
    curve.setCoefficient5yPOW2(coeffs[4])
    curve.setCoefficient6xTIMESY(coeffs[5])
    curve.setMinimumValueofx(min_x) unless min_x.nil?
    curve.setMaximumValueofx(max_x) unless max_x.nil?
    curve.setMinimumValueofy(min_y) unless min_y.nil?
    curve.setMaximumValueofy(max_y) unless max_y.nil?
    curve.setMinimumCurveOutput(min_out) unless min_out.nil?
    curve.setMaximumCurveOutput(max_out) unless max_out.nil?
    return curve
  end

  def self.make_curve_quadratic(model, coeffs, name, min_x=nil, max_x=nil, min_out=nil, max_out=nil)
    curve = OpenStudio::Model::CurveQuadratic.new(model)
    curve.setName(name)
    curve.setCoefficient1Constant(coeffs[0])
    curve.setCoefficient2x(coeffs[1])
    curve.setCoefficient3xPOW2(coeffs[2])
    curve.setMinimumValueofx(min_x) unless min_x.nil?
    curve.setMaximumValueofx(max_x) unless max_x.nil?
    curve.setMinimumCurveOutput(min_out) unless min_out.nil?
    curve.setMaximumCurveOutput(max_out) unless max_out.nil?
    return curve
  end


  # converts a set of biquadratic curve coefficients where the independent variables are
  # temperatures in F to coefficients where the independent variables are temperatures in C.
  def self.convert_biquadratic_temp_coeffs_ip_to_si(coeffs)
    coeffs_si = []
    coeffs_si[0] = (coeffs[0] * 25 +
                    coeffs[1] * 800 +
                    coeffs[2] * 25600 +
                    coeffs[3] * 800 +
                    coeffs[4] * 25600 +
                    coeffs[5] * 25600)/25

    coeffs_si[1] = (coeffs[1] * 45 +
                    coeffs[2] * 2880 +
                    coeffs[5] * 1440)/25

    coeffs_si[2] = (coeffs[2] * 81)/25

    coeffs_si[3] = (coeffs[3] * 45 +
                    coeffs[4] * 2880 +
                    coeffs[5] * 1440)/25

    coeffs_si[4] = (coeffs[4] * 81)/25

    coeffs_si[5] = (coeffs[5] * 81)/25

    return coeffs_si
  end

  # converts a set of biquadratic curve coefficients where the independent variables are
  # temperatures in C to coefficients where the independent variables are temperatures in F.
  def self.convert_biquadratic_temp_coeffs_si_to_ip(coeffs)
    coeffs_ip = []
    coeffs_ip[0] = (coeffs[0] * 81 +
                    coeffs[1] * 1440 +
                    coeffs[2] * 25600 +
                    coeffs[3] * 1440 +
                    coeffs[4] * 25600 +
                    coeffs[5] * 25600)/81

    coeffs_ip[1] = (coeffs[1] * 45 +
                    coeffs[2] * 1600 +
                    coeffs[5] * 800)/81

    coeffs_ip[2] = (coeffs[2] * 25)/81

    coeffs_ip[3] = (coeffs[3] * 45 +
                    coeffs[4] * 1600 +
                    coeffs[5] * 800)/81

    coeffs_ip[4] = (coeffs[4] * 25)/81

    coeffs_ip[5] = (coeffs[5] * 25)/81

    return coeffs_ip
  end

  # converts the coefficients of a biquadratic curve where the first independent variable
  # is in ft and the second in (unitless) fraction to coefficients where the first IV in meters.
  # used for VRF AC Piping Correction Factor curve.
  def self.convert_biquadratic_x_ft_to_m(coeffs)
    coeffs_si = []
    coeffs_si[0] = coeffs[0]
    coeffs_si[1] = coeffs[1]/0.3048
    coeffs_si[2] = coeffs[2]/(0.3048)**2
    coeffs_si[3] = coeffs[3]
    coeffs_si[4] = coeffs[4]
    coeffs_si[5] = coeffs[5]/(0.3048)**2

    return coeffs_si
  end

  def self.convert_cubic_ft_to_m(coeffs)
    coeffs_si = []
    coeffs_si[0] = coeffs[0]
    coeffs_si[1] = coeffs[1]/0.3048
    coeffs_si[2] = coeffs[2]/(0.3048)**2
    coeffs_si[3] = coeffs[3]/(0.3048)**3

    return coeffs_si
  end

  def self.convert_cubic_temp_coeffs_ip_to_si(coeffs)
    if coeffs.drop(1).all?(0)
      coeffs_si = [OpenStudio.convert(coeffs[0],"F","C").get,0,0,0]
    else
      # not implemented
      coeffs_si = coeffs
    end

    return coeffs_si
  end

end