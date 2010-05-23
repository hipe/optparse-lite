require 'minitest/autorun'
require 'optparse-lite'
require 'nandoc/spec-doc'

NanDoc::SpecDoc::Playback::Method.handlers[:optparse_app_module] = [:skip]
NanDoc::SpecDoc::GenericAgent.custom_spec_hook(:grab_optparse_app) do
  recordings.add(:optparse_app_module, :placeholder)
  record = recordings[recordings.length - 1]
  ::OptparseLite.after_included_once do |mod|
    record[1] = mod
  end
end

# extend minitest with optparse-lite-specific stuff!
module OptparseLite
  module Test
    class << self
      attr_accessor :verbose # set below
    end
    module Capture
      class Capturer
        def initialize mod
          # make a regexp that can deduce the local module name from the
          # name of the class that minitest generates, e.g.:
          # OptparseLite::Test => /^OptparseliteTest(.+)Spec/
          @mod = mod
          @regexp = Regexp.new('^'+
           mod.to_s.split('::').map{|x| x.downcase.capitalize}.join +
           '(.+)Spec'
          )
        end
        def capture app=nil, &b
          app ||= @application_module
          do_record = @spec && @spec.respond_to?(:nandoc)
          ui = app.send(:ui)
          ui.push
          if do_record
            app.set_argv_hook do |argv|
              @spec.nandoc.recordings.add(:app, app)
              @spec.nandoc.recordings.add(:argv, argv)
            end
          end
          @last_return_value = app.instance_eval(&b)
          str = ui.pop.to_str # tacitly assumes stderr is empty, breaks else
          if do_record
            @spec.nandoc.recordings.add(:out, str)
          end
          $stdout.puts "\n\n#{str}\n" if Test.verbose
          str
        end
        def capture2 app=nil, &b
          do_record = @spec && @spec.respond_to?(:nandoc)
          app ||= @application_module
          ui = app.send(:ui)
          ui.push
          @last_return_value = app.instance_eval(&b)
          out, err = ui.pop(true)
          out, err = out.to_s, err.to_s
          if Test.verbose
            $stdout.puts "\n\nout:\n#{out}\n."
            $stdout.puts "\n\nerr:\n#{out}\n."
          end
          if do_record
            if ""!=out && ""!=err
              fail("don't be a dick")
            end
            @spec.nandoc.recordings.add(:out, out + err)
          end
          [out, err]
        end
        def get_app_from_spec spec
          name = @regexp.match(spec.class.to_s)[1].downcase
          @cache ||= Hash[
            @mod.constants.map{|x|[x.downcase, @mod.const_get(x)]}
          ]
          @cache[name]
        end
        def init_fork spec
          @application_module = get_app_from_spec(spec)
          @spec = spec # this has nandoc
        end
        def fork thing
          ret = dup
          ret.init_fork(thing)
          ret
        end
        attr_accessor :last_return_value
        attr_accessor :regexp
      end
      class << self
        def included mod
          base = MiniTest::Spec
          capturer_prototype = Capturer.new(mod)
          base.send(:define_method, :capturer) do ||
            @capturer ||= capturer_prototype.fork(self)
          end
          base.send(:define_method, :capture) do |*a, &b|
            capturer.capture(*a, &b)
          end
          base.send(:define_method, :capture2) do |*a, &b|
            capturer.capture2(*a, &b)
          end
        end
      end
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

if ARGV.include? '-v'
  OptparseLite::Test.verbose = true
end

# hack to turn off randomness, for running the simplest
#   test cases first
#
if (idx = ARGV.index('--seed')) && '0'==ARGV[idx+1]
  class MiniTest::TestCase
    def test_order
      :alpha
    end
  end
end
