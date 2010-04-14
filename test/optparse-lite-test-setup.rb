require 'minitest/autorun'
require File.dirname(__FILE__)+'/minitest-extra.rb'
require File.expand_path('../../lib/optparse-lite.rb',__FILE__)


# core extensions just for tests!
class String
  def noindent n=nil
    n ||= /\A *(?! )/.match(self)[0].length
    s = gsub(/^ {#{n}}/, '')
    s.gsub!(/\n\Z/,'') # remove one trailing newline, b/c this is so common
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
        app.ui.push
        app.instance_eval(&b)
        str = app.ui.pop.to_str
        $stdout.puts "\n\n#{str}\n" if Test.verbose
        str
      end
      module_function :_run
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

MiniTest::Spec.send(:include, OptparseLite::Test::Helpers)

if ARGV.include? '-v'
  OptparseLite::Test.verbose = true
end
