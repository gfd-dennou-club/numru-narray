require_relative "test_helper"

class StatisticsTest < Test::Unit::TestCase

  def setup
    @x = NArray[65, 63, 67, 64, 68, 62, 70, 66, 68, 67, 69, 71]
    @y = NArray[68, 66, 68, 65, 69, 66, 68, 65, 71, 67, 68, 70]
  end

  test "statistics: covariance(x,y)" do

    assert { covariance(@x,@y) == 3.6666666666666674 }
  end

  test "statistics: x.stddev" do
    assert { @x.stddev == 2.774341308665842 }
  end

  test "statistics: x.sort" do
    assert { @x.sort == NArray[ 62, 63, 64, 65, 66, 67, 67, 68, 68, 69, 70, 71 ] }
  end

  test "statistics: x.median" do
    assert { @x.median == 67 }
  end

  test "statistics: (x+y.newrank!(0)).median(0)" do
    assert { (@x+@y.newrank!(0)).median(0) == NArray[ 135, 133, 135, 132, 136, 133, 135, 132, 138, 134, 135, 137 ] }
  end

end
