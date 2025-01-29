require 'rubygems'
require 'rubygems/package_task'
require 'rake/extensiontask'
require 'rake/testtask'

load './numru-narray.gemspec'

CLOBBER <<  'lib/numru/narray/'

pkgtsk = Gem::PackageTask.new(GEMSPEC) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

task :default => "gem"

#--
GEMFILE = File.join(pkgtsk.package_dir, GEMSPEC.file_name)

task :install => GEMFILE do
  sh "gem install -V --backtrace #{GEMFILE}"
end

task :push => GEMFILE do
  sh "gem push #{GEMFILE}"
end

Rake::ExtensionTask.new "narray" do |ext|
  ext.ext_dir = "ext/numru/narray"
  ext.lib_dir = "lib/numru/narray"
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.verbose = false
  t.warning = false
  t.test_files = FileList['test/*_test.rb']
end
