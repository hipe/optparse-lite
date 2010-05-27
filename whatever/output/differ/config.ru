require 'rubygems'
require 'sinatra'

root_dir = File.dirname(__FILE__)
require root_dir + '/differ-service.rb'

set :environment, ENV['RACK_ENV'] && ENV['RACK_ENV'].to_sym or :development
set :root,        root_dir
set :app_file,    File.join(root_dir, 'differ-service.rb')
disable :run

# FileUtils.mkdir_p 'log' unless File.exists?('log')
logpath = '/var/log/apache2/sinatra-differ-both.log'
log = File.new(logpath, 'a')
$stdout.reopen(log)
$stderr.reopen(log)

run Sinatra::Application
