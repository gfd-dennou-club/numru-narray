require_relative "test_helper"

class BitTest < Test::Unit::TestCase
  def setup
    @a = NArray.byte(10).indgen!
  end

  test "bit: Narray.byte(10).indgen!" do
    assert { @a == NArray[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ]}
  end

  test "bit: a & 1 " do
    assert { @a & 1  == NArray[ 0, 1, 0, 1, 0, 1, 0, 1, 0, 1 ] }
  end

  test "bit: a & 2" do
    assert { @a & 2  == NArray[ 0, 0, 2, 2, 0, 0, 2, 2, 0, 0 ] }
  end

  test "bit: a & -1" do
    assert { @a & (-1)  == NArray[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ] }
  end

  test "bit: a | 1 " do
    assert { @a | 1  == NArray[ 1, 1, 3, 3, 5, 5, 7, 7, 9, 9 ] }
  end

  test "bit: a | 2" do
    assert { @a | 2  == NArray[ 2, 3, 2, 3, 6, 7, 6, 7, 10, 11 ] }
  end

  test "bit: a | -1" do
    assert { @a | (-1)  == NArray[ 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 ] }
  end

  test "bit: a ^ 1 " do
    assert { @a^1  == NArray[ 1, 0, 3, 2, 5, 4, 7, 6, 9, 8 ] }
  end

  test "bit: a ^ 2" do
    assert { @a^2  == NArray[ 2, 3, 0, 1, 6, 7, 4, 5, 10, 11 ] }
  end

  test "bit: a ^ -1" do
    assert { @a^(-1)  == NArray[ 255, 254, 253, 252, 251, 250, 249, 248, 247, 246 ] }
  end

  test "bit: ~a " do
    assert { ~@a  == NArray[ 255, 254, 253, 252, 251, 250, 249, 248, 247, 246 ] }
  end

end
