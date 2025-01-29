require_relative "test_helper"

class ReverseTest < Test::Unit::TestCase

  test "reverse: 3x3" do
    a = NArray.int(3,3).indgen!
    assert { a.reverse == NArray[
      [ 8, 7, 6 ],
      [ 5, 4, 3 ],
      [ 2, 1, 0 ] ] }
    assert { a.reverse(0) == NArray[
      [ 2, 1, 0 ],
      [ 5, 4, 3 ],
      [ 8, 7, 6 ] ] }
    assert { a.reverse(1) == NArray[
      [ 6, 7, 8 ],
      [ 3, 4, 5 ],
      [ 0, 1, 2 ] ] }
    assert { a.rot90 == NArray[
      [ 6, 3, 0 ],
      [ 7, 4, 1 ],
      [ 8, 5, 2 ] ] }
    assert { a.rot90(2) == NArray[
      [ 8, 7, 6 ],
      [ 5, 4, 3 ],
      [ 2, 1, 0 ] ] }
    assert { a.rot90(-1) == NArray[
      [ 2, 5, 8 ],
      [ 1, 4, 7 ],
      [ 0, 3, 6 ] ] }
  end

  test "reverse: 3x3x3" do
    a = NArray.int(3,3,3).indgen!
    assert{ a.reverse == NArray[
      [ [ 26, 25, 24 ],
        [ 23, 22, 21 ],
        [ 20, 19, 18 ] ],
      [ [ 17, 16, 15 ],
        [ 14, 13, 12 ],
        [ 11, 10, 9 ] ],
      [ [ 8, 7, 6 ],
        [ 5, 4, 3 ],
        [ 2, 1, 0 ] ] ] }
    assert{ a.reverse(0) == NArray[
      [ [ 2, 1, 0 ],
        [ 5, 4, 3 ],
        [ 8, 7, 6 ] ],
      [ [ 11, 10, 9 ],
        [ 14, 13, 12 ],
        [ 17, 16, 15 ] ],
      [ [ 20, 19, 18 ],
        [ 23, 22, 21 ],
        [ 26, 25, 24 ] ] ] }
    assert{ a.reverse(1) == NArray[
      [ [ 6, 7, 8 ],
        [ 3, 4, 5 ],
        [ 0, 1, 2 ] ],
      [ [ 15, 16, 17 ],
        [ 12, 13, 14 ],
        [ 9, 10, 11 ] ],
      [ [ 24, 25, 26 ],
        [ 21, 22, 23 ],
        [ 18, 19, 20 ] ] ] }
    assert{ a.rot90 == NArray[
      [ [ 6, 3, 0 ],
        [ 7, 4, 1 ],
        [ 8, 5, 2 ] ],
      [ [ 15, 12, 9 ],
        [ 16, 13, 10 ],
        [ 17, 14, 11 ] ],
      [ [ 24, 21, 18 ],
        [ 25, 22, 19 ],
        [ 26, 23, 20 ] ] ] }
    assert{ a.rot90(2) == NArray[
      [ [ 8, 7, 6 ],
        [ 5, 4, 3 ],
        [ 2, 1, 0 ] ],
      [ [ 17, 16, 15 ],
        [ 14, 13, 12 ],
        [ 11, 10, 9 ] ],
      [ [ 26, 25, 24 ],
        [ 23, 22, 21 ],
        [ 20, 19, 18 ] ] ] }
    assert{ a.rot90(-1) == NArray[
      [ [ 2, 5, 8 ],
        [ 1, 4, 7 ],
        [ 0, 3, 6 ] ],
      [ [ 11, 14, 17 ],
        [ 10, 13, 16 ],
        [ 9, 12, 15 ] ],
      [ [ 20, 23, 26 ],
        [ 19, 22, 25 ],
        [ 18, 21, 24 ] ] ] }
  end

  test "reverse: 3" do
    a = NArray.int(3).indgen!
    assert { a.reverse == NArray[ 2, 1, 0 ] }
    assert { a.reverse(0) == NArray[ 2, 1, 0 ] }
    assert_raise(RuntimeError) { a.rot90  }
    assert_raise(RuntimeError) { a.rot90(-1)  }
  end

end
