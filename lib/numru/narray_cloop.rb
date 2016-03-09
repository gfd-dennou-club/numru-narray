require "numru/narray"
require "tmpdir"
require "erb"

module NumRu
  module NArrayCLoop

    @@kernel_num = 0 # number of kernels

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


    def self.kernel(*arys,&block)
      @@kernel_num += 1
      @@omp = false # true if openmp is enabled at least one loop
      na = -1
      args = []
      @@main = NArrayCLoop::BlockMain.new
      @@idxmax = 0
      ars = arys.map do |ary|
        na += 1
        vn = "v#{na}"
        args.push vn
        NArrayCLoop::Ary.new(ary.shape, ary.rank, ary.typecode, [:ary, vn], @@main)
      end

      self.module_exec(*ars,&block)

      body = @@main.to_s
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
          NumRu::NArrayCLoop.send("c_func_#{@@kernel_num}", *arys)
        end
      end

      return nil
    end


    def self.c_loop(min, max, openmp=false, &block)
      @@omp ||= openmp
      parent = @@main.current
      loop = NArrayCLoop::BlockLoop.new(parent, min, max, openmp, &block)
      @@idxmax = [@@idxmax, loop.idx+1].max
      return loop
    end


    def self.c_if(cond, &block)
      parent = @@main.current
      return NArrayCLoop::BlockIf.new(parent, cond, &block)
    end

    def self.c_break
      @@main.current.append "break"
    end



    # private class

    class Block # abstract class

      attr_reader :idx, :depth

      def initialize(parent)
        @parent = parent
        @idx = parent.idx
        @depth = parent.depth + 1
        @block = Array.new
        parent.current = self
        parent.append self
      end

      def current=(block)
        @parent.current = block
      end
      def current
        @parent.current
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

    end

    class BlockMain < Block

      def initialize
        @parent = nil
        @depth = 0
        @idx = -1
        @block = Array.new
        @current = self
      end

      def current=(block)
        @current = block
      end
      def current
        @current
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

      def initialize(parent, min, max, openmp)
        super(parent)
        @min = min
        @max = max
        @idx = parent.idx + 1
        @openmp = openmp
        yield( NArrayCLoop::Index.new(@idx, min, max) )
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

      def initialize(parent, cond)
        unless parent.idx >= 0
          raise "c_if must be in a loop"
        end
        super(parent)
        @cond = cond
        @elseif = false
        yield
      end

      def prefix
        "if ( #{@cond} ) {\n"
      end

      def postfix
        @elseif ? "#{"  " * @depth}}" : super
      end

      def elseif(cond, &block)
        @elseif = true
        NArrayCLoop::BlockElseIf.new(@parent, cond, &block)
      end

      def else(&block)
        @elseif = true
        NArrayCLoop::BlockElse.new(@parent, &block)
      end

      def type
        :if
      end

    end

    class BlockElseIf < Block

      def initialize(parent, cond)
        super(parent)
        @cond = cond
        @elseif = false
        yield
      end

      def prefix
        "else if ( #{@cond} ) {\n"
      end

      def postfix
        @elseif ? "#{"  " * @depth}}" : super
      end

      def elseif(cond, &block)
        @elseif = true
        NArrayCLoop::BlockElseIf.new(@parent, cond, &block)
      end

      def else(&block)
        @elseif = true
        NArrayCLoop::BlockElse.new(@parent, &block)
      end

      def type
        :elseif
      end

    end

    class BlockElse < Block

      def initialize(parent)
        super(parent)
        yield
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
        eval <<EOF
      def #{op}(other)
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

      def initialize(shape, rank, type, ops, block=nil)
        @shape = shape
        @rank = rank
        @type = type
        @ops = ops
        @block = block
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
          @block.current.append self.class.new(@shape, @rank, @type, [:set, ops, [:int,other]])
        when self.class
          @block.current.append self.class.new(@shape, @rank, @type, [:set, ops, other.ops])
        else
          raise ArgumentError, "invalid argument"
        end
        return nil
      end

      [
        ["+", "add"],
        ["-", "sub"],
        ["*", "mul"],
        ["/", "div"]
      ].each do |m, op|
        str = <<EOF
      def #{m}(other)
        binary_operation(other, :#{op})
      end
EOF
        eval str
      end

      [">", ">=", "<", "<=", "=="].each do |op|
        str = <<EOF
      def #{op}(other)
        unless @rank==0
          raise "slice first"
        end
        NArrayCLoop::Cond.new("\#{to_s} #{op} \#{other}")
      end
EOF
        eval str
      end

      def to_s
        get_str(@ops)
      end

      def ctype
        @@ntype2ctype[@type]
      end

      protected
      def ops
        @ops
      end

      @@twoop = {:add => "+", :sub => "-", :mul => "*", :div => "/"}
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
          return "#{o1} = #{o2};"
        when :int, :ary
          return obj[0].to_s
        else
          raise "unexpected value: #{op} (#{op.class})"
        end
      end

      def binary_operation(other, op)
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

    class Cond

      def initialize(cond)
        @cond = cond
      end

      [
        ["and", "&&"],
        ["or", "||"]
      ].each do |m, op|
        eval <<EOF
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
<% ars.each_with_index do |ary,i| %>
<%   ctype = ary.ctype %>
  <%= ctype %> v<%= i %> = NA_PTR_TYPE(rb_v<%= i %>, <%= ctype %>);
<% end %>
<% @@idxmax.times do |i| %>
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
  rb_define_module_function(mNArrayCLoop, "c_func_<%= @@kernel_num %>", <%= func_name %>, <%= ars.length %>);
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
<% if @@omp %>
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
