if ! Object.const_defined?(:Hipe) || ! ::Hipe.const_defined?(:GenTest)
  require File.expand_path('../gentest.rb', __FILE__)
end

module Hipe::GenTest
  def task_prefix
    "\e[35mgentest\e[0m "
  end
end

here = File.dirname(__FILE__)

require here + '/tasks/gentest.rb'
require here + '/tasks/ungen.rb'
