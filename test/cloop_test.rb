require_relative "test_helper"
require "numru/narray_cloop"
NArrayCLoop.header_path = File.expand_path(File.dirname(__FILE__)) + "/../lib/numru/narray"
class TestCLoop < Test::Unit::TestCase

  N = 10
  M = 100

  def setup
    @x = NArray.lint(N,M).indgen
    @y = NArray.lint(N,M).indgen(1)
  end

  def test_arithmetic_array
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          z[i,j] = ( x[i,j] - y[i,j] ) * x[i,j]
        end
      end
    end
    zr = ( @x - @y ) * @x
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

  def test_multi_line
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          z[i,j] = ( x[i,j] - y[i,j] ) / (y[i,j] + 1) \
                 - ( x[i,j] + y[i,j] ) * x[i,j] \
                 + ( x[i,j] * y[i,j] )
        end
      end
    end
    zr = ( @x - @y ) / ( @y + 1 ) - ( @x + @y ) * @x + ( @x * @y )
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
        z2[j] = x[0,j]
        c_loop(1,N-1) do |i|
          z1[i,j] = z2[j] + x[i-1,j] + y[i,j]
        end
        z2[j] = x[1,j] + y[0,j]
      end
    end
    z1r = NArray.lint(N,M)
    z2r = NArray.lint(M)
    z1r[1..N-1,0..M-1] = @x[0..0,0..M-1] + @x[0..N-2,0..M-1] + @y[1..N-1,0..M-1]
    z2r[0..M-1] = @x[1,0..M-1] + @y[0,0..M-1]
    assert_equal(z1r, z1)
    assert_equal(z2r, z2)
  end

  def test_negative_index
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          ii = N-1 - i
          z[ii,j] = x[ii,j] + y[i,j]
        end
      end
    end
    zr = NArray.lint(N,M)
    zr[-1..0,true] = @x[-1..0,true] + @y[true,true]
    assert_equal(zr, z)
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

  def test_if_break
    z = NArray.lint(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          c_if( i > 2 ) do
            c_break
          end
          z[i,j] = x[i,j] + y[i,j]
        end
      end
    end
    zr = NArray.lint(N,M)
    zr[0..2,true] = @x[0..2,true] + @y[0..2,true]
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
          z[i,j] = exp(x[i,j]) + atan2(x[i,j], y[i,j])
        end
      end
    end
    zr = NMath.exp(@x.to_type(NArray::DFLOAT)) + NMath.atan2(@x.to_type(NArray::DFLOAT),@y.to_type(NArray::DFLOAT))
    assert_equal(zr, z)
  end

  def test_array_index
    z = NArray.lint(N,M)
    i_idx = NArray.sint(N).random(N)
    j_idx = NArray.sint(M).random(M)
    NArrayCLoop.kernel(@x,@y,i_idx,j_idx,z) do |x,y,i_idx,j_idx,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          z[i,j] = x[i,j] + y[i_idx[i],j_idx[j]]
        end
      end
    end
    zr = @x + @y[i_idx,j_idx]
    assert_equal(zr, z)
  end

  def test_array_loop_range
    z = NArray.lint(M)
    idx = NArray.sint(M,2).random(N)
    min = idx.min(1)
    max = idx.max(1)
    NArrayCLoop.kernel(@x,min,max,z) do |x,min,max,z|
      c_loop(0,M-1) do |j|
        z[j] = 0.0
        c_loop(min[j],max[j]) do |i|
          z[j] = z[j] + x[i,j]
        end
      end
    end
    zr = NArray.lint(M)
    for j in 0..M-1
      zr[j] = 0.0
      for i in min[j]..max[j]
        zr[j] = zr[j] + @x[i,j]
      end
    end
    assert_equal(zr, z)
  end

  def test_scalar
    z = NArray.sfloat(M)
    assert_raise(RuntimeError) do
      NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
        c_loop(0,M-1) do |j|
          r = c_scalar("float", 0.0)
          c_loop(0,N-1) do |i|
            p = x[i,j] - y[i,j]
            q = c_float( x[i,j] + y[i,j] + 1 )
            r = r + p / q
          end
          z[j] = r
        end
      end
    end
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        r = c_scalar("float")
        r.assign 0.0
        c_loop(0,N-1) do |i|
          p = x[i,j] - y[i,j]
          q = c_float( x[i,j] + y[i,j] + 1 )
          r.assign r + p / q
        end
        z[j] = r
      end
    end
    p = @x - @y
    q = ( @x + @y + 1 ).to_type(NArray::SFLOAT)
    r = p / q
    zr = r.sum(0)
    assert_equal(zr, z)
  end

  def test_scalar_math
    z = NArray.sfloat(N,M)
    NArrayCLoop.kernel(@x,@y,z) do |x,y,z|
      c_loop(0,M-1) do |j|
        c_loop(0,N-1) do |i|
          p = x[i,j] - y[i,j]
          q = abs( p )
          z[i,j] = q
        end
      end
    end
    zr = (@x - @y).abs
    assert_equal(zr, z)
  end

  def test_scalar_loop_range
    z = NArray.sint(M)
    min = NArray.sint(1)
    assert_raise(RuntimeError) do
      NArrayCLoop.kernel(@x,@y,min,z) do |x,y,min,z|
        c_loop(0,M-1) do |j|
          imax = c_int(0)
          c_if ( x[0,j] < N ) do
            imax = x[0,j]
          end
          c_loop(min[0],imax) do |i|
            z[j] = z[j] + y[i,j]
          end
        end
      end
    end
    NArrayCLoop.kernel(@x,@y,min,z) do |x,y,min,z|
      c_loop(0,M-1) do |j|
        imax = c_int(0)
        c_if ( x[0,j] < N ) do
          imax.assign x[0,j]
        end
        r = c_int(0)
        c_loop(min[0],imax) do |i|
          r.assign r + y[i,j]
        end
        z[j] = r
      end
    end

    zr = NArray.sint(M)
    for j in 0..M-1
      imax = 0
      if @x[0,j] < N
        imax = @x[0,j]
      end
      r = 0
      for i in 0..imax
        r = r + @y[i,j]
      end
      zr[j] = r
    end
    assert_equal(zr, z)
  end

end
