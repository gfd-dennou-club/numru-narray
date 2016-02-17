require "numru/narray"
require "tmpdir"

module NumRu
  module NArrayCLoop

    @@tmpnum = 0
    @@verbose = false
    @@omp_opt = nil
    @@header_path = nil  # path of narray.h

    def self.verbose=(bool)
      @@verbose = bool == true
    end

    def self.omp_opt=(opt)
      @@omp_opt = opt
    end

    def self.header_path=(path)
      @@header_path = path
    end

    def self.kernel(*arys,&block)
      @@tmpnum += 1
      na = -1
      args = []
      @@loop = Array.new
      @@omp = false
      @@idxmax = 0
      ars = arys.map do |ary|
        na += 1
        vn = "v#{na}"
        args.push vn
        NArrayCLoop::Ary.new(ary.shape, ary.rank, ary.typecode, [:ary, vn], @@loop)
      end
      @@body = ""
      self.module_exec(*ars,&block)
      tmpnum = 0
      func_name = "rb_narray_ext_#{@@tmpnum}"
      code = <<EOF
#include "ruby.h"
#include "narray.h"

VALUE
#{func_name}(VALUE self, VALUE rb_#{args.join(", VALUE rb_")}) {
EOF
      ars.each_with_index do |ary,i|
        ctype = ary.ctype
        code << "  #{ctype} v#{i} = NA_PTR_TYPE(rb_v#{i}, #{ctype});\n"
      end
      @@idxmax.times do |i|
        code << "  int i#{i};\n"
      end
      code << @@body
      code << <<EOF
  return Qnil;
}

void
Init_narray_ext_#{@@tmpnum}()
{
  VALUE mNumRu = rb_define_module("NumRu");
  VALUE mNArrayCLoop = rb_define_module_under(mNumRu, "NArrayCLoop");
  rb_define_module_function(mNArrayCLoop, "c_func_#{@@tmpnum}", #{func_name}, #{ars.length});
}
EOF

      sep = "#"*72 + "\n"

      if @@verbose
        print sep
        print "# C source\n"
        print sep
        print code, "\n"
      end

#      tmpdir = "tmp"
#      Dir.mkdir(tmpdir) unless File.exist?(tmpdir)
      Dir.mktmpdir(nil, ".") do |tmpdir|
        Dir.chdir(tmpdir) do |dir|
          fname = "narray_ext_#{@@tmpnum}.c"
          File.open(fname, "w") do |file|
            file.print code
          end
          File.open("extconf.rb", "w") do |file|
            file.print extconf(@@tmpnum,@@omp)
          end
          unless system("ruby extconf.rb > log 2>&1") && system("make >> log 2>&1")
            print sep
            print "# LOG (ruby extconf.rb & make)\n"
            print sep
            print File.read("log"), "\n"

            print sep
            print "# C source (#{fname})\n"
            print sep
            print File.read(fname), "\n"

            print sep
            print "# extconf.rb\n"
            print sep
            print File.read("extconf.rb"), "\n"

            print sep
            print "# mkmf.log\n"
            print sep
            print File.read("mkmf.log"), "\n"
            print sep

            print "\n"
            raise("compile error")
          end
          if @@verbose
            print sep
            print "# compile\n"
            print sep
            print File.read("log"), "\n"
            print sep
            print "# execute\n"
            print sep
            print <<EOF
require "./narray_ext_#{@@tmpnum}.so"
NumRu::NArrayCLoop.send("c_func_#{@@tmpnum}", #{(0...arys.length).to_a.map{|i| "v#{i}"}.join(", ")})

EOF
          end

          require "./narray_ext_#{@@tmpnum}.so"
          NumRu::NArrayCLoop.send("c_func_#{@@tmpnum}", *arys)
        end
      end

      return nil
    end

    def self.cloop(min, max, openmp=false)
      @@omp ||= openmp
      i = @@loop.length
      @@idxmax = [@@idxmax, i+1].max
      idx = NArrayCLoop::Index.new(i, min, max)
      @@body << "#pragma omp parallel for\n" if openmp
      @@body << "  "*(i+1)
      @@body << "for (i#{i}=#{min}; i#{i}<=#{max}; i#{i}++) {\n"

      @@loop.push Array.new
      yield(idx)
      offset = "  "*(i+2)
      @@loop.pop.each do |ex|
        @@body << offset
        @@body << (String===ex ? ex : ex.to_c)
      end
      @@body << "  "*(i+1)+"}\n"
    end

    def self.extconf(tmpnum, omp)
      src = <<EOF
require "mkmf"
EOF
      if @@header_path
        src << <<EOF
header_path = "#{@@header_path}"
EOF
      else
        src << <<EOF
require "rubygems"
gem_path = nil
if Gem::Specification.respond_to?(:find_by_name)
  if spec = Gem::Specification.find_by_name("numru-narray")
    gem_path = spec.full_gem_path
  end
else
  if spec = Gem.source_index.find_name("numru-narray").any?
    gem_path = spec.full_gem_path
  end
end
unless gem_path
  raise "gem numru-narray not found"
end
header_path = File.join(gem_path, "ext", "numru", "narray")
EOF
      end

      src << <<'EOF'
find_header("narray_config.h", *([header_path]+Dir["../tmp/*/narray/*"]))
unless find_header("narray.h", header_path)
  STDERR.print "narray.h not found\n"
  STDERR.print "Set path of narray.h to NumRu::NArrayCLoop.header_path\n"
  raise "narray.h not found"
end
EOF

      # openmp enable
      if omp
        if @@omp_opt
          omp_opt = @@omp_opt
        else
          case RbConfig::CONFIG["CC"]
          when "gcc"
            omp_opt = "-fopenmp"
          else
            omp_opt = nil
          end
        end
        if omp_opt
          src << <<EOF
$CFLAGS << " " << "#{omp_opt}"
$DLDFLAGS << " " << "#{omp_opt}"
EOF
        else
          warn "openmp is disabled (Set compiler option for OpenMP to NArrayCLoop.omp_opt"
          warn "openmp is disabled"
        end
      end

      src << <<EOF

create_makefile("narray_ext_#{tmpnum}")
EOF
    end



    class Index

      def initialize(idx,min,max,shift=nil)
        @idx = idx
        @min = min
        @max = max
        @shift = shift
      end

      def +(i)
        case i
        when Fixnum
          NArrayCLoop::Index.new(@idx,@min,@max,i)
        else
          raise ArgumentError, "invalid argument"
        end
      end

      def -(i)
        case i
        when Fixnum
          NArrayCLoop::Index.new(@idx,@min,@max,-i)
        else
          raise ArgumentError, "invalid argument"
        end
      end

      def to_s
        if @shift.nil?
          "i#{@idx}"
        elsif @shift > 0
          "i#{@idx}+#{@shift}"
        else # < 0
          "i#{@idx}#{@shift}"
        end
      end
      alias :inspect :to_s

      def idx
        @idx
      end
      def min
        @shift ? [@min, @min+@shift].min : @min
      end
      def max
        @shift ? [@max, @max+@shift].max : @max
      end

    end


    class Ary

      @@ntype2ctype = {NArray::BYTE => "u_int8_t*",
                       NArray::SINT => "int16_t*",
                       NArray::LINT => "int32_t*",
                       NArray::SFLOAT => "float*",
                       NArray::DFLOAT => "double*",
                       NArray::SCOMPLEX => "scomplex*",
                       NArray::DCOMPLEX => "dcomplex*"}
      if NArray.const_defined?(:LLINT)
        @@ntype2ctype[NArray::LLINT] = "int64_t*"
      end

      def initialize(shape, rank, type, ops, exec=nil)
        @shape = shape
        @rank = rank
        @type = type
        @ops = ops
        @exec = exec
        if @type==NArray::SCOMPLEX || @type==NArray::DCOMPLEX
          raise "complex is not supported at this moment"
        end
      end

      def [](*idx)
        unless idx.length == @rank
          raise "number of idx != rank"
        end
        self.class.new(@shape, 0, @type, [:slice, @ops, slice(*idx)])
      end

      def []=(*arg)
        idx = arg[0..-2]
        other = arg[-1]
        unless idx.length == @rank
          raise "number of idx != rank"
        end
        ops = [:slice, @ops, slice(*idx)]
        case other
        when Numeric
          @exec[-1].push self.class.new(@shape, @rank, @type, [:set, ops, [:int,other]])
        when self.class
          @exec[-1].push self.class.new(@shape, @rank, @type, [:set, ops, other.ops])
        else
          raise ArgumentError, "invalid argument"
        end
        return nil
      end

      def +(other)
        arithmetic(other, :add)
      end

      def -(other)
        arithmetic(other, :sub)
      end

      def *(other)
        arithmetic(other, :mul)
      end

      def /(other)
        arithmetic(other, :div)
      end

      def to_c
        get_str(@ops) + ";\n"
      end

      def ctype
        @@ntype2ctype[@type]
      end

      protected
      def ops
        @ops
      end

      @@twoop = {:add => "+", :sub => "-", :mul => "*", :div => "/", :set => "="}

      private
      def get_str(obj)
        op = obj[0]
        obj = obj[1..-1]
        case op
        when :slice
          obj, idx = obj
          obj = get_str(obj)
          return "#{obj}[#{idx}]"
        when :add, :sub, :mul, :div
          o1, o2 = obj
          o1 = get_str(o1)
          o2 = get_str(o2)
          return "( #{o1} #{@@twoop[op]} #{o2} )"
        when :set
          o1, o2 = obj
          o1 = get_str(o1)
          o2 = get_str(o2)
          return "#{o1} #{@@twoop[op]} #{o2}"
        when :int, :ary
          return obj[0].to_s
        else
          raise "unexpected value: #{op} (#{op.class})"
        end
      end

      def arithmetic(other, op)
        unless @rank==0
          raise "slice first"
        end
        case other
        when Numeric
          return self.class.new(@shape, 0, @type, [op, @ops, [:int,other]])
        when self.class
          return self.class.new(@shape, 0, @type, [op, @ops, other.ops])
        else
          raise ArgumentError, "invalid argument: #{other} (#{other.class})"
        end
      end

      def slice(*idx)
        case @rank
        when 0
          raise "rank is zero"
        else
          unless Array===idx && idx.length == @rank
            raise ArgumentError, "number of index must be equal to rank"
          end
        end
        idx.each_with_index do |id,i|
          case id
          when NArrayCLoop::Index
            if id.min < 0 || id.max > @shape[i]-1
              raise ArgumentError, "out of boundary"
            end
          when Fixnum
            idx[i] = id + @shape[i] if id < 0
            if id > @shape[i]-1
              raise ArgumentError, "out of boundary"
            end
          else
            raise ArgumentError, "index is invalid: #{id} (#{id.class}) #{@rank}"
          end
        end
        if @rank == 1
          sidx = idx[0].to_s
        else
          sidx = idx[-1].to_s
          (@rank-1).times do |i|
            sidx = "(#{sidx})*#{@shape[-i-2]}+(#{idx[-i-2].to_s})"
          end
        end
        return sidx
      end

    end # class Ary

  end # module NArrayCLoop

end # module NumRu
