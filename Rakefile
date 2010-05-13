require 'rake/testtask.rb'
require File.expand_path('../lib/optparse-lite.rb', __FILE__)
require File.expand_path('../lib/optparse-lite/test/gentest/tasks', __FILE__)
require 'nandoc' # RcovAgent, ParseReadme


task :default => :test

# require 'jeweler'

# require 'nandoc/parse-readme'
#
# Jeweler::Tasks.new do |s|
#   s.authors = ['Chip Malice']
#   # s.description = NanDoc::ParseReadme.description('README')
#   s.email = 'chip.malice@gmail.com'
#   s.executables = []
#   s.files =  FileList['[A-Z]*', '{bin,doc,generators,lib,test}/**/*']
#   s.homepage = "http://optparse-lite.rubyforge.org"
#   s.files = %w(
#     lib/optparse-lite.rb
#     test/test.rb
#     ) + Dir['*.txt']
#   s.homepage = 'http://optparse-lite.hipeland.org'
#   s.name = 'optparse-lite'
#   s.rubyforge_project = 'optparse-lite'
#   # s.summary = NanDoc::ParseReadme.summary('README')
#   s.summary = "half the size, half the features of trollop/trollip"
#
#   # deps
#   s.add_dependency 'json', '~> 1.2.3'
# end

Rake::TestTask.new do |t|
  t.verbose = true
  t.warning = true
end

me = "\e[35mopl\e[0m "

teh_file = './.last-rcov'
desc "#{me}generate rcov coverage, write to #{teh_file}"
task :rcov do
  require File.dirname(__FILE__)+'/lib/optparse-lite/test/nandoc-extlib'
  agent = NanDoc::RcovAgent.new do |ag|
    output_dir 'mysite/output/coverage'
    input_file 'test/test.rb'
  end
  agent.run
end

desc "#{me}hack turns the installed gem into a symlink to this directory"
task :hack do
  kill_path = %x{gem which optparse-lite}
  kill_path = File.dirname(File.dirname(kill_path))
  new_name  = File.dirname(kill_path)+'/ok-to-erase-'+File.basename(kill_path)
  FileUtils.mv(kill_path, new_name, :verbose => 1)
  this_path = File.dirname(__FILE__)
  FileUtils.ln_s(this_path, kill_path, :verbose => 1)
end

Hipe::GenTest::GenTestTask.new

Hipe::GenTest::UnGenTask.new

# FileList['tasks/**/*.rake'].each { |task| import task }
