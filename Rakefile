require 'rubygems'
require 'rubygems/package_task'
require 'rake/extensiontask'

load './narray-bigmem.gemspec'

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
  ext.lib_dir = "lib/narray"
end
