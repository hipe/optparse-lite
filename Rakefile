# require 'rubygems'
require 'ruby-debug'
require 'rake/testtask.rb'
require 'rake/gempackagetask.rb'
require File.expand_path('../lib/optparse-lite.rb', __FILE__)

task :default => :test

spec = Gem::Specification.new do |s|
  s.name = "optparse-lite"
  s.version = '0.0.0'
  s.date = Time.now.to_s
  s.email = "chip.malice@gmail.com"
  s.authors = ["Chip Malice"]
  s.summary = "half the size, half the features of trollop/trollip"
  # s.homepage = "http://foo.rubyforge.org"
  s.files = %w(
    lib/optparse-lite.rb
    test/test.rb
    ) + Dir["*.txt"]
  s.executables = []
  # s.rubyforge_project = "optparse-lite"
  s.description = "foo, bar."
end

Rake::GemPackageTask.new(spec){}

Rake::TestTask.new()

desc "generate rcov coverage"
task :rcov do
  sh %!rcov --exclude '.*gem.*' test/test.rb!
end

FileList['tasks/**/*.rake'].each { |task| import task }
