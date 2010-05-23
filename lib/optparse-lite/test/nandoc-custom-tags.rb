require 'json'
require 'strscan'
require 'nandoc/filters'
module OptparseLite
  module MyStringMethods
    def module_basename mixed
      mixed.to_s =~ /([^:]*)\Z/ and $1
    end
  end
end
me = File.dirname(__FILE__)+'/nandoc-custom-tags'
require me + '/app.rb'
require me + '/playback.rb'
