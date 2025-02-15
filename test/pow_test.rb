require_relative "test_helper"

class PowTest < Test::Unit::TestCase
  def setup
    @a = NArray.int(4).indgen!*2-2
    @b = NArray.float(4).indgen!*2-2
    # @c = NArray.complex(4).indgen!*2-2
    @inf = 1.0/0.0
    # @nan = 0.0/0.0
  end

  test "pow: int" do
    assert{ @a**[[-3],[0],[7]] == NArray[
      [ 0, 0, 0, 0 ],
      [ 1, 1, 1, 1 ],
      [ -128, 0, 128, 16384 ] ] }
    assert{ @a**[[-3.0],[0],[7.0]] == NArray[
      [ -0.125, @inf, 0.125, 0.015625 ],
      [ 1.0, 1.0, 1.0, 1.0 ],
      [ -128.0, 0.0, 128.0, 16384.0 ] ] }
    assert{ @a**Complex(1,0) == NArray[ -2.0+2.4492935982947064e-16i, 0.0+0.0i, 2.0+0.0i, 4.0+0.0i ] }
    assert{ @a**1.0 == NArray[ -2.0, 0.0, 2.0, 4.0 ] }
  end

  test "pow: float" do
    assert{ @b**[[-3],[0],[7]] == NArray[
      [ -0.125, @inf, 0.125, 0.015625 ],
      [ 1.0, 1.0, 1.0, 1.0 ],
      [ -128.0, 0.0, 128.0, 16384.0 ] ] }
    assert{ @b**[[-3.0],[0],[7.0]] == NArray[
      [ -0.125, @inf, 0.125, 0.015625 ],
      [ 1.0, 1.0, 1.0, 1.0 ],
      [ -128.0, 0.0, 128.0, 16384.0 ] ] }
    assert{ @b**Complex(1,0) == NArray[ -2.0+2.4492935982947064e-16i, 0.0+0.0i, 2.0+0.0i, 4.0+0.0i ] }
    assert{ @b**1.0 == NArray[ -2.0, 0.0, 2.0, 4.0 ] }
  end

  test "pow: complex" do
    # -nam-nani をどう表現するか?
    # assert{ @c**[[-3],[0],[7]] == NArray[
    #   [ -0.125-0.0i, -nan-nani, 0.125-0.0i, 0.015625-0.0i ],
    #   [ 1.0+0.0i, 1.0+0.0i, 1.0+0.0i, 1.0+0.0i ],
    #   [ -128.0+0.0i, 0.0+0.0i, 128.0+0.0i, 16384.0+0.0i ] ] }
    # assert{ @c**[[-3.0],[0],[7.0]] == NArray[
    #   [ -0.125-0.0i, -nan-0.0i/0.0, 0.125-0.0i, 0.015625-0.0i ],
    #   [ 1.0+0.0i, 1.0+0.0i, 1.0+0.0i, 1.0+0.0i ],
    #   [ -128.0+0.0i, 0.0+0.0i, 128.0+0.0i, 16384.0+0.0i ] ] }
    # assert{ @c**Complex(1,0) == NArray[ -2.0+2.4492935982947064e-16i, 0.0+0.0i, 2.0+0.0i, 4.0+0.0i ] }
    # assert{ @c**1.0 == NArray[ -2.0, 0.0, 2.0, 4.0 ] }
  end

end
