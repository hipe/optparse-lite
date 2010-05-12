if ! Object.const_defined?(:Hipe) || ! ::Hipe.const_defined?(:GenTest)
  require File.expand_path('../gentest.rb', __FILE__)
end

here = File.dirname(__FILE__)
require here + '/tasks/gentest.rb'
require here + '/tasks/ungen.rb'
