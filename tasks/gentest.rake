
module Hipe;
end

module Hipe::GenTest
  extend self
  def task_gentest argv
    fail('no') unless argv.shift == 'gentest'
    use_argv = argv.dup
    argv.clear # don't let rake see (?)
    argv = use_argv
    require File.dirname(__FILE__)+'/gentest.rb'
    if argv.empty?
      puts <<-HERE.gsub(/^      /,'')
        #{hdr 'Usage:'} #{cmd 'rake gentest'} -- ./your-app.rb --foo='bar' --baz='jazz'
        #{hdr 'Description:'} output to STDOUT a code snippet fer yer test
      \n\n
      HERE
      exit # why it complains on return i don't get
    end
    Hipe::GenTest::gentest(use_argv)
  end

  def task_ungentest argv
    fail('no') unless ARGV.shift == 'ungentest'
    use_argv = argv.dup
    argv.clear # don't let rake see (?)
    argv = use_argv
    require File.dirname(__FILE__)+'/gentest.rb'
    if argv.size > 1
      puts "too many arguments: #{argv.inspect}"
      arg = nil
    elsif argv.empty?
      arg = nil
    elsif /^-(.+)/ =~ argv.first
      if '-list' != argv.first
        puts "unrecognized option: #{argv.first}"
      else
        arg = argv.first
      end
    else
      arg = argv.first
    end
    unless arg
      puts <<-HERE.gsub(/^        /,'')

        #{hdr 'Usage:'} #{cmd 'rake ungentest'} -- some-app-name.rb
               #{cmd 'rake ungentest'} -- -list

        #{hdr 'Description:'} create a file with that name in the current
          directory that has the code chunk found in the test file (for now,
          "test/test.rb")

          The second form lists available code chunks found in the file.
      \n\n
      HERE
    end

    if arg=='-list'
      ungentest_list 'test/test.rb'
    elsif arg
      ungentest 'test/test.rb', arg
    end
    exit(0) # rake is annoying
  end
private
  def hdr(x); "\e[32;m#{x}\e[0m" end
  def cmd(x); "\e[4;m#{x}\e[0m"  end
end

desc "gentest -- try it and see!"
task(:gentest){ Hipe::GenTest::task_gentest(ARGV) }

desc "ungentest -- try it and see!"
task(:ungentest){ Hipe::GenTest::task_ungentest(ARGV) }
