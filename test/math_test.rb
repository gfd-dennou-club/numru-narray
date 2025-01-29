require_relative "test_helper"

class MathTest < Test::Unit::TestCase

  test "math: sfloat" do
    x = NArray.sfloat(6).indgen.div!(2)
    ans = NArray.sfloat(6)
    for i in 0..5 do
      ans[i] = sqrt(x[i])
    end
    assert { (sqrt(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = sin(x[i])
    end
    assert { (sin(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = tan(x[i])
    end
    assert { (tan(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = sinh(x[i])
    end
    assert { (sinh(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = cosh(x[i])
    end
    assert { (cosh(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = tanh(x[i])
    end
    assert { ( tanh(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = exp(x[i])
    end
    assert { ( exp(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = log(x[i])
    end
    assert { ( log(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = log10(x[i])
    end
    assert { ( log10(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = atan(x[i])
    end
    assert { ( atan(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = atan(atan(x[i]))
    end
    assert { ( atan(atan(x)) - ans).abs <= Float::EPSILON }
  end

  test "math: float" do
    x = NArray.float(6).indgen.div!(2)
    ans = NArray.float(6)
    for i in 0..5 do
      ans[i] = sqrt(x[i])
    end
    assert { (sqrt(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = sin(x[i])
    end
    assert { (sin(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = tan(x[i])
    end
    assert { (tan(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = sinh(x[i])
    end
    assert { (sinh(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = cosh(x[i])
    end
    assert { (cosh(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = tanh(x[i])
    end
    assert { ( tanh(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = exp(x[i])
    end
    assert { ( exp(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = log(x[i])
    end
    assert { ( log(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = log10(x[i])
    end
    assert { ( log10(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = atan(x[i])
    end
    assert { ( atan(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = atan(atan(x[i]))
    end
    assert { ( atan(atan(x)) - ans).abs <= Float::EPSILON }
  end

  test "math: scomplex" do
    x = NArray.scomplex(6).indgen.div!(2)-2 - Complex(0,1)
    ans = NArray.scomplex(6)
    for i in 0..5 do
      ans[i] = sqrt(x[i])
    end
    assert { (sqrt(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = sin(x[i])
    end
    assert { (sin(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = tan(x[i])
    end
    assert { (tan(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = sinh(x[i])
    end
    assert { (sinh(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = cosh(x[i])
    end
    assert { (cosh(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = tanh(x[i])
    end
    assert { ( tanh(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = exp(x[i])
    end
    assert { ( exp(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = log(x[i])
    end
    assert { ( log(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = log10(x[i])
    end
    assert { ( log10(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = atan(x[i])
    end
    assert { ( atan(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = atan(atan(x[i]))
    end
    assert { ( atan(atan(x)) - ans).abs <= Float::EPSILON }
  end

  test "math: complex" do
    x = NArray.complex(6).indgen!/5-0.5
    ans = NArray.complex(6)
    for i in 0..5 do
      ans[i] = sqrt(x[i])
    end
    assert { (sqrt(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = sin(x[i])
    end
    assert { (sin(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = tan(x[i])
    end
    assert { (tan(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = sinh(x[i])
    end
    assert { (sinh(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = cosh(x[i])
    end
    assert { (cosh(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = tanh(x[i])
    end
    assert { ( tanh(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = exp(x[i])
    end
    assert { ( exp(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = log(x[i])
    end
    assert { ( log(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = log10(x[i])
    end
    assert { ( log10(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = atan(x[i])
    end
    assert { ( atan(x) - ans).abs <= Float::EPSILON }
    ##
    for i in 0..5 do
      ans[i] = atan(atan(x[i]))
    end
    assert { ( atan(atan(x)) - ans).abs <= Float::EPSILON }
  end

  test "math: f*f^-1:X → X, X in C " do
    x = NArray.complex(7).random!(1)
    x.imag= NArray.float(7).random!(1)
    ##
    assert { ( asin(sin(x)) - x).abs <= Float::EPSILON }
    assert { ( acos(cos(x)) - x).abs <= Float::EPSILON }
    assert { ( atan(tan(x)) - x).abs <= Float::EPSILON }
    assert { ( asinh(sinh(x)) - x).abs <= Float::EPSILON }
    assert { ( acosh(cosh(x)) - x).abs <= Float::EPSILON }
    assert { ( atanh(tanh(x)) - x).abs <= Float::EPSILON }
    assert { ( asec(sec(x)) - x).abs <= Float::EPSILON }
    assert { ( asech(sech(x)) - x).abs <= Float::EPSILON }
  end
end
