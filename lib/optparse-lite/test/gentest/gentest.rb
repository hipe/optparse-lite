module Hipe; end
module Hipe::GenTest
  extend self # cheap way to get module_function s from everything

  def gentest argv
    argv = argv.dup
    @both = false
    process_opts(argv) if /^-/ =~ argv.first
    @service_controller = deduce_services_controller
    @ui = Hipe::IndentingStream.new($stdout,'')
    file = argv.shift
    mod = deduce_module_from_file file
    mod.spec.invocation_name = File.basename(file)
    get_actuals mod, argv
    @ui.indent!.indent!
    go_app(mod, file)
    go_desc(mod, file) do
      go_exp
      go_act(mod, argv)
    end
    exit(0) # rake is annoying
  end

private

  def assert_filename mod, file
    name = no_ext(file)
    shorter = name.split('-')[0..-2].join('-')
    chemaux = camelize(shorter)
    unless chemaux == mod.to_s
      fail("expecting the module (\"#{mod}\") defined in "<<
        "\"#{File.basename(file)}\" with extension-free basename "<<
        "\"#{shorter}\" "<<
        "to define an app called #{chemaux}, not #{mod}, so please "<<
        "name the file \"#{uncamelize(mod.to_s)}-app.rb\" or change the "<<
        "name of the module from \"#{mod}\" to \"#{chemaux}\""
      )
    end
  end

  def camelize str
    str.gsub(/(?:^|-)(.)/){|x| $1.upcase}
  end

  def uncamelize str
    str.gsub(/([a-z])([A-Z])/){|x| "#{$1}-#{$2}"}.downcase
  end

  def deduce_module_from_file file
    before = Object.constants;
    @service_controller.suppress_run!
    require file
    @service_controller.enable_run!
    diff = Object.constants - before
    go_diff diff, file
  end

  def deduce_services_controller
    # this is a ridiculous attempt to avoid hard-coding the name of
    # the services module for use in disabling service applications.
    # It wants the thing to be in only one file in /lib/, and it deduces
    # the module name from the filename.  (note this is for the 'base module'
    # library module that serves this crap, this is not the application service itself.)
    #
    dir = File.expand_path('../../../..',__FILE__)
    it = Dir["#{dir}/*.rb"]
    fail("no '*.rb' files in dir \"#{dir}\"") if it.size == 0
    fail("too many files in #{dir}: "+it.map{|x| File.basename(x)}*',') if
      it.size != 1
    it = it.first
    it = camelize(no_ext(it))
    mod = Object.const_get(it)
    fail("Couldn't find module #{it}") unless mod
    mod
  end

  def get_actuals mod, argv
    if @both
      @act_out, @act_err = run2(mod){ run argv }
    else
      @act = run(mod){ run argv }
    end
  end

  def go_desc(mod, file)
    @ui.puts "describe #{mod} do"
    @ui.indent!.puts("it '#{File.basename(file)} must work' do").indent!
    yield
    @ui.dedent!.puts('end').dedent!.puts('end')
  end

  def go_diff diff, file
    if diff.empty?
      fail("sorry, hack didn't work. No new top-level constants"<<
        "were added by #{file}"
      )
    end
    svc = @service_controller
    these = diff.map do |name|
      const = Object.const_get(name)
      (const.kind_of?(Module) && const.kind_of?(svc)) ? const : nil
    end.compact
    case these.size;
    when 0:
      fail("Couldn't find any classes or modules that were #{svc} among "<<
        diff.join(' or ')
      )
    when 1; mod = these.first
    else
      fail("#{const.join(' and ')} are #{svc}s in that file.  "<<
      "I need only one to generate something."
    )
    end
    assert_filename(mod, file)
    mod
  end

  def go_act mod, args
    return go_act2(mod, args) if @both
    @ui.puts("act = _run{ run #{args.inspect} }")
    @ui.puts('assert_no_diff(exp, act)')
  end

  def go_act2 mod, args
    @ui.puts("act_out, act_err = _run2{ run #{args.inspect} }")
    @ui.puts('assert_no_diff(exp_out, act_out)')
    @ui.puts('assert_no_diff(exp_err, act_err)')
  end

  def go_app mod, file
    @ui.puts File.read(file).split("\n")[2..-3]
    @ui.puts("#{mod}.spec.invocation_name = "<<
      "#{mod.spec.invocation_name.inspect}")
    @ui.puts
  end

  def go_exp
    return go_exp2 if @both
    act = @act
    @ui.puts('exp = <<-HERE.noindent')
    @ui.indent!
    @ui.puts act.to_s.inspect.gsub('\n',"\n").gsub(/(\A"| *"\Z)/,'')
    @ui.dedent!
    @ui.puts 'HERE'
  end

  def go_exp2
    act_out, act_err = @act_out, @act_err
    @ui.puts('exp_out = <<-HERE.noindent')
    @ui.indent!
    @ui.puts act_out.to_s.inspect.gsub('\n',"\n").gsub(/(\A"| *"\Z)/,'')
    @ui.dedent!
    @ui.puts 'HERE'
    @ui.puts('exp_err = <<-HERE.noindent')
    @ui.indent!
    @ui.puts act_err.to_s.inspect.gsub('\n',"\n").gsub(/(\A"| *"\Z)/,'')
    @ui.dedent!
    @ui.puts 'HERE'
  end

  def no_ext str
    File.basename(str).match(/^(.*)\.rb$/)[1]
  end

  def process_opts argv
    fail("expecting '--out=2', not #{argv.first}") unless
      /^--out=2$/ =~ argv.first
    @both = true
    argv.shift
    nil
  end

  def run mod, &block
    mod.ui.push
    _ = mod.instance_eval(&block)
    mod.ui.pop
  end

  def run2 mod, &block
    mod.ui.push
    _ = mod.instance_eval(&block)
    mod.ui.pop(true)
  end
end

module Hipe::GenTest
  def ungentest_list test_file
    ungen(test_file).list
  end
  def ungentest test_file, chunk_name
    ungen(test_file).ungen chunk_name
  end
  def ungen test_file
    Ungen.new(test_file)
  end
  class Ungen
    def initialize test_file
      @test_file = test_file
      @ui = $stdout
    end
    def list
      tree = parse_file @test_file
      @ui.puts tree.chunk_names
    end
    def ungen name
      @tree = parse_file @test_file
      name = find_one_loudly name
      return unless name
      lines = @tree.get_code_lines(name)
      lines.map!{|x| x.gsub(/^  /,'') }
      @ui.puts lines
    end
  private
    def find_one_loudly name
      re = /^#{Regexp.escape(name)}/
      items = @tree.chunk_names.grep(re)
      if items.size != items.uniq.size
        fail("can't work with multiple entries of the same name in list: "<<
          items.map{|x| "\"#{x}\""}.join(', ')
        )
      end
      if items.size == 0
        @ui.puts("coudn't find any items matching \"#{name}\" in list.  "<<
          "please see -list for list of available items"
        )
        return
      end
      if items.size > 1
        if items.include? name
          return name
        else
          @ui.puts("which one did you mean? "<<items.join(' or '))
          return
        end
      end
      return items.first
    end
    def parse_file test_file
      Indexes.new(test_file)
    end
    class Indexes < Array
      def initialize test_file
        fail("file not found: #{test_file}") unless File.exist?(test_file)
        lines = File.read(test_file).split("\n")
        class << self; self end.send(:define_method, :lines){lines}
        lines.each_with_index do |line, idx|
          case line
          when /^  class ([a-z0-9:]+)/i;    push [:class, idx, $1]
          when /^  module ([a-z0-9:]+)/i;   push [:module, idx, $1]
          when /^  describe\b/; push [:describe, idx]
          when /^ +it '([a-z0-9]+(?:-[a-z0-9]+)*-app\.rb)/
            if last && last[2] != $1
              push [:it, idx, $1]
            end
          end
        end
      end
      def chunk_names
        select{|x| x.first == :it }.map{|x| x[2]}
      end
      def get_code_lines name
        start_offset, end_offset = get_offsets name
        lines = self.lines[start_offset..end_offset]
        # the below two are the only really optparselite-specific things here
        lines.unshift "require 'optparse-lite' unless defined? OptparseLite"
        lines.unshift "#!/usr/bin/env ruby"
        lines.push "  #{@last_mod}.run" if @last_mod
        lines
      end
      def get_offsets name
        idx = index{|x| x.first==:it && x[2]==name}
        inf = self[idx]
        fail("no") unless self[idx-1].first == :describe
        # the last line of the chunk before the describe
        end_offset = self[idx-1][1] - 1
        start_cur = idx - 2
        cur = start_cur
        @last_mod = nil
        while cur > -1 && [:module, :class].include?(self[cur].first)
          @last_mod ||= self[cur][2]
          cur -= 1
        end
        cur += 1
        if cur > start_cur
          fail("classes or modules not found for #{name}")
        end
        start_offset = self[cur][1]
        [start_offset, end_offset]
      end
    end
  end
end

module Hipe
  class IndentingStream
    def initialize io, indent
      @io = io
      @indent = indent
    end
    def indent!
      @indent << '  '
      self
    end
    def dedent!
      @indent.sub!(/  $/,'')
      self
    end
    def puts m=nil
      return @io.puts if m.nil?
      m = m.split("\n") if m.kind_of? String
      m = [m] unless m.kind_of? Array
      @io.puts m.map{|x| "#{@indent}#{x}"}
      self
    end
  end
end
