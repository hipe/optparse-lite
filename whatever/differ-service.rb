require 'sinatra'

# use index.html or index.xml if it exists, else passthru
# thanks namelessjon
#
get '/*' do
  require 'ruby-debug'
  head = File.join(options.public, params[:splat])
    # may or may not have trailing slash
  found = %w(index.xml index.html).map{|x| File.join(head,x)}.detect do |path|
    File.exist?(path)
  end
  if found
    send_file found
  else
    pass
  end
end

get '/diff/:html' do |x|
  "ok there is hope: #{Time.now} - #{x.inspect}"
end
