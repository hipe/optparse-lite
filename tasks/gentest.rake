desc "gentest -- try it and see!"
task :gentest do
  require File.dirname(__FILE__)+'/gentest.rb'
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
