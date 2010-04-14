require File.dirname(__FILE__)+'/optparse-lite-test-setup.rb'


module OptparseLite::Test

  class Empty
    include OptparseLite
  end
  Empty.spec.invocation_name = "empty-app.rb"

  describe Empty do
    it 'empty-app.rb must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m empty-app.rb (this screen. no commands defined.)
      HERE
      act = _run{ run [] }.strip
      assert_no_diff(exp, act)
    end
  end

  class OneMeth
    include OptparseLite
    def bar; end
  end
  OneMeth.spec.invocation_name = "one-meth-app.rb"

  describe OneMeth do
    it 'one-meth-app.rb must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m one-meth-app.rb {bar} [<opts>] [<args>]

        \e[32;mCommands:\e[0m
          bar          \e[32;mUsage:\e[0m bar
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run [] }.strip
      assert_no_diff(exp, act)
    end
  end
end
