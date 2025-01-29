require_relative "test_helper"

class MaskTest < Test::Unit::TestCase

  test "mask: byte" do
    a = NArray.byte(10)
    a[2..4] = 1
    assert { a.class == NumRu::NArray }
    assert { a.count_true == 3 }
    assert { a.count_false == 7 }
  end

  test "mask: cannot count_true NArray except BYTE type" do
    a = NArray.float(10)
    a[2..4] = 1
    assert { a.class == NumRu::NArray }
    assert_raise(TypeError) { a.count_true }
    assert_raise(TypeError) { a.count_false }
  end

  test "mask: float" do
    a = NArray.float(5,3).indgen!
    b = (a-2)*2
    c = a.lt(b)
    assert { c.typecode == 1 }
    assert { a.mask(c) == NArray[ 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0 ] }
    assert { a[c] == NArray[ 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0 ] }
    a[c] = 10000
    assert { a == NArray[
      [ 0.0, 1.0, 2.0, 3.0, 4.0 ],
      [ 10000.0, 10000.0, 10000.0, 10000.0, 10000.0 ],
      [ 10000.0, 10000.0, 10000.0, 10000.0, 10000.0 ] ]
    }
  end

  test "mask: complex" do
    a = NArray.complex(5).indgen! + Complex::I
    m = NArray.byte(5)
    m[true] = [0,0,1,1,0]
    assert { a[m] == NArray[ 2.0+1.0i, 3.0+1.0i ] }
    a[m] = 100.0
    assert { a == NArray[ 0.0+1.0i, 1.0+1.0i, 100.0+0.0i, 100.0+0.0i, 4.0+1.0i ] }
  end
end
