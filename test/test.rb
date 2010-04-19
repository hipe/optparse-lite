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
      act = _run{ run [] }
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
        try \e[32;mone-meth-app.rb\e[0m \e[32;m-h\e[0m for help.
      HERE
      act = _run{ run ["bazzle"] }
      assert_no_diff(exp, act)
    end


    it 'one-meth-app.rb ask for help must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m one-meth-app.rb (bar) [<opts>] [<args>]

        \e[32;mCommands:\e[0m
          bar    usage: bar
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run ["-h"] }
      assert_no_diff(exp, act)
    end


    it 'one-meth-app.rb no args must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m one-meth-app.rb (bar) [<opts>] [<args>]

        \e[32;mCommands:\e[0m
          bar    usage: bar
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run [] }
      assert_no_diff(exp, act)
    end


    it 'one-meth-app.rb ask for help bad command must work' do
      exp = <<-HERE.noindent
        i don't know how to \e[32;mska\e[0m.
        try \e[32;mone-meth-app.rb\e[0m \e[32;m-h\e[0m for help.
      HERE
      act = _run{ run ["-h", "ska"] }
      assert_no_diff(exp, act)
    end


    it 'one-meth-app.rb ask for help partial match must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m one-meth-app.rb bar
      HERE
      act = _run{ run ["-h", "b"] }
      assert_no_diff(exp, act)
    end


    it 'one-meth-app.rb ask for help full match must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m one-meth-app.rb bar
      HERE
      act = _run{ run ["-h", "bar"] }
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
      act = _run{ run ["ping"] }
      assert_no_diff(exp, act)
      exp = <<-HERE.noindent
        i have pinged 2 times
      HERE
      act = _run{ run ["ping"] }
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
      act = _run{ run [] }
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
      act = _run{ run [] }
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
      act = _run{ run [] }
      assert_no_diff(exp, act)
    end
    it 'one-meth-desc-app.rb ask for help must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m one-meth-desc-app.rb bar
        \e[32;mDescription:\e[0m this is for barring
      HERE
      act = _run{ run ["-h", "bar"] }
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
      act = _run{ run [] }
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
      act = _run{ run [] }
      assert_no_diff(exp, act)
    end

    it 'three-meth-app.rb help requested command not found must work' do
      exp = <<-HERE.noindent
        i don't know how to \e[32;mska\e[0m.
        try \e[32;mthree-meth-app.rb\e[0m \e[32;m-h\e[0m for help.
      HERE
      act = _run{ run ["-h", "ska"] }
      assert_no_diff(exp, act)
    end

    it 'three-meth-app.rb help requested partial match must work' do
      exp = <<-HERE.noindent
        did you mean \e[32;mfoo\e[0m or \e[32;mfaz\e[0m?
        try \e[32;mthree-meth-app.rb\e[0m \e[32;m-h\e[0m for help.
      HERE
      act = _run{ run ["-h", "f"] }
      assert_no_diff(exp, act)
    end

    it 'three-meth-app.rb help requestsed on command with desc must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m three-meth-app.rb faz
        \e[32;mDescription:\e[0m
          faz line one
          faz line two
      HERE
      act = _run{ run ["-h", "fa"] }
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
       ['--fake', '-b=<foo>']
    end
    def doc_sexp
      [[:hdr, 'Awesome Opts:'],
        [:opt, '-h,--hey','awesome desc'],
        [:opt, '-H,--HO=<ho>', 'awesome desc2']]
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
      act = _run{ run [] }
      assert_no_diff(exp, act)
    end
    it 'cmd-with-opts-app.rb multiline description stub' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m cmd-with-opts-app.rb foo [--fake] [-b=<foo>]
        \e[32;mAwesome Opts:\e[0m
              -h,--hey    awesome desc
          -H,--HO=<ho>    awesome desc2
      HERE
      act = _run{ run ["-h", "foo"] }
      assert_no_diff(exp, act)
    end
  end


  class CovPatch
    include OptparseLite

    usage '[-blah -blah] <blah1> <blah2>'
    def wierd_usage
    end

    usage '-one -opt -another [<args>]'
    def useless_interpolate a1, a2
    end
  end
  CovPatch.spec.invocation_name = "cov-patch-app.rb"

  describe CovPatch do

    it 'cov-patch-app.rb displays wierd usage (no validation!?)' do # @todo
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m cov-patch-app.rb wierd-usage [-blah -blah] <blah1> <blah2>
      HERE
      act = _run{ run ["-h", "wierd-"] }
      assert_no_diff(exp, act)
    end


    it 'cov-patch-app.rb interpolates args for no reason' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m cov-patch-app.rb useless-interpolate -one -opt -another <arg1> <arg2>
      HERE
      act = _run{ run ["-h", "use"] }
      assert_no_diff(exp, act)
    end
  end



  class OptsMock
    include OptparseLite::OptsLike
    def initialize(sexp); @sexp = sexp end
    def doc_sexp;         @sexp; end
    def syntax_tokens
      @sexp.select{|x| x.first==:opt}.map{|x| x[1]}
    end
  end

  class BannerTime
    include OptparseLite

    opts OptsMock.new([
      [:hdr, 'Eric Banner:'],
      [:opt, '--foo, -Bar', 'some opt desc'],
      [:opt, '-foobric', 'another'],
      [:txt, 'multiline description that is'],
      [:txt, 'not a banner:'],
      [:opt, '--stanley','foobric'],
      [:txt,'this is desc'],
      [:hdr,'This is banner:'],
      [:opt, '-a,-b','bloofis goofis']
    ])
    def fix_desc opts, a, b=nil
    end
  end
  BannerTime.spec.invocation_name = "banner-time-app.rb"

  describe BannerTime do
    it 'banner-time-app.rb must work' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m banner-time-app.rb fix-desc [--foo, -Bar] [-foobric] [--stanley] [-a,-b] <arg1> [<arg2>]
        \e[32;mEric Banner:\e[0m
          --foo, -Bar    some opt desc
             -foobric    another
        multiline description that is
        not a banner:
            --stanley    foobric
        this is desc
        \e[32;mThis is banner:\e[0m
                -a,-b    bloofis goofis
      HERE
      act = _run{ run ["-h", "fix"] }
      assert_no_diff(exp, act)
    end
  end


  describe OptparseLite::OptParser do
    it "must fail on no mames param" do
      e = assert_raises(RuntimeError) do
        OptparseLite::OptParser.new{
          opt '--[no-]mames[=<joai>]'
        }.compile!
      end
      assert_match(/let's not take arguments with no- style opts/,e.message)
    end
  end


  class Finally
    include OptparseLite

    opts {
      banner 'Fun Options:'
      opt '-a, --alpha', 'desco', :foo
      opt '-b, --beta=<foo>', 'desc for beta', :fooey, 'more desc for beta'
      banner 'Eric Banner:'
      banner 'not eric banner, just some desco'
      banner 'another not banner, just some chit chat:'
      opt '--gamma[=<baz>]','gamma is where it\'s at'
      opt '--[no-]mames', :juae
    }
    def do_it opts, a, b=nil

    end
  end
  Finally.spec.invocation_name = "finally-app.rb"

  describe Finally do

    it 'finally-app.rb general help' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m finally-app.rb (do-it) [<opts>] [<args>]

        \e[32;mCommands:\e[0m
          do-it    usage: do-it [--alpha,-a] [--beta,-b=<foo>] [--gamma[=<baz>]] [--[no-]mames] <arg1> [<arg2>]
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run [] }
      assert_no_diff(exp, act)
    end

    it 'finally-app.rb command help' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m finally-app.rb do-it [--alpha,-a] [--beta,-b=<foo>] [--gamma[=<baz>]] [--[no-]mames] <arg1> [<arg2>]
        \e[32;mFun Options:\e[0m
               --alpha, -a    desco
          --beta, -b=<foo>    desc for beta
                              more desc for beta
        \e[32;mEric Banner:\e[0m
        not eric banner, just some desco
        another not banner, just some chit chat:
           --gamma[=<baz>]    gamma is where it's at
              --[no-]mames
      HERE
      act = _run{ run ["-h", "do"] }
      assert_no_diff(exp, act)
    end

    it 'finally-app.rb complains on optparse errors' do
      exp_out = <<-HERE.noindent
      HERE
      exp_err = <<-HERE.noindent
        finally-app.rb: couldn't do-it because of the following errors:
        \e[32;m--beta\e[0m requires a parameter (-b=<foo>)
        i don't recognize the parameter: \e[32;m--not\e[0m
        \e[32;m--alpha\e[0m does not take an arguement (\"yo\")
        \e[32;mUsage:\e[0m finally-app.rb do-it [--alpha,-a] [--beta,-b=<foo>] [--gamma[=<baz>]] [--[no-]mames] <arg1> [<arg2>]
        try \e[32;mfinally-app.rb\e[0m \e[32;mhelp\e[0m \e[32;mdo-it\e[0m for full syntax and usage.
      HERE
      act_out, act_err = _run2{ run ["do", "--not=an", "option", "--beta", "--alpha=yo", "--no-mames"] }
      assert_no_diff(exp_out, act_out)
      assert_no_diff(exp_err, act_err)
    end
  end

  class Raiser
    include OptparseLite

    def arg_error
      raise ArgumentError.new("this is an application-level arg error")
    end

    def rt_error
      raise RuntimeError.new("this is an application-level runtime error")
    end

    def ui_level_error arg1, arg2
    end
  end
  Raiser.spec.invocation_name = "raiser-app.rb"

  describe Raiser do

    it 'lets application level argument errors thru' do
      e = assert_raises(ArgumentError) do
        Raiser.run(%w(arg_error))
      end
      assert_match %r!arg error!, e.message
    end

    it 'lets application level runtime errors thru' do
      e = assert_raises(RuntimeError) do
        Raiser.run(%w(rt_error))
      end
      assert_match %!runtime error!, e.message
    end

    it 'rescues argument errors to the controller methods' do
      exp_out = <<-HERE.noindent
      HERE
      exp_err = <<-HERE.noindent
        raiser-app.rb: couldn't ui-level-error because of an error:
        wrong number of arguments (0 for 2)
        \e[32;mUsage:\e[0m raiser-app.rb ui-level-error <arg1> <arg2>
        try \e[32;mraiser-app.rb\e[0m \e[32;mhelp\e[0m \e[32;mui-level-error\e[0m for full syntax and usage.
      HERE
      act_out, act_err = _run2{ run ["ui-"] }
      assert_no_diff(exp_out, act_out)
      assert_no_diff(exp_err, act_err)
    end
  end

  describe OptparseLite::Np do
    it "fails on this" do
      e = assert_raises(RuntimeError) do
        OptparseLite::Np.new(:the,'thing'){}
      end
      assert_match %r!blah blah!, e.message
      e = assert_raises(RuntimeError) do
        OptparseLite::Np.new(:the,'thing',10){||}
      end
      assert_match %r!count and block mutually exclusive!, e.message
    end
  end

  class AggOpts
    include OptparseLite
    opts {
      banner 'Alpha Options:'
      opt '-a, --alpha', 'this is alpha'
      opt '-b', 'this is beta', :default=>'heh but it\'s argless'
    }
    desc "you will see this at the top above the opts? or not"
    opts {
      banner 'Gamma Options:'
      opt '-g, --gamma=<foo>', 'this is gamma',
        'multiline gamma', :default=>'great gams'
      opt '-d, --delta'
    }
    def go_with_it opts, a, b=nil
      opts = opts.merge(:first_arg=>a, :second_arg=>b)
      resp = opts.keys.map(&:to_s).sort.map{|k| [k.to_sym, opts[k.to_sym]]}
      ui.puts resp.inspect
    end
  end
  AggOpts.spec.invocation_name = "agg-opts-app.rb"

  describe AggOpts do
    it 'agg-opts-app.rb help display' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m agg-opts-app.rb go-with-it [--alpha,-a] [-b] [--gamma,-g=<foo>] [--delta,-d] <arg1> [<arg2>]
        \e[32;mAlpha Options:\e[0m
                --alpha, -a    this is alpha
                         -b    this is beta
          you will see this at the top above the opts? or not
        \e[32;mGamma Options:\e[0m
          --gamma, -g=<foo>    this is gamma
                               multiline gamma
                --delta, -d
      HERE
      act = _run{ run ["-h", "go"] }
      assert_no_diff(exp, act)
    end

    it 'agg-opts-app.rb opt validation' do
      exp_out = <<-HERE.noindent
      HERE
      exp_err = <<-HERE.noindent
        agg-opts-app.rb: couldn't go-with-it because of the following errors:
        \e[32;m--alpha\e[0m does not take an arguement (\"foo\")
        i don't recognize these parameters: \e[32;m--gamma,\e[0m and \e[32;m--digle\e[0m
        \e[32;mUsage:\e[0m agg-opts-app.rb go-with-it [--alpha,-a] [-b] [--gamma,-g=<foo>] [--delta,-d] <arg1> [<arg2>]
        try \e[32;magg-opts-app.rb\e[0m \e[32;mhelp\e[0m \e[32;mgo-with-it\e[0m for full syntax and usage.
      HERE
      act_out, act_err = _run2{ run ["go", "--digle=fingle,", "--gamma,", "--alpha=foo"] }
      assert_no_diff(exp_out, act_out)
      assert_no_diff(exp_err, act_err)
    end

    it 'agg-opts-app.rb must work' do
      exp = <<-HERE.noindent
        [[:b, \"heh but it's argless\"], [:first_arg, \"foo\"], [:gamma, \"great gams\"], [:second_arg, nil]]
      HERE
      act = _run{ run ["go", "foo"] }
      assert_no_diff(exp, act)
    end
  end


  class Sub
    include OptparseLite

    subcommands :fric, 'bric-dic', :frac
    def foo(*a)
      subcommand_dispatch(*a)
    end

  private

    usage '[<opts>] <crank-harder>'
    desc  'crank harder'
    opts {
      opt '-f', "this does blah", :accessor=>:f
    }
    def foo_fric opts, arg
      opts.merge!({:arg=>arg, :method=>:foo_fric})
      puts opts.inspect
      opts
    end

    usage '[<opts>] <somefile>'
    desc  'some awesome times'
    opts {
      opt '-b,--blah', "this does blah"
    }
    def foo_bric_dic opts, arg
      opts.merge!({:arg=>arg, :method=>:foo_bric_dic})
      puts opts.inspect
      opts
    end

    def foo_frac
    end
  end
  Sub.spec.invocation_name = "sub-app.rb"

  describe Sub do
    it 'sub-app.rb with command with no arg shows subcommand list' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m sub-app.rb foo (fric|bric-dic|frac) [<opts>] [<args>]

        \e[32;mSub Commands:\e[0m
          fric        crank harder
          bric-dic    some awesome times
          frac        usage: foo frac
        type -h after a command or subcommand name for more help
      HERE
      act = _run{ run ["foo"] }
      assert_no_diff(exp, act)
      act = _run{ run ["foo", "-h"] }
      assert_no_diff(exp, act)
    end
    it 'sub-app.rb shows help on sub-command' do
      exp = <<-HERE.noindent
        \e[32;mUsage:\e[0m sub-app.rb foo fric [-f] <crank-harder>
        \e[32;mDescription:\e[0m crank harder
          -f    this does blah
      HERE
      act = _run{ run ["foo", "-h", "fric"] }
      assert_no_diff(exp, act)
    end
  end
end
