require_relative "test_helper"

class MatrixTest < Test::Unit::TestCase

  $v1 = NVector[0.5,1.5]
  $v2 = NVector.float(2,2).indgen!

  test "matrix: creation" do
    m = NMatrix.float(3,3,3).indgen!
    assert { m == NArray[
      [ [ 0.0, 1.0, 2.0 ], [ 3.0, 4.0, 5.0 ], [ 6.0, 7.0, 8.0 ] ],
      [ [ 9.0, 10.0, 11.0 ], [ 12.0, 13.0, 14.0 ],[ 15.0, 16.0, 17.0 ] ],
      [ [ 18.0, 19.0, 20.0 ], [ 21.0, 22.0, 23.0 ], [ 24.0, 25.0, 26.0 ] ] ] }
  end

  test "matrix: index test" do
    m = NMatrix.float(3,3,3).indgen!
    assert { m[1,1,true] == NArray[ 4.0, 13.0, 22.0 ] }
  end

  test "matrix: index test2" do
    m = NMatrix.float(3,3,3).indgen!
    assert { m[0..1,2,true] == NArray[
      [ [ 6.0, 7.0 ] ],
      [ [ 15.0, 16.0 ] ],
      [ [ 24.0, 25.0 ] ] ]}
  end

  test "matrix: inverse " do
    m1 = NMatrix.float(2,2).indgen!
    assert { m1.inverse == NMatrix[ [ -1.5, 0.5 ], [ 1.0, 0.0 ] ] }
  end

  test "matrix: m1 + m2" do
    m1 = NMatrix.float(2,2).indgen!
    m2 = NMatrix[[0,1.2],[1.5,0]]
    assert { m1 + m2 = NMatrix[ [ 0.0, 2.2 ], [ 3.5, 3.0 ] ]}
  end

  test "matrix: $m1 * $m2 " do
    m1 = NMatrix.float(2,2).indgen!
    m2 = NMatrix[[0,1.2],[1.5,0]]
    assert { m1 * m2 == NMatrix[ [ 1.5, 0.0 ], [ 4.5, 2.4 ] ] }
  end

  test "matrix: $m2 * $m1 " do
    m1 = NMatrix.float(2,2).indgen!
    m2 = NMatrix[[0,1.2],[1.5,0]]
    assert { m2 * m1 = NMatrix[ [ 2.4, 3.6 ], [ 0.0, 1.5 ] ] }
  end

  test "matrix: 3.14 * m1" do
    m1 = NMatrix.float(2,2).indgen!
    assert { 3.14 * m1 == NMatrix[ [ 0.0, 3.14 ], [ 6.28, 9.42 ] ] }
  end

  test 'matrix: m2*1.25' do
    m2 = NMatrix[[0,1.2],[1.5,0]]
    assert { m2 * 1.25  == NMatrix[ [ 0.0, 1.5 ],[ 1.875, 0.0 ] ] }
  end

  test 'matrix: 1.25*v1' do
    v1 = NVector[0.5,1.5]
    assert { 1.25 * v1 == NVector[ 0.625, 1.875 ] }
  end

  test 'matrix: NMath.sqrt(v2**2)' do
    v2 = NVector.float(2,2).indgen!
    assert { NMath.sqrt(v2**2) == NVector[ 1.0, 3.605551275463989 ] }
  end

  test 'matrix: v1*v2' do
    v1 = NVector[0.5,1.5]
    v2 = NVector.float(2,2).indgen!
    assert { v1 * v2 == NVector[ 1.5, 5.5 ] }
  end

  test 'matrix: m1*v1' do
    m1 = NMatrix.float(2,2).indgen!
    v1 = NVector[0.5,1.5]
    assert { m1 * v1 == NVector[ 1.5, 5.5 ] }
  end

  test 'matrix: v2*m2' do
    v2 = NVector.float(2,2).indgen!
    m2 = NMatrix[[0,1.2],[1.5,0]]
    assert { v2 * m2 = NVector[ [ 1.5, 0.0 ], [ 4.5, 2.4 ] ] }
  end

  test 'matrix: m1.diagonal([98,99])' do
    m1 = NMatrix.float(2,2).indgen!
    assert { m1.diagonal([98,99]) == NMatrix[ [ 98.0, 1.0 ], [ 2.0, 99.0 ] ] }
  end

  test 'matrix: NMatrix.float(4,3).unit' do
    assert { NMatrix.float(4,3).unit == NMatrix[
      [ 1.0, 0.0, 0.0, 0.0 ],
      [ 0.0, 1.0, 0.0, 0.0 ],
      [ 0.0, 0.0, 1.0, 0.0 ] ] }
  end

  test "matrix: failed m1 + v1: raise" do
    m1 = NMatrix.float(2,2).indgen!
    v1 = NVector[0.5,1.5]
    assert_raise(TypeError){ m1 + v1 }
  end

  test "matrix: failed m1 + 1: raise" do
    m1 = NMatrix.float(2,2).indgen!
    assert_raise(TypeError){ m1 + 1 }
  end

  test "matrix: ratioral" do
    require 'rational'
    srand(1)
    m = NMatrix.object(5,5).collect{Rational(rand(10))}
    test = m/m
    assert { test == NMatrix[
      [ (1/1), (0/1), (0/1), (0/1), (0/1) ],
      [ (0/1), (1/1), (0/1), (0/1), (0/1) ],
      [ (0/1), (0/1), (1/1), (0/1), (0/1) ],
      [ (0/1), (0/1), (0/1), (1/1), (0/1) ],
      [ (0/1), (0/1), (0/1), (0/1), (1/1) ] ]
    }
  end

end
