require_relative "test_helper"

class ArrayTest < Test::Unit::TestCase

  def setup
    @a = NArray.float(3,3).indgen
    @b = NArray.float(2,2).indgen
  end

  test "array: 01" do
    assert { @a == NArray[[ 0, 1, 2 ], [ 3, 4, 5 ], [ 6, 7, 8 ]] }
  end

  test "array: 02" do
    assert { NArray[@a, [100, 101]] == NArray[
      [[ 0, 1, 2 ], [ 3, 4, 5 ], [ 6, 7, 8 ]],
      [100, 101]]
    }
  end

  test "array: 03" do
    assert { NArray[@b, [@b]] == NArray[
      [ [ [ 0.0, 0.0 ], [ 1.0, 0.0 ] ],
        [ [ 2.0, 0.0 ], [ 3.0, 0.0 ] ] ],
      [ [ [ 0.0, 1.0 ],[ 2.0, 3.0 ] ],[ [ 0.0, 0.0 ],[ 0.0, 0.0 ] ] ] ]
    }
  end
end
