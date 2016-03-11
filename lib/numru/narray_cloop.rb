require "numru/narray"
require "tmpdir"
require "erb"

module NumRu
  module NArrayCLoop

    @@kernel_num = 0 # number of kernels
    @@kernel         # current kernel

    # options
    @@verbose = false    # switch for verbose mode
    @@omp_opt = nil      # compiler option for OpenMP
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

    def self.kernel(*narys, &block)
      @@kernel_num += 1
      na = -1
      args = []
      kernel = NArrayCLoop::Kernel.new
      arys = narys.map do |ary|
        na += 1
        vn = "v#{na}"
        args.push vn
        NArrayCLoop::Ary.new(ary.shape, ary.rank, ary.typecode, vn, kernel)
      end
      body = kernel.exec(*arys, &block)

      func_name = "rb_narray_ext_#{@@kernel_num}"
      code = TEMPL_ccode.result(binding)

      sep = "#"*72 + "\n"
      if @@verbose
        print sep
        print "# C source\n"
        print sep
        print code, "\n"
      end

      # save file and compile
#      tmpdir = "tmp"
#      Dir.mkdir(tmpdir) unless File.exist?(tmpdir)
      Dir.mktmpdir(nil, ".") do |tmpdir|
        Dir.chdir(tmpdir) do |dir|
          fname = "narray_ext_#{@@kernel_num}.c"
          File.open(fname, "w") do |file|
            file.print code
          end
          extconf = TEMPL_extconf.result(binding)
          File.open("extconf.rb", "w") do |file|
            file.print extconf
          end
          unless system("ruby extconf.rb > log 2>&1")
            print sep, "# LOG (ruby extconf.rb)\n"
            print sep, File.read("log"), "\n"

            print sep, "# extconf.rb\n"
            print sep, extconf, "\n"

            print sep, "# mkmf.log\n"
            print sep, File.read("mkmf.log"), "\n"

            print sep, "\n"
            raise("extconf error")
          end
          unless system("make > log 2>&1")
            print sep, "# LOG (make)\n"
            print sep, File.read("log"), "\n"

            print sep, "# C source (#{fname})\n"
            print sep, File.read(fname), "\n"

            print "\n"
            raise("compile error")
          end
          if @@verbose
            print sep, "# compile\n"
            print sep, File.read("log"), "\n"
            print sep, "# execute\n"
            print sep
            print <<EOF
require "./narray_ext_#{@@kernel_num}.so"
NumRu::NArrayCLoop.send("c_func_#{@@kernel_num}", #{(0...arys.length).to_a.map{|i| "v#{i}"}.join(", ")})

EOF
          end

          # execute
          require "./narray_ext_#{@@kernel_num}.so"
          NumRu::NArrayCLoop.send("c_func_#{@@kernel_num}", *narys)
        end
      end

      return nil
    end




    # private class

    class Kernel

      attr_accessor :current
      attr_reader :idxmax, :omp

      def initialize
        @idxmax = 0
        @omp = false
      end

      def c_scalar(type, value=nil)
        return NArrayCLoop::Scalar.new(type, value, current)
      end

      ["int", "long", "long long", "int32_t", "int64_t", "float", "double"].each do |type|
        eval <<EOF, binding, __FILE__, __LINE__+1
        def c_#{type.sub(" ","_")}(value=nil)
          c_scalar("#{type}", value)
        end
EOF
      end

      def c_loop(min, max, openmp=false, &block)
        @omp ||= openmp
        loop = NArrayCLoop::BlockLoop.new(self, min, max, openmp, &block)
        @idxmax = [@idxmax, loop.idx+1].max
        return loop
      end

      def c_if(cond, &block)
        return NArrayCLoop::BlockIf.new(self, cond, &block)
      end

      def c_break
        current.append "break"
      end

      # math.h
      %w(sin asin cos acos tan atan atan2
         sinh asinh cosh acosh tanh atanh
         exp exp2 expm1 frexp ldexp log log2 log10 log1p logb ilogb modf scalbn scalbln
         pow sqrt fabs hypot cbrt
         erf erfc gamma lgamma tgamma
         cail floor nearbyint rint lrint llrint round lround llround trunc
         fmod remainder remquo
         copysign nextafter nexttoward
         fdim fmax fmin
         fma
         j0 j1 jn y0 y1 yn).each do |func|
        [
          ["", "double"],
          ["f", "float"]
        ].each do |prec,ctype|
          eval <<EOF, binding, __FILE__, __LINE__+1
          def #{func}#{prec}(*arg)
            NArrayCLoop::Scalar.new("#{ctype}", "#{func}#{prec}(\#{arg.map{|a| a.to_s}.join(",")})", current, arg)
          end
EOF
        end
      end # math.h

      # stdlib.h
      %w(abs).each do |func|
        [
          ["", "int"],
          ["l", "long"],
          ["ll", "long long"]
        ].each do |prec,ctype|
          eval <<EOF, binding, __FILE__, __LINE__+1
          def #{prec}#{func}(*arg)
            NArrayCLoop::Scalar.new("#{ctype}", "#{prec}#{func}(\#{arg.map{|a| a.to_s}.join(",")})", current, arg)
          end
EOF
        end
      end # stdlib.h

      def exec(*args, &block)
        begin
          main = NArrayCLoop::BlockMain.new(self)
          @current = main
          instance_exec(*args, &block)
        ensure
          main.close
        end
        main.to_s
      end

    end # class Kernel


    class Block # abstract class

      attr_reader :idx, :depth, :hook
      attr_accessor :scalar_num, :last

      def initialize(kernel, *arg)
        @kernel = kernel
        @parent = kernel.current
        @depth = @parent.depth + 1
        @idx ||= @parent.idx
        @block = Array.new
        @svs = Array.new
        @scalar_num = @parent.scalar_num
        kernel.current = self
        @parent.append self
        @last = nil
        @hook = get_hook
        begin
          set_trace_func @hook
          yield(*arg)
        ensure
          set_trace_func @parent.hook
        end
        close
      end

      def current
        @kernel.current
      end

      def append(exp)
        @block.push exp
      end

      def indent
        @indent ||= "  " * (@depth+1)
      end

      def postfix
        "#{"  " * @depth}};"
      end

      def to_s
        str = prefix
        @block.each do |ex|
          str << "#{indent}#{ex}\n"
        end
        str << postfix
        return str
      end

      def define_scalar(name)
        @svs.push name
      end

      def close
        set_trace_func(nil) if type == :main
        @last[1].scalar(@last[0]) if @last
        @kernel.current = @parent
        svs = Array.new
        @svs.each do |sv|
          svs.push sv unless sv.use
        end
        unless svs.empty?
          raise <<EOF
In block
<<< block begin >>>
#{self}
<<< block end >>>
scalar variable(s) is(are) defined but not used:
  #{svs.map{|s| s.to_s}.join("\n  ")}
Do not use '=' to asigin value to scalar variable.
Use #assign in stead.
EOF
        end
      end

      def get_hook
        @hook = lambda do |event, file, line, id, binding, klass|
          if file != __FILE__ && event=="line"
            if @last
              @last[1].scalar(@last[0])
              @last = nil
            end
          end
        end
      end

    end

    class BlockMain < Block

      def initialize(kernel)
        @kernel = kernel
        @parent = nil
        @depth = 0
        @idx = -1
        @scalar_num = 0
        @block = Array.new
        @svs = Array.new
        kernel.current = self
        @hook = get_hook
        set_trace_func @hook
      end

      def type
        :main
      end

      def prefix
        ""
      end
      def postfix
        ""
      end

    end

    class BlockLoop < Block

      def initialize(kernel, min, max, openmp, &block)
        @min = min
        @max = max
        min.use = true if NArrayCLoop::Scalar === min
        max.use = true if NArrayCLoop::Scalar === max
        @idx = kernel.current.idx + 1
        @openmp = openmp
        kernel.current.last = nil
        super(kernel, NArrayCLoop::Index.new(@idx, min, max), &block)
      end

      def prefix
        str = ""
        str << "#pragma omp parallel for\n#{indent}" if @openmp
        str << "for (i#{@idx}=#{@min}; i#{@idx}<=#{@max}; i#{@idx}++) {\n"
        str
      end

      def type
        :loop
      end

    end

    class BlockIf < Block

      def initialize(kernel, cond, &block)
        unless kernel.current.idx >= 0
          raise "c_if must be in a loop"
        end
        @cond = cond
        @elseif = false
        super(kernel, &block)
      end

      def prefix
        "if ( #{@cond} ) {\n"
      end

      def postfix
        @elseif ? "#{"  " * @depth}}" : super
      end

      def elseif(cond, &block)
        @elseif = true
        NArrayCLoop::BlockElseIf.new(@kernel, cond, &block)
      end

      def else(&block)
        @elseif = true
        NArrayCLoop::BlockElse.new(@kernel, &block)
      end

      def type
        :if
      end

    end

    class BlockElseIf < Block

      def initialize(kernel, cond, &block)
        @cond = cond
        @elseif = false
        super(kernel, &block)
      end

      def prefix
        "else if ( #{@cond} ) {\n"
      end

      def postfix
        @elseif ? "#{"  " * @depth}}" : super
      end

      def elseif(cond, &block)
        @elseif = true
        NArrayCLoop::BlockElseIf.new(@kernel, cond, &block)
      end

      def else(&block)
        @elseif = true
        NArrayCLoop::BlockElse.new(@kernel, &block)
      end

      def type
        :elseif
      end

    end

    class BlockElse < Block

      def initialize(kernel, &block)
        super(kernel, &block)
      end

      def prefix
        "else {\n"
      end

      def type
        :else
      end

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

      ["<", "<=", ">", ">=", "=="].each do |op|
        eval <<EOF, binding, __FILE__, __LINE__+1
      def #{op}(other)
        other.use = true if NArrayCLoop::Scalar === other
        NArrayCLoop::Cond.new("\#{to_s} #{op} \#{other}")
      end
EOF
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


    class Value # abstract class

      def initialize(type, block)
        @type = type
        @block = block
      end

      def inspect
        "<#{self.class.name}: type=#{@type}>"
      end

    end

    class Scalar < Value

      attr_accessor :use

      def initialize(type, value, block, parents=[], define=nil)
        super(type, block)
        case value
        when Float, Integer, String, NArrayCLoop::Scalar, nil
          @value = value.to_s
        else
          raise ArgumentError, "invalid value type: #{value.class}"
        end
        @define = define
        @parents = parents
        @use = false
        push_obj(self)
      end

      def -@
        @value = "( -#{to_s} )"
        push_obj(self)
      end

      def assign(other)
        @value = other.to_s
        @block.current.append "#{@define} = #{@value};"
        @block.current.last = nil
        return nil
      end

      %w(+ - * /).each do |op|
        eval <<EOF, binding, __FILE__, __LINE__+1
      def #{op}(other)
        obj = self.class.new(@type, "( \#{to_s} ) #{op} ( \#{other} )", @block, [self,other])
        self.use = true
        other.use = true if self.class === other
        push_obj(obj)
      end
EOF
      end

      [">", ">=", "<", "<=", "=="].each do |op|
        eval <<EOF, binding, __FILE__, __LINE__+1
      def #{op}(other)
        self.use = true
        other.use = true if self.class === other
        @block.current.last = nil
        NArrayCLoop::Cond.new("( \#{to_s} ) #{op} ( \#{other} )")
      end
EOF
      end

      def push_obj(obj)
        @block.current.last = [@block.current, obj]
        return obj
      end

      def scalar(block)
        i = ( block.current.scalar_num += 1 )
        v = "s#{i}"
        if @value
          block.current.append "#{@type} #{v} = #{@value};"
        else
          block.current.append "#{@type} #{v};"
        end
        @define = v
        block.define_scalar(self)
        @use = false
      end

      def ctype
        @type
      end

      def to_s
        @define || @value.to_s
      end

      def coerce(other)
        if other.kind_of?(Numeric)
          return [self.class.new(@type, other, @block), self]
        else
          super
        end
      end

      def define
        @define
      end

      def inspect
        "<#{self.class.name}: type=#{@type}, defined?=#{self.define || false}, value=#{@value}>"
      end

    end # class Scalar

    class Ary < Value

      @@ntype2ctype = {NArray::BYTE => "u_int8_t",
                       NArray::SINT => "int16_t",
                       NArray::LINT => "int32_t",
                       NArray::SFLOAT => "float",
                       NArray::DFLOAT => "double",
                       NArray::SCOMPLEX => "scomplex",
                       NArray::DCOMPLEX => "dcomplex"}
      if NArray.const_defined?(:LLINT)
        @@ntype2ctype[NArray::LLINT] = "int64_t"
      end

      attr_reader :rank

      def initialize(shape, rank, type, ary, block)
        super(type, block)
        @shape = shape
        @rank = rank
        @ary = ary
        if @type==NArray::SCOMPLEX || @type==NArray::DCOMPLEX
          raise "complex is not supported at this moment"
        end
      end

      def [](*idx)
        unless idx.length == @rank
          raise "number of idx != rank"
        end
        NArrayCLoop::Scalar.new(ctype, "#{@ary}[#{slice(*idx)}]", @block, [self])
      end

      def []=(*arg)
        idx = arg[0..-2]
        other = arg[-1]
        ary = self[*idx]
        exec = "#{ary} = #{other};"
        @block.current.append exec
        @block.current.last = nil
        return nil
      end

      def ctype
        @@ntype2ctype[@type]
      end

      private
      def slice(*idx)
        if @rank == 0
          raise "rank is zero"
        end
        unless Array===idx && idx.length == @rank
          raise ArgumentError, "number of index must be equal to rank"
        end
        idx.each_with_index do |id,i|
          case id
          when NArrayCLoop::Index
            if (Fixnum===id.min && id.min < 0) || (Fixnum===id.max && id.max > @shape[i]-1)
              raise ArgumentError, "out of boundary"
            end
          when Fixnum
            idx[i] = id + @shape[i] if id < 0
            if id > @shape[i]-1
              raise ArgumentError, "out of boundary"
            end
          when NArrayCLoop::Scalar
            unless /int/ =~ id.ctype
              raise ArgumentError, "must be interger type: #{id.ctype}"
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



    class Cond

      def initialize(cond)
        @cond = cond
      end

      [
        ["and", "&&"],
        ["or", "||"]
      ].each do |m, op|
        eval <<EOF, binding, __FILE__, __LINE__+1
      def #{m}(other)
        self.class.new("(\#{@cond}) #{op} (\#{other})")
      end
EOF
      end

      def to_s
        @cond
      end

    end


    # templates

    TEMPL_ccode = ERB.new <<EOF
#include "ruby.h"
#include "narray.h"

VALUE
<%= func_name %>(VALUE self, VALUE rb_<%= args.join(", VALUE rb_") %>) {
<% arys.each_with_index do |ary,i| %>
<%   ctype = ary.ctype %>
  <%= ctype %>* v<%= i %> = NA_PTR_TYPE(rb_v<%= i %>, <%= ctype %>*);
<% end %>
<% kernel.idxmax.times do |i| %>
  int i<%= i %>;
<% end %>
<%= body %>

  return Qnil;
}

void
Init_narray_ext_<%= @@kernel_num %>()
{
  VALUE mNumRu = rb_define_module("NumRu");
  VALUE mNArrayCLoop = rb_define_module_under(mNumRu, "NArrayCLoop");
  rb_define_module_function(mNArrayCLoop, "c_func_<%= @@kernel_num %>", <%= func_name %>, <%= arys.length %>);
}
EOF


    TEMPL_extconf = ERB.new <<EOF
require "mkmf"
<% if @@header_path %>
header_path = "<%= @@header_path %>"
<% else %>
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
<% end %>

find_header("narray_config.h", *([header_path]+Dir["../tmp/*/narray/*"]))
unless find_header("narray.h", header_path)
  STDERR.print "narray.h not found\n"
  STDERR.print "Set path of narray.h to NumRu::NArrayCLoop.header_path\n"
  raise "narray.h not found"
end

# openmp enable
<% if kernel.omp %>
<%   if @@omp_opt %>
omp_opt = <%= @@omp_opt %>
<%   else %>
case RbConfig::CONFIG["CC"]
when "gcc"
  omp_opt = "-fopenmp"
else
  omp_opt = nil
end
<%   end %>
if omp_opt
  $CFLAGS << " " << omp_opt
  $DLDFLAGS << " " << omp_opt
else
  warn "openmp is disabled (Set compiler option for OpenMP to NArrayCLoop.omp_opt"
end
<% else %>
warn "openmp is disabled"
<% end %>

create_makefile("narray_ext_<%= @@kernel_num %>")
EOF


  end # module NArrayCLoop

end # module NumRu
