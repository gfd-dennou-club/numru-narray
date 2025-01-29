require_relative "test_helper"
require 'rational'

class ObjectTest < Test::Unit::TestCase
  def setup
    @a = NArray.object(4,4).fill!(Rational(1))
    @b = NArray.object(4,4).indgen!(1).collect{|i| Rational(i)}
  end

  test "object: a+b" do
    assert{ @a + @b == NArray[
      [ 2/1, 2/1, 2/1, 2/1 ],
      [ 2/1, 2/1, 2/1, 2/1 ],
      [ 2/1, 2/1, 2/1, 2/1 ],
      [ 2/1, 2/1, 2/1, 2/1 ] ] }
  end

  test "object: a/b" do
    assert{ @a/@b == NArray[
      [ 1/1, 1/1, 1/1, 1/1 ],
      [ 1/1, 1/1, 1/1, 1/1 ],
      [ 1/1, 1/1, 1/1, 1/1 ],
      [ 1/1, 1/1, 1/1, 1/1 ] ] }
  end

  test "object: a/b - b" do
    assert{ @a/@b - @b == NArray[
      [ 0/1, 0/1, 0/1, 0/1 ],
      [ 0/1, 0/1, 0/1, 0/1 ],
      [ 0/1, 0/1, 0/1, 0/1 ],
      [ 0/1, 0/1, 0/1, 0/1 ] ] }
  end

end
