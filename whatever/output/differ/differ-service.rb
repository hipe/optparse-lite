require 'sinatra'

get '/' do
  "this is the doxxorz rootzoz"
end

get '/diff/:html' do |x|
  "ok there is hope: #{Time.now} - #{x.inspect}"
end
