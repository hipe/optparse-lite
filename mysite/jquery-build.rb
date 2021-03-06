#!/usr/bin/env ruby
require 'ruby-debug'
require 'optparse-lite/treebis-extlib'

task = Treebis::Task.new do
  from('.')
  tgt_dir = on_path + '/NOGIT-jquery-head'
  build_dir = on_path + '/NOGIT-build'
  if File.directory?(tgt_dir)
    notice "exists", "#{tgt_dir}"
  else
    cmd = "git clone git://github.com/jquery/jquery.git #{tgt_dir}"
    notice "git cloning", cmd
    system(cmd) # open3 would block at wierd places like eof?
  end
  mkdir_p_unless_exists build_dir
  output_js_file = build_dir+'/dist/jquery.js'
  if File.exist?(output_js_file)
    notice "skipping", "exists: #{output_js_file}"
  else
    FileUtils.cd(tgt_dir) do
      cmd = "make PREFIX=../#{build_dir}"
      notice "command", cmd
      system(cmd)
    end
  end
  copy build_dir+'/dist/jquery.js', './output/js/jquery-1.4.3.pre-hack-me.js'
  notice "donezoorz", ''
end

if File.basename(__FILE__) == 'jquery-build.rb'
  task.on('.').run
end
