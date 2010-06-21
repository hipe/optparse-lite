require 'rake/testtask.rb'
require File.expand_path('../lib/optparse-lite.rb', __FILE__)
require File.expand_path('../lib/optparse-lite/test/gentest/tasks', __FILE__)
require 'nandoc/extras/rcov-task'

task :default => :test

require 'jeweler'

require 'nandoc/parse-readme'

Jeweler::Tasks.new do |s|
  s.authors = ['Chip Malice']
  s.description = NanDoc::ParseReadme.description('README')
  s.email = 'chip.malice@gmail.com'
  s.executables = []
  s.files =  FileList['[A-Z]*', '{bin,doc,generators,lib,test}/**/*']
  s.homepage = 'http://optparse-lite.hipeland.org'
  s.name = 'optparse-lite'
  s.rubyforge_project = 'optparse-lite'
  s.summary = NanDoc::ParseReadme.summary('README')
end

Rake::TestTask.new do |t|
  t.verbose = true
  t.warning = true
end

me = "\e[35mopl\e[0m "

desc "#{me}put rcov coverage html docs into mysite/output"
NanDoc::RcovTask.new(:rcov) do |t|
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
  t.rcov_opts << "--text-report"
  t.rcov_opts << "--exclude '.*gem.*'"
  t.rcov_opts << "--exclude '.*treebis*'"
  t.rcov_opts << "--include-file 'optparse-lite/lib'"
  t.output_dir = 'mysite/output/coverage'
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
