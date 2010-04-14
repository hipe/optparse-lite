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
    it 'one-meth-app.rb no args must work' do
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

  describe OneMeth do
    it 'one-meth-app.rb ask for help must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m one-meth-app.rb <command> [<opts>] [<args>]

        \e[32;mCommands:\e[0m
          bar          \e[32;mUsage:\e[0m bar
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run ["-h"] }.strip
      assert_no_diff(exp, act)
    end
  end

  module NoOptparseLiteForU
  end
  describe NoOptparseLiteForU do
    it "should raise on trying to do module (for now. "<<
                                      "this will be changed.)" do
      e = assert_raises(RuntimeError){
        NoOptparseLiteForU.send(:include, OptparseLite)
      }
      assert_equal e.message,
        "module controller singletons not yet implemented"
    end
  end


  class OneMethWithNegArity
    include OptparseLite
    def bar(*a); end
  end
  OneMethWithNegArity.spec.invocation_name = "one-meth-with-neg-arity-app.rb"

  describe OneMethWithNegArity do
    it 'one-meth-with-neg-arity-app.rb must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m one-meth-with-neg-arity-app.rb {bar} [<opts>] [<args>]

        \e[32;mCommands:\e[0m
          bar          \e[32;mUsage:\e[0m bar [<arg1>]
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run [] }.strip
      assert_no_diff(exp, act)
    end
  end


  class OneMethWithPosArity
    include OptparseLite
    def bar(a); end
  end
  OneMethWithPosArity.spec.invocation_name = "one-meth-with-pos-arity-app.rb"

  describe OneMethWithPosArity do
    it 'one-meth-with-pos-arity-app.rb must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m one-meth-with-pos-arity-app.rb {bar} [<opts>] [<args>]

        \e[32;mCommands:\e[0m
          bar          \e[32;mUsage:\e[0m bar <arg1>
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run [] }.strip
      assert_no_diff(exp, act)
    end
  end

end
