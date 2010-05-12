require File.expand_path('../../tasklib.rb', __FILE__)

module Hipe
  module GenTest
    class UnGenTask
      include Hipe::GenTest::TaskLib
      def initialize name=:ungen, argv=ARGV
        @argv = argv
        @desc = "#{GenTest.task_prefix}(ungentest) -- try it and see!"
        @name = name
        yield self if block_given?
        define
      end
      attr_writer :desc
    private
      def define
        desc @desc
        task(@name){ run }
      end
      def run
        require File.expand_path('../../gentest.rb', __FILE__)
        fail('huh?') unless @argv.shift == @name.to_s
        use_argv = @argv.dup
        @argv.clear # don't let rake see (?)
        argv = use_argv
        if argv.size > 1
          puts "too many arguments: #{argv.inspect}"
          arg = nil
        elsif argv.empty?
          arg = nil
        elsif /^-(.+)/ =~ argv.first
          if '-list' != argv.first
            puts "unrecognized option: #{argv.first}"
          else
            arg = argv.first
          end
        else
          arg = argv.first
        end
        unless arg
          puts <<-HERE.gsub(/^            /,'')

            #{hdr 'Usage:'} #{cmd 'rake ungen'} -- <some-app-name.rb>
                   #{cmd 'rake ungen'} -- -list

            #{hdr 'Description:'} Ungentest. write to stdout a chunk of
            code in the test file corresponding to the name.
            (for now the testfile is hard-coded as "test/test.rb")

              The second form lists available code chunks found in the file.
          \n\n
          HERE
        end

        if arg=='-list'
          GenTest::ungentest_list 'test/test.rb'
        elsif arg
          GenTest::ungentest 'test/test.rb', arg
        end
        exit(0) # rake is annoying
      end
    end
  end
end
