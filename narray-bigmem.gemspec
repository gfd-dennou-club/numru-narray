open("ext/narray/narray.h") do |f|
  f.each_line do |l|
    if /NARRAYBIGMEM_VERSION "([\d.]+)"/ =~ l
      NARRAYBIGMEM_VERSION = $1
      break
    end
  end
end

GEMSPEC = Gem::Specification.new do |s|
  s.name = "narray-bigmem"
  s.version = NARRAYBIGMEM_VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Seiya Nishizawa"]
  s.date = Time.now.strftime("%F")
  s.description = "NArray with big memory support"
  s.email = "seiya@gfd-dennou.org"
  s.extensions = ["ext/narray/extconf.rb"]
  s.require_paths = ["lib"]
  s.files = %w[
ChangeLog
MANIFEST
README
README_NARRAY.en
README_NARRAY.ja
SPEC.en
SPEC.ja
ext/narray/depend
ext/narray/extconf.rb
ext/narray/mkmath.rb
ext/narray/mknafunc.rb
ext/narray/mkop.rb
ext/narray/na_array.c
ext/narray/na_func.c
ext/narray/na_index.c
ext/narray/na_linalg.c
ext/narray/na_random.c
ext/narray/narray.c
ext/narray/narray.def
ext/narray/narray.h
ext/narray/narray_local.h
lib/narray.rb
lib/narray_ext.rb
lib/nmatrix.rb
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
  s.homepage = "https://github.com/seiya/narray-bigmeme/"
#  s.rubyforge_project = "narray"
#  s.rubygems_version = "1.8.10"
  s.summary = "NArray with big memory support"
  s.license = "Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
