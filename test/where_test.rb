require_relative "test_helper"

class ComplexTest < Test::Unit::TestCase

  def setup
    @a = NArray.float(8).indgen!
  end

  test "where: t,f = ( (a >= 5).or(a < 2) ).where2 " do
    t,f = ( (@a >= 5).or(@a < 2) ).where2
    assert { t == NArray[ 0, 1, 5, 6, 7 ] }
    assert { f == NArray[ 2, 3, 4 ] }
  end

  test "where: t,f = ( (a >= 5).and(a < 2) ).where2 " do
    t,f = ( (@a >= 5).and(@a < 2) ).where2
    assert { t == NArray[] }
    assert { f == NArray[ 0, 1, 2, 3, 4, 5, 6, 7 ] }
  end

  test "where: vvv no-meaning !! vvv" do
    t,f = ( (@a >= 5) && ( @a < 2) ).where2
    assert { t == NArray[ 0, 1 ] }
    assert { f == NArray[ 2, 3, 4, 5, 6, 7 ] }
  end

  test "t,f = ( (a>=5) || (a<2) ).where2" do
    t,f = ( (@a >= 5) || (@a < 2) ).where2
    assert { t == NArray[ 5, 6, 7 ] }
    assert { f == NArray[ 0, 1, 2, 3, 4 ] }
  end

end
