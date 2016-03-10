require "test/unit"
require "numru/narray_cloop"
include NumRu

NumRu::NArrayCLoop.header_path = File.expand_path(File.dirname(__FILE__)) + "/../ext/numru/narray"

#NumRu::NArrayCLoop.verbose = true

class TestCLoop < Test::Unit::TestCase

  N = 10
  M = 100

  def setup
    @x = NArray.lint(N,M).indgen
    @y = NArray.lint(N,M).indgen(1)
  end

  def test_add_lint
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          z[i,j] = x[i,j] + y[i,j]
        end
      end
    end
    zr = @x + @y
    assert_equal(zr, z)
  end

  def test_sub_lint
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          z[i,j] = x[i,j] - y[i,j]
        end
      end
    end
    zr = @x - @y
    assert_equal(zr, z)
  end

  def test_mul_lint
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          z[i,j] = x[i,j] * y[i,j]
        end
      end
    end
    zr = @x * @y
    assert_equal(zr, z)
  end

  def test_div_lint
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          z[i,j] = x[i,j] / y[i,j]
        end
      end
    end
    zr = @x / @y
    assert_equal(zr, z)
  end

  def test_arithmetic_numeric
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,z) do |x,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          z[i,j] = ( ( x[i,j] + 1 ) * 2 - 3 ) / 4
        end
      end
    end
    zr = ( ( @x + 1 ) * 2 - 3 ) / 4
    assert_equal(zr, z)
  end

  def test_arithmetic_ary
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          z[i,j] = ( ( x[i,j] + y[i,j] ) * x[i,j] - y[i,j] ) / y[i,j]
        end
      end
    end
    zr = ( ( @x + @y ) * @x - @y ) / @y
    assert_equal(zr, z)
  end

  def test_cast
    z = NArray.sfloat(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          z[i,j] = ( x[i,j] + 1.0 ) * y[i,j]
        end
      end
    end
    zr = ( @x.to_type(NArray::SFLOAT) + 1.0 ) * @y
    assert_equal(zr, z)
  end

  def test_subrange
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-2) do |j|
        c_loop(1,N-1) do |i|
          z[i,j] = x[i,j] + y[i,j]
        end
      end
    end
    zr = NArray.lint(N,M)
    zr[1..N-1,0..M-2] = @x[1..N-1,0..M-2] + @y[1..N-1,0..M-2]
    assert_equal(zr, z)
  end

  def test_shift
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-2) do |j|
        c_loop(1,N-1) do |i|
          z[i,j] = x[i-1,j] + y[i,j+1]
        end
      end
    end
    zr = NArray.lint(N,M)
    zr[1..N-1,0..M-2] = @x[0..N-2,0..M-2] + @y[1..N-1,1..M-1]
    assert_equal(zr, z)
  end

  def test_multiple_loop
    z1 = NArray.lint(N,M)
    z2 = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z1,z2) do |x,y,z1,z2|
      c_loop(0,M-1) do |j|
        c_loop(1,N-1) do |i|
          z1[i,j] = x[i-1,j] + y[i,j]
        end
        c_loop(0,N-2) do |i|
          z2[i,j] = x[i+1,j] + y[i,j]
        end
      end
    end
    z1r = NArray.lint(N,M)
    z2r = NArray.lint(N,M)
    z1r[1..N-1,0..M-1] = @x[0..N-2,0..M-1] + @y[1..N-1,0..M-1]
    z2r[0..N-2,0..M-1] = @x[1..N-1,0..M-1] + @y[0..N-2,0..M-1]
    assert_equal(z1r, z1)
    assert_equal(z2r, z2)
  end

  def test_multiple_loop2
    z1 = NArray.lint(N,M)
    z2 = NArray.lint(M)
    NArrayCLoop.kernel(@x,@y,z1,z2) do |x,y,z1,z2|
      c_loop(0,M-1) do |j|
        c_loop(1,N-1) do |i|
          z1[i,j] = x[i-1,j] + y[i,j]
        end
        z2[j] = x[1,j] + y[0,j]
      end
    end
    z1r = NArray.lint(N,M)
    z2r = NArray.lint(M)
    z1r[1..N-1,0..M-1] = @x[0..N-2,0..M-1] + @y[1..N-1,0..M-1]
    z2r[0..M-1] = @x[1,0..M-1] + @y[0,0..M-1]
    assert_equal(z1r, z1)
    assert_equal(z2r, z2)
  end

  def test_openmp
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1,openmp=true) do |j|
        c_loop(0,N-1) do |i|
          z[i,j] = x[i,j] + y[i,j]
        end
      end
    end
    zr = @x + @y
    assert_equal(zr, z)
  end

  def test_boundary_exceed
    z1 = NArray.lint(N,M)
    assert_raise(ArgumentError) do
      NArrayCLoop.kernel(@x,@y,z1) do |x,y,z1|
        c_loop(0,M-1) do |j|
          c_loop(0,N-1) do |i|
            z1[i,j] = x[0,j] + y[i+1,j] # exceed boundary
          end
        end
      end
    end
  end

  def test_if_element
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          c_if( x[i,j] > 500 ) do
            z[i,j] = x[i,j] + y[i,j]
          end
        end
      end
    end
    mask = @x.gt(500)
    zr = NArray.lint(N,M)
    zr[mask] = @x[mask] + @y[mask]
    assert_equal(zr, z)
  end

  def test_if_element_add
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          c_if( x[i,j] + y[i,j] >= 1000 ) do
            z[i,j] = x[i,j] + y[i,j]
          end
        end
      end
    end
    mask = (@x+@y).ge(1000)
    zr = NArray.lint(N,M)
    zr[mask] = @x[mask] + @y[mask]
    assert_equal(zr, z)
  end

  def test_if_index
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          c_if( j < 50 ) do
            z[i,j] = x[i,j] + y[i,j]
          end
        end
      end
    end
    zr = NArray.lint(N,M)
    zr[true,0...50] = @x[true,0...50] + @y[true,0...50]
    assert_equal(zr, z)
  end

  def test_if_and
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          c_if( (j < 50).and(x[i,j] < 100) ) do
            z[i,j] = x[i,j] + y[i,j]
          end
        end
      end
    end
    zr = NArray.lint(N,M)
    idx = 0...50
    mask = @x[true,idx].lt(100)
    zrs = NArray.lint(N,50)
    zrs[mask] = @x[true,idx][mask] + @y[true,idx][mask]
    zr[true,idx] = zrs
    assert_equal(zr, z)
  end

  def test_if_else
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          c_if( j < 50 ) do
            z[i,j] = x[i,j] + y[i,j]
          end.elseif( j < 70 ) do
            z[i,j] = x[i,j] - y[i,j]
          end.elseif( i < 5 ) do
            z[i,j] = 10
          end.else do
            z[i,j] = 100
          end
        end
      end
    end
    zr = NArray.lint(N,M)
    j_idx0 = 0...50
    j_idx1 = 50...70
    j_idx2 = 70..-1
    i_idx0 = 0...5
    i_idx1 = 5..-1
    zr[true,j_idx0] = @x[true,j_idx0] + @y[true,j_idx0]
    zr[true,j_idx1] = @x[true,j_idx1] - @y[true,j_idx1]
    zr[i_idx0,j_idx2] = 10
    zr[i_idx1,j_idx2] = 100
    assert_equal(zr, z)
  end

  def test_abs
    z = NArray.llint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          z[i,j] = abs(x[i,j]) + llabs(-y[i,j])
        end
      end
    end
    zr = @x.abs + (-@y.to_type(NArray::LLINT)).abs
    assert_equal(zr, z)
  end

  def test_math
    z = NArray.dfloat(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          z[i,j] = exp(x[i,j]) + atan2f(x[i,j], y[i,j])
        end
      end
    end
    zr = NMath.exp(@x.to_type(NArray::DFLOAT)) + NMath.atan2(@x.to_type(NArray::SFLOAT),@y.to_type(NArray::SFLOAT))
    assert_equal(zr, z)
  end

end

