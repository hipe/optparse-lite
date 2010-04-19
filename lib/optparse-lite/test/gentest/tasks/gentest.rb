require File.expand_path('../../tasklib.rb', __FILE__)

module Hipe
  module GenTest
    class GenTestTask
      include Hipe::GenTest::TaskLib
      def initialize name=:gentest, argv=ARGV
        @argv = argv
        @desc = "gentest -- try it and see!"
        @name = name
        yield self if block_given?
        define
      end
      attr_accessor :name
      attr_writer :desc
    private
      def define
        desc @desc
        task(@name){ run @argv }
      end
      def run argv
        require File.expand_path('../../gentest.rb',__FILE__)
        fail('huh?') unless argv.shift == @name.to_s
        use_argv = argv.dup
        argv.clear # don't let rake see (?)
        argv = use_argv
        if argv.empty?
          puts <<-HERE.gsub(/^            /,'')
            #{hdr 'Usage:'} #{cmd 'rake gentest'} -- [--out=2] ./your-app.rb --foo='bar' --baz='jazz'
            #{hdr 'Description:'} output to STDOUT a code snippet fer yer test
            #{hdr 'Options:'}
            --out=2         pseudo option. if present it must equal '2', it will
                            create a test that captures both stdout and stderr streams,
                            turns them to strings, and returns them both for assertion
                            against the two recorded strings.  Default is to ignore stderr.
          \n\n
          HERE
          exit # why it complains on return i don't get
        end
        GenTest::gentest(use_argv)
      end
    end
  end
end
