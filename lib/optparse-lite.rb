require 'singleton'
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
  # forward declarations (as everything is in alphabetical order):
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
    attr_reader :desc, :usage, :method_name, :spec
    def desc_oneline
      desc.any? ? desc.first_desc_line : nil
    end
    def doc_sexp
      common_doc_sexp @desc, :bdy
    end
    def opts
      @opt_indexes.map{|x| @desc[x]}
    end
    def process_opt_parse_errors resp, opts={}
      opts = {opts=>true} if opts.kind_of?(Symbol)
      ui = @disp.ui.err
      ui.puts "#{prefix}couldn't #{cmd(pretty)} because of "<<
        Np.new(proc{|b| b ? 'the following' : 'an'},'error',resp.size)
      ui.puts resp
      @disp.help.command_usage self, ui if opts[:show_usage]
      @disp.help.invite_to_more_command_help_specific self, ui
      return -1
    end
    def run disp, argv
      @disp = disp
      opts = nil
      if parser = get_parser
        resp, opts = parser.parse(argv)
        return process_opt_parse_errors(resp, :show_usage) if resp.errors.any?
      end
      argv.unshift(opts) if opts
      resp = nil
      begin
        resp = disp.impl.send(method_name, *argv)
      rescue ArgumentError => e
        if one_of_ours(e)
          return process_opt_parse_errors [e.message], :show_usage
        else
          raise e
        end
      end
      resp
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
    def get_parser
      case opts.size
      when 0; nil
      when 1; opts.first
      else OptParserAggregate.new(opts)
      end
    end
    # hack to see where the exception orignated
    def one_of_ours e
      e.backtrace.first.index(__FILE__)
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
    def any?
      detect{|x| x.kind_of?(String) || x.kind_of?(DocBlock)}
    end
    def get_desc_lines
      select{|x| x.kind_of?(String) || x.kind_of?(DocBlock)}
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
    # commands need some or all of these
    attr_reader :impl, :spec, :ui, :help
    def run argv
      return @help.no_args         if argv.empty?
      return @help.requested(argv) if help_requested?(argv)
      if cmd = @help.find_one_loudly(argv.shift)
        cmd.run(self, argv)
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
    def prefix; "#{spec.invocation_name}: " end
    def txt(str); str end
    def cmd(str); str end # @todo change to underline
    alias_method :code, :hdr
  private
    def common_doc_sexp items, txt_type=:txt
      items.map{ |x| x.respond_to?(:doc_sexp) ? x.doc_sexp :
        looks_like_header?(x) ? [[:hdr, x]] : [[txt_type, x]]
      }.flatten(1)
    end
  end
  class Help
    include Lingual, HelpHelper
    def initialize spec, ui
      @margin_a = '  '
      @margin_b = '    '
      @spec = spec
      @ui = ui
    end
    def command_usage cmd, ui=@ui
      sexp = cmd.syntax_sexp.dup # b/c of unshift below
      sexp.unshift([:cmds, @spec.invocation_name])
      ui.puts hdr('Usage:')+'  '+stylize_syntax(sexp) # @todo fix
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
    def invite_to_more_command_help_specific cmd, ui=@ui
      ui.puts("try #{code(@spec.invocation_name)} #{code('help')} "<<
        "#{code(cmd.pretty_full)} for full syntax and usage.")
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
      @ui.print("#{hdr 'Usage:'} #{@spec.invocation_name}")
      if @spec.base_commands.empty?
        @ui.puts(" (this screen. no commands defined.)")
      else
        @ui.puts(' ('<<@spec.base_commands.map{|c| c.pretty }*'|'<<
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
    def command_help_full_actual cmd, _
      command_usage cmd
      sexp = cmd.doc_sexp.dup
      if sexp.any?
        case sexp.first.first
        when :opt;        sexp.unshift([:hdr, 'Options:'])
        when :bdy, :txt;  sexp.unshift([:hdr, 'Description:'])
        end
      end
      stylize_docblock sexp, @ui
    end
    def invite_to_more_command_help_general
      @ui.puts "type -h after a command or subcommand name for more help"
    end
    def invite_to_more_help
      @ui.puts "try #{code(@spec.invocation_name + ' -h')} for help."
    end
    def list_commands cmds
      width = cmds.map{|c| c.pretty.length}.max
      cmds.each do |c|
        cmd_desc = c.desc_oneline
        cmd_desc ||= 'usage: '+stylize_syntax(c.syntax_sexp)
        @ui.puts "#{@margin_a}%-#{width}s#{@margin_b}#{cmd_desc}" % [c.pretty]
      end
    end
    def list_base_commands
      cmds = @spec.base_commands
      return if cmds.empty?
      @ui.puts
      @ui.puts "#{hdr 'Commands:'}"
      list_commands cmds
      invite_to_more_command_help_general
    end
    class SexpWrapper # hack so you can access .first on nil nodes
      class NilSexpClass; include Singleton; def first; nil end end
      NilSexp = NilSexpClass.instance
      def initialize(sexp); @sexp = sexp end
      def each_with_index(*a, &b); @sexp.each_with_index(*a, &b); end
      def [](idx); it = @sexp[idx] and it or NilSexp; end
    end
    def stylize_docblock sexp, ui=@ui
      matrix = stylize_docblock_first_pass sexp
      width = matrix.map{|x|(Array===x&&x[0])?x[0].length : nil}.compact.max
      matrix.each do |row|
        case row
        when String; ui.puts row
        when Array;
          ui.print "#{@margin_a}%#{width}s" % row[0] # should be ok on nil
          ui.puts row[1] ? "#{@margin_b}#{row[1]}" : "\n"
        end
      end
    end
    def stylize_docblock_first_pass sexp
      idx, last = 0, sexp.size-1
      sexp = SexpWrapper.new(sexp)
      matrix = [] # two-pass rendering to line up columns
      while idx <= last
        node = sexp[idx]
        case node.first
        when :hdr
          matrix.push hdr(node[1])
          if sexp[idx+1].first == :bdy && sexp[idx+2].first != :bdy
            matrix.last.concat " #{sexp[idx+1][1]}"
            idx += 1 # special case: only one line of txt on same line as hdr
          end
        when :bdy; matrix.push "#{@margin_a}#{node[1]}"
        when :txt; matrix.push node[1]
        when :opt
          matrix.push [node[1], node[2]]  # multiline opt docs:
          matrix.concat node[3..-1].map{|x| [nil, x]} if node[3]
        end
        idx += 1
      end
      matrix
    end
    def stylize_syntax sexp
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
    # syntax_tokens
  end
  module OptsBlock
    include OptsLike
  end
  module ServiceClass
    def init_service_class
      @instance ||= nil
      @spec = AppSpec.new(self)
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
  class AppSpec
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

    def push out=Sio.new, err=Sio.new
      @stack ||= []
      @stack.push [@out, @err]
      @out, @err = out, err
    end

    def pop both=false
      ret = [@out, @err]
      @out, @err = @stack.pop
      return ret if both
      return ret[0] if ret[1].respond_to?(:to_str) && ''==ret[1].to_str
      # ret # ick. tries to pretend there is only one out stream when possible
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
  module OptHelper
    def dashes key # hack, could be done in spec instead somehow
      key.length == 1 ? "-#{key}" : "--#{key}"
    end
  end
  class OptParser
    include OptHelper, HelpHelper
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
    def doc_sexp
      compile! unless @compiled
      common_doc_sexp @items
    end
    def parse argv
      opts = parse_argv argv
      resp = validate_and_populate(opts)
      [resp, opts]
    end
    def specs
      compile! unless @compiled
      @specs.map{|idx| @items[idx]}
    end
    def syntax_tokens
      specs.map{|x| x.syntax_tokens * ','}
    end
    # @return [Response], alter opts
    # this does the following: for all unrecognized opts, add one error
    # (one error encompases all of them), populate defaults, normalize
    # them either to the accessor or last long or last short surface form
    # with a symbol key (maybe), make sure that opts that don't take parameter
    # don't have them and opts that require them do.
    def validate_and_populate opts
      compile! unless @compiled
      resp = Response.new
      sing = class << opts; self end
      specs = self.specs
      opts.keys.each do |key|
        val = opts.delete(key) # easier just to do this always
        if ! @names.key?(key)
          resp.unrecognized_parameter(key, val)
        else
          spec = specs[@names[key]]
          if spec.required? && val == true
            resp.required_argument_missing(spec, key)
          elsif val != true && ! spec.takes_argument?
            resp.argument_not_allowed(spec, key, val)
          else  # if resp.valid? (aggregate parses.. @todo)
            opts[spec.normalized_key] = val
            if spec.accessor
              acc = spec.accessor
              sing.send(:define_method, spec.accessor){ self[acc] }
            end
          end
        end
      end
      these = specs.map{|s| s.has_default? ? s.normalized_key : nil }.compact
      employ = these - opts.keys
      employ.each{|k| opts[k]=specs.detect{|s| s.normalized_key == k}.default}
      resp
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
      spec.default = opts[:default] if opts.key?(:default)
      spec.desc = extra
      spec.names.each do |name|
        fail("won't redefine existing opt name \"#{name}\"") if @names[name]
        @names[name] = @specs.size
      end
      @specs.push @items.size
      @items.push spec
    end
    def parse_argv argv
      options = []; not_opts = []
      argv.each{ |x| (x =~ /^-/ ? options : not_opts).push(x) }
      opts = Hash[* options.map do |flag|
        key,value = flag.match(/\A([^=]+)(?:=(.*))?\Z/).captures
        [key.sub(/^--?/, ''), value.nil? ? true : value ]
      end.flatten]
      argv.replace not_opts
      opts
    end
    class Response < Array
      include OptHelper, HelpHelper
      def initialize
        @memoish = {}
      end
      def [] sym
        return super(sym) unless sym.kind_of?(Symbol)
        res = all(sym)
        case res.size
        when 0; nil
        when 1; res[0]
        else fail("Multiple results for #{sym.inspect}")
        end
      end
      def all sym
        all_indexes(sym).map{|x| self[x]}
      end
      def all_indexes sym
        each_with_index.map{|(v,i)| v.error_type == sym ? i : nil }.compact
      end
      def argument_not_allowed spec, key, val
        push Error.new(:argument_not_allowed,
         code(dashes(key))<<" does not take an arguement (#{val.inspect})",
         :norm_key => spec.normalized_key)
      end
      def delete sym
        idxs = all_indexes(sym)
        case idxs.size
        when 0; nil
        when 1; delete_at(idxs.first)
        else; fail("Multiple results for #{sym.inspect}")
        end
      end
      def errors; self  end
      def required_argument_missing spec, key
        push Error.new(:required_argument_missing,
          code(dashes(key))<<" requires a parameter ("<<
          "#{spec.cannonical_name})",
          :norm_key => spec.normalized_key)
      end
      def unrecognized_parameter key, value
        memoish(:unrec_param){ UnparsedParamters.new }[key] = value
      end
      def valid?; empty? end
    private
      def memoish(name, &block)
        return self[@memoish[name]] if @memoish.key? name
        @memoish[name] = size
        push block.call
        last
      end
    end
    module Error;
      attr_accessor :error_type
      class << self
        def [](mixed)
          mixed.extend(self)
        end
        def new error_type, message, opts={}
          ret = self[message.dup]
          ret.error_init error_type, opts
          ret
        end
      end
      def error_init error_type, opts
        @error_type = error_type
        opts.each do |(k,v)|
          instance_variable_set("@#{k}", v)
          def!(k){instance_variable_get("@#{k}")}
        end
      end
    private
      def def! name, &block
        class << self; self end.send(:define_method, name, &block)
      end
    end
    class UnparsedParamters < Hash
      include Error, OptHelper, HelpHelper
      def initialize
        @error_type = :unparsed_parameters
      end
      def to_s
        "i don't recognize "<<
          Np.new(:this, 'parameter'){|| keys.map{|x| code(dashes(x)) }}
      end
    end
  end
  # we take this opportunity to discover our interface for parsers:
  # parse()
  class OptParserAggregate
    def initialize parsers
      @parsers = parsers
    end
    def parse args
      errors, opts = @parsers.first.parse(args)
      @parsers[1..-1].each do |parser|
        unparsed = errors.delete(:unparsed_parameters) or break
        errors.concat parser.validate_and_populate(unparsed)
        opts.merge! unparsed
      end
      [errors, opts]
    end
  end
  class OptSpec < Struct.new(:names, :takes_argument, :required,
    :optional, :arg_name, :short, :long, :noable, :desc, :accessor, :default)
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
    def cannonical_name
      syntax_tokens.last
    end
    def doc_sexp
      [[:opt, syntax_tokens*', ', * desc]]
    end
    def has_default?
      ! default.nil? # whatever. i don't care about nil defaults
    end
    def normalized_key
      accessor ? accessor.to_sym : names.last.to_sym
    end
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
  class Np
    # Noun Phrase. silly cute extraneous way to do plurals
    # this was toned down from previous versions, can be expanded
    # it is half mock now
    include Lingual
    class << self
      alias_method :[], :new
    end
    def initialize art, root, count=nil, &block
      fail('blah blah for now') if block_given? && ! block.arity.zero?
      fail('count and block mutually exclusive, one required') unless
        1 == [count, block].compact.size
      @art, @root, @block, @count, @list = art, root, block, count, nil
    end
    def to_str
      [ surface_article,
        surface_root,
        surface_items ].compact.join(' ')
    end
    alias_method :to_s, :to_str
  private
    def list
      @block and @list ||= @block.call
    end
    def many?
      @count ||= list.size
      @count != 1
    end
    def surface_article
      @art.kind_of?(Proc) ? @art.call(many?) :
        many? ? 'these' : 'the'
    end
    def surface_items
      oxford_comma(list) if list
    end
    def surface_root
      many? ? "#{@root}s:" : "#{@root}:"  # colons will be annoying
    end
  end
end
