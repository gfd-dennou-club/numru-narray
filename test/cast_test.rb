require_relative "test_helper"

class CastTest < Test::Unit::TestCase
  def setup
    @a = NArray.int(3,3).indgen!
  end
  test "cast: a" do
    assert { @a == NArray[ [0, 1, 2], [3, 4, 5], [6, 7, 8] ] }
  end

  test "cast: a + 1.5" do
    assert { @a + 1.5 == NArray[ [1, 2, 3], [4, 5, 6], [7, 8, 9] ] }
  end

  test "cast: 1.5 + a" do
    assert { 1.5 + @a == NArray[ [1, 2, 3], [4, 5, 6], [7, 8, 9] ] }
  end

  test "cast: a + NArray[1.2,3.4,5.6]" do
    assert { @a + NArray[1.2,3.4,5.6] == NArray[
      [ 1.2, 4.4, 7.6 ],
      [ 4.2, 7.4, 10.6 ],
      [ 7.2, 10.4, 13.6 ] ]
    }
  end

  test "cast: a + NArray[Complex(0.5,1.5)]" do
    assert { @a + NArray[Complex(0.5,1.5)] == NArray[
      [ 0.5+1.5i, 1.5+1.5i, 2.5+1.5i ],
      [ 3.5+1.5i, 4.5+1.5i, 5.5+1.5i ],
      [ 6.5+1.5i, 7.5+1.5i, 8.5+1.5i ] ]
    }
  end
end
