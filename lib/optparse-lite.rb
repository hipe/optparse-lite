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
        puts "not implemented"
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
    end
    def desc_oneline
      desc.any? ? desc.first : usage.any? ? usage.first :
      opts.any? ? opts.first.desc_oneline : usage_from_arity
    end
    def pretty
      method_name.gsub(/_/,'-')
    end
  private
    def unbound_method
      spec.unbound_method method_name
    end
    def usage_from_arity
      arity = unbound_method.arity
      arity -= (arity > 0 ? 1 : -1) if opts.any?
      args = (0..arity.abs-1).map{|i| "<arg#{i+1}>"}
      if arity < 0
        args.last.replace("[#{args.last}]") # too bad we can't etc
      end
      args = args.any? ? (' ' + args * ' ') : nil
      optz = opts.any? ? "<opts>" : nil
      "#{hdr 'Usage:'} " << [pretty, optz, args].compact.join(' ')
    end
  end
  class Description < Array
    def get_lines
      self
    end
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

    end
    def no_args
      app_usage_expanded
      app_description_full
      list_base_commands
    end
    def general
      app_usage
      app_description_full
      list_base_commands
    end
  private
    def app_description_full
      lines = @spec.app_description.get_lines
      @ui.puts lines
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
        @ui.puts("#{hdr 'Usage:'} #{@spec.invocation_name} {"<<
          oxford_comma(@spec.base_commands.map{|c| c.pretty },' | ')<<
          '} [<opts>] [<args>]'
        )
      end
    end
    def invite_to_more_command_help
      @ui.puts "type -h after a command or subcommand name for more help"
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
    def list_base_commands
      cmds = @spec.base_commands
      return if cmds.empty?
      @ui.puts
      @ui.puts "#{hdr 'Commands:'}"
      list_commands cmds
      invite_to_more_command_help
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
    def o usage
      @spec.usage usage
    end
    def run argv=ARGV.dup
      unless OptparseLite.run_enabled?
        $stderr.puts('run disabled. (probably for gentesting)')
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
      @spec.desc desc
    end
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
    def desc desc
      @desc ||= []
      @desc.push desc
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
    end
    def push io=Sio.new
      @stack ||= []
      @stack.push @out
      @out = io
    end
    def puts *a
      @out.puts(*a)
    end
    def pop
      ret = @out
      @out = @stack.pop
      ret
    end
  end
end
