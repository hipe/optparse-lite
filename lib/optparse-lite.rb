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
  class Command < Struct.new(:spec, :method_name, :desc, :opts, :usage)
    include HelpHelper
    def initialize *a
      super(*a)
      self.desc  ||= []
      self.opts  ||= []
      self.usage ||= []
      Descriptive[self.desc]
    end
    def args_usage_from_arity
      arity = unbound_method.arity
      arity -= (arity > 0 ? 1 : -1) if opts.any?
      args = (0..arity.abs-1).map{|i| "<arg#{i+1}>"}
      if arity < 0
        args.last.replace("[#{args.last}]") # too bad we can't etc
      end
      args.any? ? (args * ' ') : nil
    end
    def desc_oneline
      desc.any? ? desc.first : usage.any? ? usage_oneline_short :
      opts.any? ? opts.first.desc_oneline : usage_from_arity_short
    end
    def pretty
      method_name.gsub(/_/,'-')
    end
    alias_method :pretty_full, :pretty
  private
    def unbound_method
      spec.unbound_method method_name
    end
    def usage_from_arity_short
      args = args_usage_from_arity
      optz = opts.any? ? "<opts>" : nil
      'usage: ' << [pretty, optz, args].compact.join(' ')
    end
    def usage_oneline_short
      "usage: #{spec.invocation_name} #{pretty_full} " << (usage * ' ')
    end
  end
  module Descriptive
    class << self; def [](m); m.extend(self) end end
    def get_lines
      self
    end
  end
  class Description < Array
    include Descriptive
  end
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
      puts "ok, running"
    end
  private
  end
  module HelpHelper
    def help_requested?(argv)
      ['-h','--help','-?'].include? argv[0]
    end
    def hdr(str); "\e[32;m#{str}\e[0m" end
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
      lines = @spec.app_description.get_lines
      @ui.puts lines.map{|line| "#{@margin_a}#{line}"}
    end
    def app_usage
      @ui.puts "#{hdr 'Usage:'} #{@spec.invocation_name} "<<
        "<command> [<opts>] [<args>]"
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
    def command_help_full cmd, rest
      all = @spec.find_all cmd
      case all.size
      when 0
        @ui.puts "i don't know how to #{code cmd}."
        invite_to_more_help
      when 1
        command_help_full_actual all.first, rest
      else
        @ui.puts "did you mean " <<
          oxford_comma(all.map{|x| code(x.pretty)}, ' or ') << '?'
        invite_to_more_help
      end
    end
    def command_help_full_actual cmd, rest
      command_usage cmd
      if cmd.desc.any?
        @ui.print hdr('Description:')
        lines = cmd.desc.get_lines
        if lines.size == 1
          @ui.puts "  #{lines.first}"
        else
          @ui.puts "\n" << lines.map{|x| "#{@margin_a}#{x}"}
        end
      end
      list_options(cmd) if cmd.opts.any?
    end
    def command_usage cmd
      @ui.print hdr("Usage: ") <<
        " #{@spec.invocation_name} #{cmd.pretty_full}"
      if cmd.usage.any?
        @ui.puts opts_interpolate(cmd, cmd.usage * ' ')
      else
        @ui.puts(
          [ cmd.opts.any? ? opts_string(cmd) : nil,
            cmd.args_usage_from_arity
          ].compact.join(' ')
        )
      end
    end
    def invite_to_more_command_help
      @ui.puts "type -h after a command or subcommand name for more help"
    end
    def invite_to_more_help
      @ui.puts "try #{code(@spec.invocation_name + ' -h')} for help."
    end
    def list_commands cmds
      width = cmds.map{|c| c.pretty.length}.max +
        @margin_a.length + @margin_b.length
      cmds.each do |c|
        @ui.puts sprintf(
          "#{@margin_a}%-#{width}s#{@margin_b}#{c.desc_oneline}",c.pretty
        )
      end
    end
    def list_options cmd
      matrix = []
      cmd.opts.each do |parser|
        parser.doc_matrix matrix
      end
      unless matrix.first[2]
        @ui.puts hdr('Options:')
      end
      width = matrix.map{|x| x[0] ? x[0].length : nil }.compact.max
      matrix.each do |row|
        @ui.puts hdr(row[2]) if row[2]
        if @row[0] || @row[1]
          @ui.puts sprintf(
            "#{@margin_a}%#{width}s#{@margin_b}%s", [@row[0], @ros[1]]
          )
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
    def opts_interpolate cmd, string
      string.gsub('#{opts}'){|x| opts_string(cmd)}
    end
    def opts_string cmd
      cmd.opts.map{|o| o.sytax_tokens}.flatten.join(' ')
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
  module OptsBlock
  end
  module ServiceClass
    def init_service_class
      @spec = Spec.new(self)
      @ui = Ui.new
    end
    attr_reader :ui, :spec
    alias_method :app, :spec
    def o usage
      @spec.usage usage
    end
    alias_method :usage, :o
    def run argv=ARGV.dup
      unless OptparseLite.run_enabled?
        @ui.err.puts('run disabled. (probably for gentesting)')
        return
      end
      @instance ||= begin
        obj = new
        obj.init_service_object(@spec, @ui)
        obj
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
      @spec = @usage = @opts = nil
    end
    attr_reader :app_description
    def base_commands
      @base_commands ||= begin
        (@order &  @mod.public_instance_methods(false)).map do |meth|
          get_command(meth)
        end
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
      re = /^#{Regexp.escape(name)}/
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
    def opts &block
      @desc ||= []
      @desc.push OptsBlock.extend(block)
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
