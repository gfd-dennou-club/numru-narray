require_relative "test_helper"

class IndexSetTest < Test::Unit::TestCase
  def setup
    @a = NArray.float(3,3).indgen!
  end

  test "index set: a[[]] = a" do
    @a[[]] == []
    assert { @a == NArray.float(3,3).indgen! }
  end

  test "index set: 1-element replace" do
    @a[1,1] = 0
    assert { @a == NArray[
      [ 0.0, 1.0, 2.0 ],
      [ 3.0, 0.0, 5.0 ],
      [ 6.0, 7.0, 8.0 ]
      ]
    }
  end

  test "index set: Range replace" do
    @a[0..-1,1] = 0
    assert { @a == NArray[
      [ 0.0, 1.0, 2.0 ],
      [ 0.0, 0.0, 0.0 ],
      [ 6.0, 7.0, 8.0 ]
      ]
    }
  end

  test "index set: Array replace" do
    @a[1,2..0] = [100, 101, 102]
    assert { @a == NArray[[ 0.0, 102.0, 2.0 ], [ 3.0, 101.0, 5.0 ], [ 6.0, 100.0, 8.0 ]] }
  end

  test "index set: Specifing Starting point a[0,1]" do
    @a[0,1] =  [100,101,102]
    assert { @a = NArray[
      [ 0.0, 1.0, 2.0 ],
      [ 100.0, 101.0, 102.0 ],
      [ 6.0, 7.0, 8.0 ] ]
    }
  end

  test "index set: Specifing Starting point a[1,0]" do
    @a[1,0] = [[100],[101],[102]]
    assert { @a = NArray[
      [ 0.0, 100.0, 2.0 ],
      [ 3.0, 101.0, 5.0 ],
      [ 6.0, 102.0, 8.0 ] ]
    }
  end

  test "index set: `true' means entire range" do
    @a[true,1] = [100,101,102]
    assert { @a == NArray[
      [ 0.0, 1.0, 2.0 ],
      [ 100.0, 101.0, 102.0 ],
      [ 6.0, 7.0, 8.0 ] ]
    }
  end

  test "index set: a[true, true]" do
    @a[true,true] = [[100,101,102]]
    assert { @a == NArray[
      [ 100.0, 101.0, 102.0 ],
      [ 100.0, 101.0, 102.0 ],
      [ 100.0, 101.0, 102.0 ] ]
    }
  end

  test "index set: failed a[true,1] = [[100, 101, 102]]" do
    assert_raise (IndexError) { @a[true, 1] = [[100,101,102]] }
  end

  test "index set: failed a[true,1] = [[100], [101], [102]]" do
    assert_raise (IndexError) { @a[true, 1] = [[100],[101],[102]] }
  end

  test "index set: failed a[true,true] = [100, 101, 102]" do
    assert_raise (IndexError) { @a[true, true] = [100, 101, 102] }
  end

  test "index set: failed a[1,0] = [100, 101, 102]" do
    assert_raise (IndexError) { @a[1,0] = [100, 101, 102] }
  end

end
