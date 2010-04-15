module OptparseLite
  @run_enabled = true
  class << self
    def included mod
      if mod.kind_of?(Class)
        mod.extend self # only for gentest!
        mod.extend ServiceClass
        mod.init_service_class
        mod.send(:include, ServiceObject)
      else
        fail "module controller singletons not yet implemented"
      end
    end
    def suppress_run!; @run_enabled = false end
    def enable_run!; @run_enabled = true end
    def run_enabled?; @run_enabled end
  end
private
  module Lingual
  end
  module HelpHelper
  end
  class Command
    include HelpHelper
    def initialize spec, method_name, desc=nil, opts=nil, usage=nil
      @spec = spec
      @method_name = method_name
      @desc = DescriptionAndOpts.new(desc || [])
      @opt_indexes = opts || []
      @syntax_sexp = nil
      @usage = usage || []
    end
    attr_reader :desc, :usage, :method_name
    def desc_oneline
      desc.any? ? desc.first_desc_line : nil
    end
    def opts
      @opt_indexes.map{|x| @desc[x]}
    end
    def run implementor, argv
      implementor.send(method_name, *argv)
    end
    def pretty
      method_name.gsub(/_/,'-') # @todo
    end
    alias_method :pretty_full, :pretty
    # local, don't look up! (?)
    def syntax_sexp
      return @syntax_sexp unless @syntax_sexp.nil?
      # no support for union grammars yet (or evar!) (like git-branch).
      usage = @usage.any? ? @usage.join(' ') : '[<opts>] [<args>]'
      md = (/\A(\[<opts>\] *)?(.*)\Z/m).match(usage) # matches all strings
      @syntax_sexp = [cmds_sexp, opts_sexp(md[1]), args_sexp(md[2])].compact
    end
  private
    def args_sexp str
      # @todo: note that when it doesn't parse '[<opts>]' in the usage string
      # then all opts are treated as args here. so this (for now) should only
      # be used for presentation stuff (of course we could etc...)
      if /\A\s*([^\s]+(?:\s+[^\s]+)*)?\s*(?:\[<args>\]|<args>)\s*\Z/x =~ str
        args = args_sexp_children_from_arity || []
        opts = $1 ? $1.split(' ') : []
      else
        args = str.split(' ') # and of course this breaks on nested things
        opts = []
      end
      (both = opts + args).empty? ? nil : [:args, *both]
    end
    def args_sexp_children_from_arity
      arity = unbound_method.arity
      return nil if arity.zero?
      arity -= (arity > 0 ? 1 : -1) if opts.any?
      args = (0..arity.abs-1).map{|i| "<arg#{i+1}>"}
      if arity < 0
        args.last.replace("[#{args.last}]") # too bad we can't etc
      end
      args
    end
    def cmds_sexp
      [:cmds, pretty_full] # @todo later
    end
    def opts_sexp match
      return nil if @opt_indexes.empty? # no matter what u don't take options
      return nil if match.nil? # maybe want to have them but not show them?
      [:opts, *opts.map{|o| o.syntax_tokens.map{|x| "[#{x}]"}}.flatten]
    end
    def unbound_method
      @spec.unbound_method method_name
    end
  end
  class Description < Array
    class << self; def [](m); m.extend(self) end end
    def get_desc_lines
      self
    end
  end
  class DescriptionAndOpts < Array
    def initialize arr
      super(arr)
    end
    def get_desc_lines
      select{|x| x.kind_of?(String) || x.kind_of?(DocBlock)}
    end
    def any?
      detect{|x| x.kind_of?(String) || x.kind_of?(DocBlock)}
    end
    def first_desc_line
      if (one = any?)
        one.kind_of?(String) ? one : one.first_desc_line
      end
    end
  end
  module DocBlock; end
  class Dispatcher
    include HelpHelper
    def initialize impl, spec, ui
      @impl = impl
      @spec = spec
      @ui = ui
      @help = Help.new(@spec, @ui)
    end
    def run argv
      return @help.no_args         if argv.empty?
      return @help.requested(argv) if help_requested?(argv)
      if cmd = @help.find_one_loudly(argv.shift)
        cmd.run(@impl, argv)
      else
        -1 # kind of silly but whatever
      end
    end
  private
  end
  module HelpHelper
    def help_requested?(argv)
      ['-h','--help','-?','help'].include? argv[0]
    end
    def looks_like_header? line
      /\A[A-Z0-9][A-Za-z]*(?:\s[A-Za-z0-9]*)*:\s*\Z/ =~ line
    end
    def hdr(str); "\e[32;m#{str}\e[0m" end
    def txt(str); str end
    def cmd(str); str end # @todo change to underline
    alias_method :code, :hdr
  end
  class Help
    include Lingual, HelpHelper
    def initialize spec, ui
      @margin_a = '  '
      @margin_b = '    '
      @spec = spec
      @ui = ui
    end
    def find_one_loudly cmd
      all = @spec.find_all cmd
      case all.size
      when 0
        @ui.puts "i don't know how to #{code cmd}."
        invite_to_more_help
        nil
      when 1
        all.first
      else
        @ui.puts "did you mean " <<
          oxford_comma(all.map{|x| code(x.pretty)}, ' or ') << '?'
        invite_to_more_help
        nil
      end
    end
    def requested argv
      return command_help_full(argv[1], argv[2..-2]) if argv.size > 1
      app_usage
      app_description_full
      list_base_commands
    end
    def no_args
      app_usage_expanded
      app_description_full
      list_base_commands
    end
  private
    def app_description_full
      lines = @spec.app_description.get_desc_lines
      @ui.puts lines.map{|line| "#{@margin_a}#{line}"}
    end
    def app_usage_expanded
      if @spec.base_commands.empty?
        @ui.puts("#{hdr 'Usage:'} #{@spec.invocation_name}"<<
          " (this screen. no commands defined.)"
        )
      else
        @ui.puts("#{hdr 'Usage:'} #{@spec.invocation_name} ("<<
          @spec.base_commands.map{|c| c.pretty }*'|'<<
          ') [<opts>] [<args>]'
        )
      end
    end
    alias_method :app_usage, :app_usage_expanded
    def command_help_full cmd, rest
      if found = find_one_loudly(cmd)
        command_help_full_actual found, rest
      end
    end
    def command_help_full_actual cmd, rest
      command_usage cmd
      if cmd.desc.any?
        @ui.print hdr('Description:')
        lines = cmd.desc.get_desc_lines
        if lines.size == 1
          @ui.puts "  #{lines.first}"
        else
          @ui.puts "\n" << lines.map{|x| "#{@margin_a}#{x}"} * "\n"
        end
      end
      list_options(cmd) if cmd.opts.any?
    end
    def command_usage cmd
      sexp = cmd.syntax_sexp.dup # b/c of unshift below
      sexp.unshift([:cmds, @spec.invocation_name])
      @ui.puts hdr("Usage: ")+' '+stylize(sexp) # @todo fix
    end
    def invite_to_more_command_help
      @ui.puts "type -h after a command or subcommand name for more help"
    end
    def invite_to_more_help
      @ui.puts "try #{code(@spec.invocation_name + ' -h')} for help."
    end
    def list_commands cmds
      width = cmds.map{|c| c.pretty.length}.max
      cmds.each do |c|
        cmd_desc = c.desc_oneline
        cmd_desc ||= 'usage: '+stylize(c.syntax_sexp)
        @ui.puts "#{@margin_a}%-#{width}s#{@margin_b}#{cmd_desc}" % [c.pretty]
      end
    end
    def list_options cmd
      matrix = []
      cmd.opts.each do |parser|
        matrix.concat parser.doc_matrix
      end
      @ui.puts hdr('Options:') unless matrix.first[2]
      width = matrix.map{|x| x[0] ? x[0].length : nil }.compact.max
      matrix.each do |row|
        @ui.puts(looks_like_header?(row[2]) ? hdr(row[2]) : row[2]) if row[2]
        if row[0] || row[1]
          @ui.puts "#{@margin_a}%#{width}s#{@margin_b}%s" % [row[0], row[1]]
        end
      end
    end
    def list_base_commands
      cmds = @spec.base_commands
      return if cmds.empty?
      @ui.puts
      @ui.puts "#{hdr 'Commands:'}"
      list_commands cmds
      invite_to_more_command_help
    end
    def stylize sexp
      parts = []
      sexp.each do |node|      # non-empty children else xtra spaces
        case node.first
        when :cmds; parts.push node[1..-1].map{|c| cmd(c)}.join(' ')
        when :opts; parts.push node[1..-1].join(' ')
        when :args; parts.push node[1..-1].join(' ')
        end
      end
      parts * ' '
    end
  end
  module Lingual
    def oxford_comma items, sep=' and ', comma=', '
      return '()' if items.size == 0
      return items[0] if items.size == 1
      seps = [sep, '']
      seps.insert(0,*Array.new(items.size - seps.size, comma))
      items.zip(seps).flatten.join('')
    end
    def methodize mixed
      mixed.to_s.gsub(/[^a-z0-9_\?\!]/,'_')
    end
  end
  module OptsLike
    # syntax_tokens, doc_matrix
  end
  module OptsBlock
    include OptsLike
  end
  module ServiceClass
    def init_service_class
      @instance ||= nil
      @spec = Spec.new(self)
      @ui = Ui.new
    end
    attr_reader :ui, :spec
    alias_method :app, :spec
    def o usage
      @spec.usage usage
    end
    def opts mixed=nil, &block
      @spec.opts(mixed, &block)
    end
    alias_method :usage, :o
    def run argv=ARGV
      argv = argv.dup # never change caller's array
      return @ui.err.puts('run disabled. (probably for gentesting)') unless
        OptparseLite.run_enabled?
      unless @instance # rcov bug?
        obj = new
        obj.init_service_object(@spec, @ui)
        @instance = obj
      end
      @instance.run argv
    end
    def x desc
      @spec.cmd_desc desc
    end
    alias_method :desc, :x
    def method_added method_sym
      @spec.method_added_notify method_sym
    end
  end
  module ServiceObject
    def init_service_object spec, ui
      @spec = spec
      @ui = ui
      @dispatcher = Dispatcher.new(self, @spec, @ui)
    end
    def run argv
      @dispatcher.run argv
    end
    attr_accessor :ui; private :ui # avoid warnings
  end
  class Sio < StringIO
    def to_str; idx = tell; rewind; str = read; seek(idx); str end
    alias_method :to_s, :to_str
  end
  class Spec
    include Lingual
    def initialize mod
      @app_description = Description.new
      @base_commands = nil
      @commands = []
      @names = {}
      @mod = mod
      @order = []
      @desc = @opts = @spec = @usage = nil
    end
    attr_reader :app_description
    def base_commands
      @base_commands ||=
        (@order &  @mod.public_instance_methods(false)).map do |meth|
          get_command(meth)
        end
    end
    def cmd_desc desc
      @desc ||= []
      @desc.push desc
    end
    def desc mixed
      @app_description.push mixed
    end
    def find_all name
      meth = methodize(name)
      re = /^#{Regexp.escape(meth)}/
      (@order & (
        @mod.public_instance_methods(false) |
        @commands.map{|x| x.method_name }
      )).grep(re).map do |n|
        if n == meth
          return [get_command(n)]
        else
          get_command(n)
        end
      end
    end
    attr_writer :invocation_name
    def invocation_name
      @invocation_name ||= File.basename($PROGRAM_NAME)
    end
    def method_added_notify meth
      meth = meth.to_s
      @order.push meth
      if @desc || @opts || @usage
        @names[meth] = @commands.length
        @commands.push Command.new(self, meth, @desc, @opts, @usage)
        @desc = @opts = @usage = nil
      end
    end
    def opts mixed=nil, &block
      @desc ||= []
      @opts ||= []
      fail("can't take block and arg") if mixed && block
      if block
        mixed = OptParser.new(&block)
      else
        fail("opts must be OptsLike") unless mixed.kind_of?(OptsLike)
      end
      @opts.push @desc.size
      @desc.push mixed
    end
    def unbound_method method_name
      @mod.instance_method method_name
    end
    def usage usage
      @usage ||= []
      @usage.push usage
    end
  private
    def get_command meth
      @names[meth] ? @commands[@names[meth]] : begin
        @names[meth] = @commands.length
        cmd = Command.new(self, meth)
        @commands.push cmd
        cmd
      end
    end
  end
  class Ui
    def initialize
      @out = $stdout
      @err = $stderr
    end
    attr_accessor :err

    %w(print puts).each do |meth|
      define_method(meth){|*a| @out.send(meth,*a) }
    end

    def push io=Sio.new
      @stack ||= []
      @stack.push @out
      @out = io
    end
    def pop
      ret = @out
      @out = @stack.pop
      ret
    end
  end
end

# temporary? as minimal as reasonable option parsing below
module OptparseLite
  module ReExtra
    # consumes string, allows for named captures
    class << self
      def[](re,*names)
        re.extend(self)
        re.names = names
        re
      end
    end
    attr_accessor :names
    def parse str
      if md = match(str)
        caps = md.captures
        str.replace str[md.offset(0)[1]..-1]
        sing = class << caps; self end
        names.each_with_index{|(n,i)| sing.send(:define_method,n){self[i]}}
        caps
      end
    end
  end
  class OptParser
    def initialize(&block)
      @block = block
      @compiled = false
      @items = []
      @names = {}
      @specs = []
    end
    def compile!
      instance_eval(&@block)
      @compiled = true
    end
    def doc_matrix
      matrix = []
      @items.each do |item|
        if OptSpec===item
          matrix.push [item.syntax_tokens*', ', item.desc.first]
          matrix.concat(item.desc[1..-1].map{|x| [nil,x]}) if item.desc.size>1
        else
          matrix.push [nil,nil,item]
        end
      end
      matrix
    end
    def specs
      compile! unless @compiled
      @specs.map{|idx| @items[idx]}
    end
    def syntax_tokens
      specs.map{|x| x.syntax_tokens * ','}
    end
  private
    def banner str
      @items.push str
    end
    def opt syntax, *extra
      spec = OptSpec.parse(syntax)
      opts = extra.last.kind_of?(Hash) ? extra.pop : {}
      unless opts[:accessor]
        idxs = extra.each_with_index.map{|(m,i)| Symbol===m ? i : nil}.compact
        fail("can't have more than one symbol in definition") if idxs.size > 1
        opts[:accessor] = extra.slice!(idxs.first) if idxs.any?
      end
      spec.desc = extra
      spec.names.each do |name|
        fail("won't redefine existing opt name \"#{name}\"") if @names[name]
        @names[name] = @specs.size
      end
      @specs.push @items.size
      @items.push spec
    end
  end
  class OptSpec < Struct.new(:names, :takes_argument, :required,
    :optional, :arg_name, :short, :long, :noable, :desc, :accessor)
    alias_method :required?, :required
    alias_method :optional?, :optional
    alias_method :takes_argument?, :takes_argument
    # def name
    #   long.any? ? long.first : short.first
    # end
    @short_long = ReExtra[
      /\A *(?:-([a-z0-9])|--(?:\[(no-)\])?([a-z0-9][-a-z0-9]+)) */i,
               :short,           :no,      :long
    ]
    required = /   (= \s*     (?:  <[a-z_][-a-z_]*>  |  [A-Z_]+  ) ) \s* /x
    optional = /(\[\s* = \s*  (?:  <[a-z_][-a-z_]*>  |  [A-Z_]+  ) \] ) \s* /x
    @param = ReExtra[Regexp.new(
      '\A' + [required.source,optional.source].join('|'), Regexp::EXTENDED
    )]
    @param.names=[:required, :optional]
    class << self
      extend Lingual
      def parse str
        names, reqs, opts, short, long, noable, caps = [],[],[],[],[], nil,nil
        str.split(/, */).each do |syn|
          failed(str.inspect) unless caps = @short_long.parse(syn)
          names.push(caps.short || caps.long)
          long.push "--#{caps.long}" if caps.long
          short.push "-#{caps.short}" if caps.short
          if caps.no
            failed("i dunno can u say no multiple times?") if noable
            noable = caps.no
            this = "#{caps.no}#{caps.long}"
            long.push "--#{this}"
            names.push this
          end
          if caps = @param.parse(syn)
            (caps.required ? reqs : opts).push(caps.required || caps.optional)
          end
          failed("don't know how to parse: #{syn.inspect}") unless syn.empty?
        end
        failed("can't have both required and optional arguments: "<<
          str.inspect) if reqs.any? && opts.any?
        arg_names = opts | reqs
        failed("let's not take arguments with no- style opts") if
          noable && arg_names.any?
        failed("spell the argument the same way each time: "<<
          oxford_comma(arg_names)) if arg_names.length > 1
        new(names, opts.any? || reqs.any?,
          reqs.any?, opts.any?, arg_names.first, short, long, noable)
      end
    private
      def failed msg
        fail("parse parse fail: bad option syntax syntax: #{msg}")
      end
    end # class << self
    def syntax_tokens
      if noable
        ["--[#{noable}]#{names.first}"]
      else
        these = long + short
        these[these.length-1] = "#{these.last}#{arg_name}"
        these
      end
    end
  private
  end
end
