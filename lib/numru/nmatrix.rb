#  Numerical Array Extention for Ruby
#    (C) Copyright 2000-2003 by Masahiro TANAKA
#

#
# ------ NMatrix ------
#
class NumRu::NMatrix < NumRu::NArray
  CLASS_DIMENSION = 2

  def +(other)
    case other
    when NumRu::NMatrix
      return super(NumRu::NArray.refer(other))
    when NumRu::NArray
      unless other.instance_of?(NumRu::NArray)
        return other.coerce_rev( self, :+ )
      end
    end
    raise TypeError,"Illegal operation: NumRu::NMatrix + %s" % other.class
  end

  def -(other)
    case other
    when NumRu::NMatrix
      return super(NumRu::NArray.refer(other))
    when NumRu::NArray
      unless other.instance_of?(NumRu::NArray)
        return other.coerce_rev( self, :- )
      end
    end
    raise TypeError,"Illegal operation: NumRu::NMatrix - %s" % other.class
  end

  def *(other)
    case other
    when NumRu::NMatrix
      NumRu::NMatrix.mul_add( NumRu::NArray.refer(self).newdim!(0),other.newdim(2), 1 )
      #NumRu::NMatrix.mul_add( NumRu::NArray.refer(self).newdim!(0),
      #		       other.transpose(1,0).newdim!(2), 0 )
    when NumRu::NVector
      NumRu::NVector.mul_add( NumRu::NArray.refer(self), other.newdim(1), 0 )
    when NumRu::NArray
      if other.instance_of?(NumRu::NArray)
	NumRu::NMatrix.mul( NumRu::NArray.refer(self), other.newdim(0,0) )
      else
	other.coerce_rev( self, :* )
      end
    when Numeric
      super
      #NumRu::NMatrix.mul( NumRu::NArray.refer(self), other )
    when Array
      NumRu::NMatrix.mul( self, NumRu::NArray[*other].newdim!(0,0) )
    else
      raise TypeError,"Illegal operation: NumRu::NMatrix * %s" % other.class
    end
  end

  def /(other)
    case other
    when NumRu::NMatrix
      other.lu.solve(self)
    when NumRu::NVector
      raise TypeError,"Illegal operation: NumRu::NMatrix / %s" % other.class
    when NumRu::NArray
      if other.instance_of?(NumRu::NArray)
	NumRu::NMatrix.div( NumRu::NArray.refer(self), other.newdim(0,0) )
      else
	other.coerce_rev( self, :/ )
      end
    when Numeric
      NumRu::NMatrix.div( NumRu::NArray.refer(self), other )
    when Array
      NumRu::NMatrix.div( self, NumRu::NArray[*other].newdim!(0,0) )
    else
      raise TypeError,"Illegal operation: NumRu::NMatrix / %s" % other.class
    end
  end

  def **(n)
    case n
    when Integer
      if n==0
	return 1.0
      elsif n<0
	m = self.inverse
	n = -n
      else
	m = self
      end
      (2..n).each{ m *= self }
      m
    else
      raise TypeError,"Illegal operation: NumRu::NMatrix ** %s" % other.class
    end
  end

  def coerce_rev(other,id)
    case id
    when :*
	if other.instance_of?(NumRu::NArray)
	  return NumRu::NMatrix.mul( other.newdim(0,0), self )
	end
	if other.instance_of?(NumRu::NArrayScalar)
	  return NumRu::NMatrix.mul( other.newdim(0), self )
	end
    when :/
	if other.instance_of?(NumRu::NArray)
	  return NumRu::NMatrix.mul( other.newdim(0,0), self.inverse )
	end
	if other.instance_of?(NumRu::NArrayScalar)
	  return NumRu::NMatrix.mul( other.newdim(0), self.inverse )
	end
    end
    raise TypeError,"Illegal operation: %s %s NumRu::NMatrix" %
      [other.class, id.id2name]
  end

  def inverse
    self.lu.solve( NumRu::NMatrix.new(self.typecode, *self.shape).fill!(0).unit )
  end

  def transpose(*arg)
    if arg.size==0
      super(1,0)
    else
      super
    end
  end

  def diagonal!(val=1)
    shp = self.shape
    idx = NumRu::NArray.int(shp[0..1].min).indgen! * (shp[0]+1)
    ref = reshape(shp[0]*shp[1],true)
    if val.kind_of?(Numeric)
      ref[idx,true] = val
    else
      val = NumRu::NArray.to_na(val)
      raise ArgumentError, "must be 1-d array" if val.dim!=1
      ref[idx,true] = val.newdim!(-1)
    end
    self
  end

  def diagonal(val)
    self.dup.diagonal!(val)
  end

  def unit
    diagonal!
  end
  alias identity unit
  alias I unit

end # class NumRu::NMatrix


#
# ------ NumRu::NVector ------
#
class NumRu::NVector < NumRu::NArray
  CLASS_DIMENSION = 1

  def +(other)
    case other
    when NumRu::NVector
      return super(NumRu::NArray.refer(other))
    when NumRu::NArray
      unless other.instance_of?(NumRu::NArray)
        return other.coerce_rev( self, :+ )
      end
    end
    raise TypeError,"Illegal operation: NumRu::NVector + %s" % other.class
  end

  def -(other)
    case other
    when NumRu::NVector
      return super(NumRu::NArray.refer(other))
    when NumRu::NArray
      unless other.instance_of?(NumRu::NArray)
        return other.coerce_rev( self, :- )
      end
    end
    raise TypeError,"Illegal operation: NumRu::NVector - %s" % other.class
  end

  def *(other)
    case other
    when NumRu::NMatrix
      NumRu::NVector.mul_add( NumRu::NArray.refer(self).newdim!(0), other, 1 )
    when NumRu::NVector
      NumRu::NArray.mul_add( NumRu::NArray.refer(self), other, 0 ) # inner product
    when NumRu::NArray
      if other.instance_of?(NumRu::NArray)
	NumRu::NVector.mul( NumRu::NArray.refer(self), other.newdim(0) )
      else
	other.coerce_rev( self, :* )
      end
    when Numeric
      NumRu::NVector.mul( NumRu::NArray.refer(self), other )
    else
      raise TypeError,"Illegal operation: NumRu::NVector * %s" % other.class
    end
  end

  def /(other)
    case other
    when NumRu::NMatrix
      other.lu.solve(self)
    when NumRu::NVector
      raise TypeError,"Illegal operation: NumRu::NVector / %s" % other.class
    when NumRu::NArray
      if other.instance_of?(NumRu::NArray)
	NumRu::NVector.div( NumRu::NArray.refer(self), other.newdim(0) )
      else
	other.coerce_rev( self, :/ )
      end
    when Numeric
      NumRu::NVector.div( NumRu::NArray.refer(self), other )
    else
      raise TypeError,"Illegal operation: NumRu::NVector / %s" % other.class
    end
  end

  def **(n)
    if n==2
      self*self
    else
      raise ArgumentError,"Only v**2 is implemented"
    end
  end

  def coerce_rev(other,id)
    case id
    when :*
	if other.instance_of?(NumRu::NArray)
	  return NumRu::NVector.mul( other.newdim(0), self )
	end
	if other.instance_of?(NumRu::NArrayScalar)
	  return NumRu::NVector.mul( other, self )
	end
    end
    raise TypeError,"Illegal operation: %s %s NumRu::NVector" %
      [other.class, id.id2name]
  end

end # class NumRu::NVector
