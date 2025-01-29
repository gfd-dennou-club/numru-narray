require_relative "test_helper"

class SortTest < Test::Unit::TestCase

  test "sort: int" do
    a = NArray.int(16).random!(100).sort
    assert_block do
      for i in 0..14 do
        a[i] <= a[i+1]
      end
    end
  end

  test "sort: as string" do
    a = NArray.int(16).random!(100).to_string.sort
    assert_block do
      for i in 0..14 do
        a[i] <= a[i+1]
      end
    end
  end

  test "sort: up to 0-rank" do
    a = NArray.int(4,4).random!(100).sort(0)
    assert_block do
      for i in 0..14 do
        a[i] <= a[i+1]
      end
    end
  end

  test "sort: big array test" do
    a = NArray.int(10,10,10,10,10).random!(100).sort(1)
    assert_block do
      for i in 0..99998 do
        a[i] <= a[i+1]
      end
    end
  end

  test "sort: index" do
    a = NArray.int(7,4).random!(100)
    idx = a.sort_index(0)
    a = a[idx]
    assert_block do
      for i in 0..26 do
        a[i] <= a[i+1]
      end
    end
  end

  test "sort: failed test" do
    a = NArray.complex(3,3).random!(100)
    assert_raise(TypeError) { a.sort }
  end


end
