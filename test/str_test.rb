require_relative "test_helper"

class StringTest < Test::Unit::TestCase

  test "string: NArray.float to string" do
    assert { NArray.float(3,3).indgen!.to_string == NArray[
      [ "0", "1", "2" ],
      [ "3", "4", "5" ],
      [ "6", "7", "8" ]
      ]
    }
  end

  test "string: NArray.complex to string" do
    assert { NArray.complex(3,3).indgen!.div!(3).to_string == NArray[
      [ "0+0i", "0.33333333+0i", "0.66666667+0i" ],
      [ "1+0i", "1.3333333+0i", "1.6666667+0i" ],
      [ "2+0i", "2.3333333+0i", "2.6666667+0i" ]
      ]
    }
  end

  test "string: NArray.scomplex to string" do
    assert { NArray.scomplex(3,3).indgen!.div!(3).to_string == NArray[
      [ "0+0i", "0.33333+0i", "0.66667+0i" ],
      [ "1+0i", "1.3333+0i", "1.6667+0i" ],
      [ "2+0i", "2.3333+0i", "2.6667+0i" ]
      ]
    }
  end

  test "string: NArray.byte to string" do
    assert { NArray.byte(3,3).indgen!.add!(32).to_string == NArray[ " !\"", "\#$%", "&'(" ] }
  end

  test "string: NArray.sfloat to string twice" do
    assert { NArray.sfloat(3,3).indgen!.to_string.to_string == NArray[
      [ "0", "1", "2" ],
      [ "3", "4", "5" ],
      [ "6", "7", "8" ]
      ]
    }
  end

end
