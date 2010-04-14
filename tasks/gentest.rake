desc "gentest -- try it and see!"
task :gentest do
  fail('no') unless ARGV.shift == 'gentest'
  def hdr(x); "\e[32;m#{x}\e[0m" end
  if ARGV.empty?
    puts <<-HERE.gsub(/^    /,'')
    #{hdr 'Usage:'} rake gentest -- ./your-app.rb --foo='bar' --baz='jazz'
    #{hdr 'Description:'} output to STDOUT a code snippet fer yer test
    \n\n
    HERE
    exit # why it complains on return i don't get
  end
  argv = ARGV.dup
  ARGV.clear # don't let rake worry about these (?)
  Hipe::GenTest::gentest(argv)
end

module Hipe
end

class Hipe::IndentingStream
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

module Hipe::GenTest
  extend self

  def gentest argv
    @service_controller = deduce_service_controller
    @ui = Hipe::IndentingStream.new($stdout,'')
    argv = argv.dup
    file = argv.shift
    mod = deduce_module_from_file file
    mod.spec.invocation_name = File.basename(file)
    act = run(mod){ run argv }
    @ui.indent!.indent!
    go_app(mod, file)
    go_desc(mod, file) do
      go_exp(act)
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

  def deduce_service_controller
    dir = File.expand_path('../../lib',__FILE__)
    it = Dir["#{dir}/*.rb"]
    fail("no files in dir #{dir}") if it.size == 0
    fail("too many files in #{dir}: "+it.map{|x| File.basename(x)}*',') if
      it.size != 1
    it = it.first
    it = camelize(no_ext(it))
    mod = Object.const_get(it)
    fail("Couldn't find module #{it}") unless mod
    mod
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
    @ui.puts("act = _run{ run #{args.inspect} }.strip")
    @ui.puts('assert_no_diff(exp, act)')
  end

  def go_app mod, file
    @ui.puts File.read(file).split("\n")[2..-3]
    @ui.puts("#{mod}.spec.invocation_name = "<<
      "#{mod.spec.invocation_name.inspect}")
    @ui.puts
  end

  def go_exp act
    @ui.puts('exp = <<-HERE.noindent')
    @ui.indent!
    @ui.puts act.to_s.inspect.gsub(/\\n/,"\n  ").gsub(/(\A"| *"\Z)/,'')
    @ui.dedent!
    @ui.puts 'HERE'
  end

  def no_ext str
    File.basename(str).match(/^(.*)\.rb$/)[1]
  end

  def run mod, &block
    mod.ui.push
    _ = mod.instance_eval(&block)
    mod.ui.pop
  end
end
