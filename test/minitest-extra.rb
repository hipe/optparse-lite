require 'diff/lcs'

module MiniTest
  module Assertions

    ##
    # Fails unless <tt>exp == act</tt>.
    # On failure use diff to show the diff, if +exp+
    # and +act+ are of the same class and
    #

    def assert_no_diff exp, act, msg=nil, opts={}
      if opts.kind_of?(String)
        opts = {:sep=>opts}
      end
      opts = {:sep=>"\n"}.merge(opts)
      msg = message(msg) do
        exp_kind, act_kind = [exp,act].map do |x|
          [String, Array].detect{|c| x.kind_of?(c)}
        end
        if exp_kind != act_kind
          "Expecting #{exp_kind.inspect} had #{act_kind.inspect}"
        elsif exp_kind.nil?
          "Will only do diff for strings and arrays, not #{exp.class}"
        else
          differ = DiffToString.gitlike!
          if exp_kind == String
            use_exp = exp.split(opts[:sep], -1)
            use_act = act.split(opts[:sep], -1)
          else
            use_exp = exp
            use_act = act
          end
          diff = Diff::LCS.diff(use_exp, use_act)
          if diff.empty?
            debugger; 'x' # @todo
          else
            differ.diff_to_str(diff)
          end
        end
      end
      assert(exp == act, msg)
    end
  end
end


##
# turn the output of Diff::LCS.diff into a string similar
# to what would be retured by `diff`, optionally make it looks
# *sorta* like colorized output from git-diff
#
# @todo move this to minitest branch
# @todo this gives different results than diff for some stuff!!??
#
# poor man's diff:
#   file_a, file_b = ARGV.shift(2)
#   puts DiffToString.files_diff(file_a, file_b)
#
#
class DiffToString
  module Style
    Codes = {:red=>'31', :green=>'32', :bold=>'1', :red_bg=>'41',
      :magenta => '35'
    }
    def stylize str, *codes
      if 1 == codes.size
        if codes.first.nil?
          return str
        elsif codes.first.kind_of?(Array)
          codes = codes.first
        end
      end
      codes = codes.map{|c| Codes[c]}
      "\033[#{codes * ';'}m#{str}\033[0m";
    end
  end
  include Style

  class << self
    # these are just convenience wrappers for instance methods
    %w(files_diff strings_diff gitlike!).each do |meth|
      define_method(meth){|*a| new.send(meth,*a) }
    end
  end
  def initialize
    @add_style = nil
    @add_header    = '%sa%s'
    @change_header = '%sc%s'
    @del_header    = '%sd%s'
    @del_style = nil
    @left  = '<'
    @line_no_style = nil
    @right = '>'
    @separator_line = '---'
    @trailing_whitespace_style = nil
  end
  def gitlike!
    common_header = '@@ -%s, +%s @@'
    @add_header =  common_header
    @add_style = [:bold, :green]
    @change_header = common_header
    @del_style = [:bold, :red]
    @del_header = common_header
    @header_style = [:bold, :magenta]
    @left  = '-'
    @right = '+'
    @separator_line = nil
    @trailing_whitespace_style = [:red_bg]
    self
  end
  def files_diff a, b, opts={:sep=>"\n"}
    str1 = File.read(a)
    str2 = File.read(b)
    strings_diff(str1, str2, opts)
  end
  def strings_diff a, b, opts={:sep=>"\n"}
    arr1 = str_to_arr a, opts[:sep]
    arr2 = str_to_arr b, opts[:sep]
    arrays_diff(arr1, arr2)
  end
  def arrays_diff arr1, arr2
    diff = Diff::LCS.diff(arr1, arr2)
    diff_to_str diff
  end
  def str_to_arr str, sep
    str.split(sep, -1)
  end
  def diff_to_str diff
    @out = StringIO.new
    @offset_offset = -1
    diff.each do |chunk|
      dels = []
      adds = []
      start_add = last_add = start_del = last_del = nil
      chunk.each do |change|
        case change.action
        when '+'
          start_add ||= change.position + 1
          last_add = change.position + 1
          adds.push change.element
        when '-'
          start_del ||= change.position + 1
          last_del = change.position + 1
          dels.push change.element
        else
          fail("no: #{change.action}")
        end
      end
      if adds.any? && dels.any?
        puts_change_header start_del, last_del, start_add, last_add
      elsif adds.any?
        puts_add_header start_add, last_add
      else
        puts_del_header start_del, last_del
      end
      @offset_offset -= ( dels.size - adds.size )
      dels.each do |del|
        puts_del "#{@left} #{del}"
      end
      if adds.any? && dels.any?
        puts_sep
      end
      adds.each do |add|
        puts_add "#{@right} #{add}"
      end
    end
    @out.rewind
    @out.read
  end
private
  def other_offset start
    start + @offset_offset
  end
  def puts_del str
    puts_change str, @del_style
  end
  def puts_add str
    puts_change str, @add_style
  end
  def puts_add_header start_add, last_add
    str = @add_header % [other_offset(start_add), range(start_add,last_add)]
    @out.puts(stylize(str, @header_style))
  end
  def puts_change str, style
    # separate string into three parts! main string,
    # trailing non-newline whitespace, and trailing newlines
    # we want to highlite the trailing whitespace, but if we are
    # colorizing it we need to exclude the final trailing newlines
    # for puts to work correctly
    if /^(.*[^\s]|)([\t ]*)([\n]*)$/ =~ str
      main_str, ws_str, nl_str = $1, $2, $3
      @out.print(stylize(main_str, style))
      @out.print(stylize(ws_str, @trailing_whitespace_style))
      @out.puts(nl_str)
    else
      # hopefully regex never fails but it might
      @out.puts(stylize(str, style))
    end
  end
  def puts_change_header start_del, last_del, start_add, last_add
    str = @change_header %
      [range(start_del,last_del), range(start_add,last_add)]
    @out.puts(stylize(str, @header_style))
  end
  def puts_del_header start_del, last_del
    str =  @del_header % [range(start_del,last_del), other_offset(start_del)]
    @out.puts(stylize(str, @header_style))
  end
  def puts_sep
    if @separator_line
      @out.puts(@separator_line)
    end
  end
  def range min, max
    if min == max
      min
    else
      "#{min},#{max}"
    end
  end
end
