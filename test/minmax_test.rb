require_relative "test_helper"

class MinMaxTest < Test::Unit::TestCase

  def setup
    @a = NArray[0, 2, -2.5, 3, 1.4 ]
    @b = NArray.float(5,1).indgen!(1)
    @c = NArray.float(1,3).indgen!(1)
    @c *= @b
  end

  test "min" do
    assert{ @a.min == -2.5 }
    assert{ @c.min == 1.0 }
    assert{ @c.min(0) == NArray[ 1.0, 2.0, 3.0 ] }
    assert{ @c.min(1) == NArray[ 1.0, 2.0, 3.0, 4.0, 5.0 ] }
  end

  test "max" do
    assert{ @a.max == 3.0 }
    assert{ @c.max == 15.0 }
    assert{ @c.max(0) == NArray[ 5.0, 10.0, 15.0 ] }
    assert{ @c.max(1) == NArray[ 3.0, 6.0, 9.0, 12.0, 15.0 ] }
  end

  test "sum" do
    assert{ @a.sum == 3.9 }
    assert{ @c.sum == 90.0 }
    assert{ @c.sum(0) == NArray[ 15.0, 30.0, 45.0 ] }
    assert{ @c.sum(1) == NArray[ 6.0, 12.0, 18.0, 24.0, 30.0 ] }
  end

  test "mean" do
    assert{ @a.mean == 0.78 }
    assert{ @c.mean == 6.0 }
    assert{ @c.mean(0) == NArray[ 3.0, 6.0, 9.0 ] }
    assert{ @c.mean(1) == NArray[ 2.0, 4.0, 6.0, 8.0, 10.0 ] }
  end

  test "stddev" do
    assert{ @a.stddev == 2.131196846844514 }
    assert{ @c.stddev == 4.053217416888888 }
    assert_in_delta  @c.stddev(0), NArray[ 1.58114, 3.16228, 4.74342 ], Float::EPSILON
    assert{ @c.stddev(1) == NArray[ 1.0, 2.0, 3.0, 4.0, 5.0 ]}
  end

end
