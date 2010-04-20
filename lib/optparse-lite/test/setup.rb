require 'minitest/autorun'
require File.dirname(__FILE__)+'/minitest-diff-extlib.rb'

module OptparseLite
  module Test
    module Helpers
    end
  end
end

MiniTest::Spec.send(:include, OptparseLite::Test::Helpers)

if ARGV.include? '-v'
  OptparseLite::Test.verbose = true
end

# hack to turn off randomness, for running the simplest
# test cases first
if (idx = ARGV.index('--seed')) && '0'==ARGV[idx+1]
  class MiniTest::TestCase
    def test_order
      :alpha
    end
  end
end

# core extensions just for tests!
class String
  def noindent n=nil
    n ||= /\A *(?! )/.match(self)[0].length
    s = gsub(/^ {#{n}}/, '')
    s
  end
end

# extend minitest with optparse-lite-specific stuff!
module OptparseLite
  module Test
    class << self
      attr_accessor :verbose  # set below at end of file
    end
    module Helpers
      #
      # guesses the app based on the current classname
      #
      def _run app=nil, &b
        app ||= guess_app
        ui = app.send(:ui)
        ui.push
        _ = app.instance_eval(&b)
        str = ui.pop.to_str # tacitly assumes stderr is empty, breaks else
        $stdout.puts "\n\n#{str}\n" if Test.verbose
        str
      end

      def _run2 app=nil, &b
        app ||= guess_app
        app.ui.push
        _ = app.instance_eval(&b)
        out, err = app.ui.pop(true)
        out, err = out.to_s, err.to_s
        if Test.verbose
          $stdout.puts "\n\nout:\n#{out}\n."
          $stdout.puts "\n\nerr:\n#{out}\n."
        end
        [out, err]
      end

      def guess_app
        /^OptparseliteTest(.+)Spec/ =~ self.class.to_s
        silly_cache[$1.downcase]
      end

      def silly_cache
        @silly_cache ||= Hash[ OptparseLite::Test.constants.map{|x|
          [x.downcase, OptparseLite::Test.const_get(x)]
        }]
      end
    end
  end
end
