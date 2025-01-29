require_relative "test_helper"

class TransposeTest < Test::Unit::TestCase
  def setup
    @a = NArray.int(4,3,2).indgen!
  end

  test "transpose: first and second..."  do
    assert { @a.transpose(1,0) == NArray[
      [ [ 0, 4, 8 ],
        [ 1, 5, 9 ],
        [ 2, 6, 10 ],
        [ 3, 7, 11 ] ],
      [ [ 12, 16, 20 ],
        [ 13, 17, 21 ],
        [ 14, 18, 22 ],
        [ 15, 19, 23 ] ] ]
    }
  end

  test "transpose: first and last..."  do
    assert { @a.transpose(-1,1..-2,0) == NArray[
      [ [ 0, 12 ], [ 4, 16 ], [ 8, 20 ] ],
      [ [ 1, 13 ], [ 5, 17 ], [ 9, 21 ] ],
      [ [ 2, 14 ], [ 6, 18 ], [ 10, 22 ] ],
      [ [ 3, 15 ], [ 7, 19 ], [ 11, 23 ] ] ]
    }
  end

  test "transpose: shift forward ..." do
    assert { @a.transpose(1..-1,0) == NArray[
      [ [ 0, 4, 8 ], [ 12, 16, 20 ] ],
      [ [ 1, 5, 9 ], [ 13, 17, 21 ] ],
      [ [ 2, 6, 10 ], [ 14, 18, 22 ] ],
      [ [ 3, 7, 11 ], [ 15, 19, 23 ] ] ]
    }
  end

end
