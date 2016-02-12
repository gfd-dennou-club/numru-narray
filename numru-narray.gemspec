open("ext/numru/narray/narray.h") do |f|
  f.each_line do |l|
    if /NUMRU_NARRAY_VERSION "([\d.]+)"/ =~ l
      NUMRU_NARRAY_VERSION = $1
      break
    end
  end
end

GEMSPEC = Gem::Specification.new do |s|
  s.name = "numru-narray"
  s.version = NUMRU_NARRAY_VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Seiya Nishizawa"]
  s.date = Time.now.strftime("%F")
  s.description = "NArray with big memory support"
  s.summary = "NumRu-NArray is a Ruby class library for multi-dimensional array and a fork of NArray with big memory support"
  s.email = "seiya@gfd-dennou.org"
  s.extensions = ["ext/numru/narray/extconf.rb"]
  s.require_paths = ["lib"]
  s.files = %w[
ChangeLog
MANIFEST
README
README_NARRAY.en
README_NARRAY.ja
SPEC.en
SPEC.ja
ext/numru/narray/depend
ext/numru/narray/extconf.rb
ext/numru/narray/mkmath.rb
ext/numru/narray/mknafunc.rb
ext/numru/narray/mkop.rb
ext/numru/narray/na_array.c
ext/numru/narray/na_func.c
ext/numru/narray/na_index.c
ext/numru/narray/na_linalg.c
ext/numru/narray/na_random.c
ext/numru/narray/narray.c
ext/numru/narray/narray.def
ext/numru/narray/narray.h
ext/numru/narray/narray_local.h
lib/numru/narray.rb
lib/numru/narray_ext.rb
lib/numru/nmatrix.rb
]
  s.rdoc_options = %w[
    --title NArray
    --main NArray
    --exclude mk.*
    --exclude extconf\.rb
    --exclude .*\.h
    --exclude lib/
    --exclude .*\.o
    --exclude narray\.so
    --exclude libnarray\.*
    --exclude ChangeLog
    --exclude MANIFEST
    --exclude README*
    --exclude SPEC*
  ]
  s.homepage = "https://github.com/seiya/numru-narray/"
  s.license = "Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
