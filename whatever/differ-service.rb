require 'sinatra'


get '/diff-1.html' do
  require File.dirname(__FILE__)+'/differ-service/differ'
  some_root = File.dirname(__FILE__)+'/public/js'
  left = some_root + '/jquery-1.4.3.pre.js'
  right = some_root + '/jquery-1.4.3.pre-hact.js'
  diff = Hipe::Differ.get_diff(left, right)
  html = "<html><head><title>jquery diff</title>\n"
  html <<
  '<link rel="stylesheet" type="text/css" href="/css/trollop-subset.css" media="screen" />'
  html << "\n</head>\n"
  html << <<-HTML
    <p>This is a diff showing the hacks I did to jquery to get it to work with xhtml and svgs.</p>
    <em><a href='/'>back to main page</a></em>
    <br />
    <br />
  HTML
  html << "<body><pre id='the-diff' class='terminal'>\n"
  html << diff.to_html
  html << "</pre>\n"
  html << "<div class='footer'><em>generated on #{Time.now}</em></div>\n"
  html << "</body></html>\n"
  html
end

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

