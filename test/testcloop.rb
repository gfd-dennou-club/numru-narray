require "test/unit"
require "numru/narray_cloop"
include NumRu

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
      cloop(0,M-1) do |j|
        cloop(0,N-1) do |i|
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
      cloop(0,M-1) do |j|
        cloop(0,N-1) do |i|
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
      cloop(0,M-1) do |j|
        cloop(0,N-1) do |i|
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
      cloop(0,M-1) do |j|
        cloop(0,N-1) do |i|
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
      cloop(0,M-1) do |j|
        cloop(0,N-1) do |i|
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
      cloop(0,M-1) do |j|
        cloop(0,N-1) do |i|
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
      cloop(0,M-1) do |j|
        cloop(0,N-1) do |i|
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
      cloop(0,M-2) do |j|
        cloop(1,N-1) do |i|
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
      cloop(0,M-2) do |j|
        cloop(1,N-1) do |i|
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
      cloop(0,M-1) do |j|
        cloop(1,N-1) do |i|
          z1[i,j] = x[i-1,j] + y[i,j]
        end
        cloop(0,N-2) do |i|
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
      cloop(0,M-1) do |j|
        cloop(1,N-1) do |i|
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
      cloop(0,M-1,openmp=true) do |j|
        cloop(0,N-1) do |i|
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
        cloop(0,M-1) do |j|
          cloop(0,N-1) do |i|
            z1[i,j] = x[0,j] + y[i+1,j] # exceed boundary
          end
        end
      end
    end
  end

end

