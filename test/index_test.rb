require_relative 'test_helper'
class IndexTest < Test::Unit::TestCase
  def setup
    @a = NArray.float(3,3).indgen!
  end

  test "index: a" do
    assert { @a == NArray[
      [ 0.0, 1.0, 2.0 ],
      [ 3.0, 4.0, 5.0 ],
      [ 6.0, 7.0, 8.0 ]]
    }
  end

  test "index: a[1, -1]" do
    assert { @a[1, -1] == 7.0 }
  end

  test "index: a[1, 2..0]" do
    assert { @a[1, 2..0] == NArray[ 7.0, 4.0, 1.0 ] }
  end

  test "index: a[1...2, 0..1]" do
    assert { @a[1...2, 0..1] == NArray[ [ 1.0 ], [ 4.0 ] ] }
  end

  test "index: a[true, 0..1]" do
    assert { @a[true, 0..1] == NArray[
      [ 0.0, 1.0, 2.0 ],
      [ 3.0, 4.0, 5.0 ] ] }
  end

  test "index: a[0..5]" do
    assert { @a[0..5] == NArray[ 0.0, 1.0, 2.0, 3.0, 4.0, 5.0 ] }
  end

end
