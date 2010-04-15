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

    it 'no run' do
      OptparseLite.suppress_run!
      hold = Empty.ui.err
      Empty.ui.err = OptparseLite::Sio.new
      Empty.run
      have = Empty.ui.err
      Empty.ui.err = hold
      OptparseLite.enable_run!
      assert_equal "run disabled. (probably for gentesting)\n", have.to_s
    end
  end


  class OneMeth
    include OptparseLite
    def bar; 'done' end
  end
  OneMeth.spec.invocation_name = "one-meth-app.rb"

  describe OneMeth do

    it 'one-meth-app.rb runs' do
      assert_equal('done', OneMeth.run(['bar']))
    end


    it "one-meth-app.rb works like help
      when the command is not found.
    " do
      exp = <<-HERE.noindent
        i don't know how to \e[32;mbazzle\e[0m.
        try \e[32;mone-meth-app.rb -h\e[0m for help.
      HERE
      act = _run{ run ["bazzle"] }.strip
      assert_no_diff(exp, act)
    end


    it 'one-meth-app.rb ask for help must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m one-meth-app.rb (bar) [<opts>] [<args>]

        \e[32;mCommands:\e[0m
          bar    usage: bar
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run ["-h"] }.strip
      assert_no_diff(exp, act)
    end


    it 'one-meth-app.rb no args must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m one-meth-app.rb (bar) [<opts>] [<args>]

        \e[32;mCommands:\e[0m
          bar    usage: bar
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run [] }.strip
      assert_no_diff(exp, act)
    end


    it 'one-meth-app.rb ask for help bad command must work' do
      exp = <<-HERE.noindent
        i don't know how to \e[32;mska\e[0m.
        try \e[32;mone-meth-app.rb -h\e[0m for help.
      HERE
      act = _run{ run ["-h", "ska"] }.strip
      assert_no_diff(exp, act)
    end


    it 'one-meth-app.rb ask for help partial match must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage: \e[0m one-meth-app.rb bar
      HERE
      act = _run{ run ["-h", "b"] }.strip
      assert_no_diff(exp, act)
    end


    it 'one-meth-app.rb ask for help full match must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage: \e[0m one-meth-app.rb bar
      HERE
      act = _run{ run ["-h", "bar"] }.strip
      assert_no_diff(exp, act)
    end
  end

  class PersistentService
    include OptparseLite
    def initialize
      @num = 0
    end
    def ping
      @num += 1
      ui.puts "i have pinged #{@num} times"
    end
  end
  PersistentService.spec.invocation_name = "persistent-service-app.rb"

  describe PersistentService do
    it "persistent-service-app.rb will use the same object
    each time it fulfills a request.
    " do
      exp = <<-HERE.noindent
        i have pinged 1 times
      HERE
      act = _run{ run ["ping"] }.strip
      assert_no_diff(exp, act)
      exp = <<-HERE.noindent
        i have pinged 2 times
      HERE
      act = _run{ run ["ping"] }.strip
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
        \e[32;mUsage:\e[0m one-meth-with-neg-arity-app.rb (bar) [<opts>] [<args>]

        \e[32;mCommands:\e[0m
          bar    usage: bar [<arg1>]
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
        \e[32;mUsage:\e[0m one-meth-with-pos-arity-app.rb (bar) [<opts>] [<args>]

        \e[32;mCommands:\e[0m
          bar    usage: bar <arg1>
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run [] }.strip
      assert_no_diff(exp, act)
    end
  end


  class OneMethDesc
    include OptparseLite

    app.desc "when u wanna have a good time"

    desc "this is for barring"
    def bar; end
  end
  OneMethDesc.spec.invocation_name = "one-meth-desc-app.rb"

  describe OneMethDesc do
    it 'one-meth-desc-app.rb must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m one-meth-desc-app.rb (bar) [<opts>] [<args>]
          when u wanna have a good time

        \e[32;mCommands:\e[0m
          bar    this is for barring
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run [] }.strip
      assert_no_diff(exp, act)
    end
    it 'one-meth-desc-app.rb ask for help must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage: \e[0m one-meth-desc-app.rb bar
        \e[32;mDescription:\e[0m  this is for barring
      HERE
      act = _run{ run ["-h", "bar"] }.strip
      assert_no_diff(exp, act)
    end
  end

  class OneMethUsage
    include OptparseLite
    usage "<paint> <ball>"
    def bar a, b; end
  end
  OneMethUsage.spec.invocation_name = "one-meth-usage-app.rb"

  describe OneMethUsage do
    it 'one-meth-usage-app.rb must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m one-meth-usage-app.rb (bar) [<opts>] [<args>]

        \e[32;mCommands:\e[0m
          bar    usage: bar <paint> <ball>
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run [] }.strip
      assert_no_diff(exp, act)
    end
  end

  class ThreeMeth
    include OptparseLite
    def foo; end
    def bar(arg1, arg2); end
    desc "faz line one"
    desc "faz line two"
    def faz; end
  end
  ThreeMeth.spec.invocation_name = "three-meth-app.rb"
  ThreeMeth.spec.invocation_name = "three-meth-app.rb"

  describe ThreeMeth do

    it 'three-meth-app.rb no args must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m three-meth-app.rb (foo|bar|faz) [<opts>] [<args>]

        \e[32;mCommands:\e[0m
          foo    usage: foo
          bar    usage: bar <arg1> <arg2>
          faz    faz line one
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run [] }.strip
      assert_no_diff(exp, act)
    end

    it 'three-meth-app.rb help requested command not found must work' do
      exp = <<-HERE.noindent
        i don't know how to \e[32;mska\e[0m.
        try \e[32;mthree-meth-app.rb -h\e[0m for help.
      HERE
      act = _run{ run ["-h", "ska"] }.strip
      assert_no_diff(exp, act)
    end

    it 'three-meth-app.rb help requested partial match must work' do
      exp = <<-HERE.noindent
        did you mean \e[32;mfoo\e[0m or \e[32;mfaz\e[0m?
        try \e[32;mthree-meth-app.rb -h\e[0m for help.
      HERE
      act = _run{ run ["-h", "f"] }.strip
      assert_no_diff(exp, act)
    end

    it 'three-meth-app.rb help requestsed on command with desc must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage: \e[0m three-meth-app.rb faz
        \e[32;mDescription:\e[0m
          faz line one
          faz line two
      HERE
      act = _run{ run ["-h", "fa"] }.strip
      assert_no_diff(exp, act)
    end
  end

  describe OptparseLite::OptsLike do
    it "ops must be OptsLike" do
      e = assert_raises(RuntimeError) do
        class BadOpts
          include OptparseLite
          opts nil
          def foo; end
        end
      end
      assert_equal(e.message, 'opts must be OptsLike')
    end
  end


  module OptsStub
    include OptparseLite::OptsLike
    extend self
    def syntax_tokens
       ['[--fake]', '[-b=<foo>]']
    end
    def doc_matrix
      [
        [nil, nil, 'Awesome Opts:'],
        ['-h,--hey','awesome desc'],
        ['-H,--HO=<ho>', 'awesome desc2']
      ]
    end
  end

  class CmdWithOpts
    include OptparseLite
    opts OptsStub
    def foo; end
  end
  CmdWithOpts.spec.invocation_name = "cmd-with-opts-app.rb"

  describe CmdWithOpts do
    it 'cmd-with-opts-app.rb must work with stub' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m cmd-with-opts-app.rb (foo) [<opts>] [<args>]

        \e[32;mCommands:\e[0m
          foo    usage: foo [--fake] [-b=<foo>]
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run [] }.strip
      assert_no_diff(exp, act)
    end
    it 'cmd-with-opts-app.rb multiline description stub' do
      exp = <<-HERE.noindent
        \e[32;mUsage: \e[0m cmd-with-opts-app.rb foo [--fake] [-b=<foo>]
        \e[32;mAwesome Opts:\e[0m
              -h,--hey    awesome desc
          -H,--HO=<ho>    awesome desc2
      HERE
      act = _run{ run ["-h", "foo"] }.strip
      assert_no_diff(exp, act)
    end
  end
end
