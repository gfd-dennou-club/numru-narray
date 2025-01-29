require_relative "test_helper"

class IndexArrayTest < Test::Unit::TestCase
  def setup
    @a = NArray.new(NArray::DFLOAT,5,5).indgen!
    @idx = [2,0,1]
  end

  test "IndexArray: a[idx,idx]" do
    assert { @a[@idx,@idx] == NArray[
      [ 12.0, 10.0, 11.0 ],
      [ 2.0, 0.0, 1.0 ],
      [ 7.0, 5.0, 6.0 ] ] }
  end

  test "IndexArray: Narray.to_na(idx), idx += 10" do
    idx = NArray.to_na(@idx)
    idx += 10
    assert{ idx = NArray[ 12, 10, 11 ] }
  end

  test "IndexArray: a[1,[]]" do
    assert{ @a[1,[]] = NArray[ ] }
  end

  test "IndexArray: Failed a[idx,0]" do
    idx = NArray[ 12, 10, 11 ]
    assert_raise(IndexError) { @a[idx, 0] }
  end
end
