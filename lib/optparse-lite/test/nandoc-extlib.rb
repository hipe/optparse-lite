module NanDoc

  # experimental additions to nanDoc that can inject rcov info from
  # the last rcov into docs. We get SLOC count from this, yay!

  module Helpers
    module NanDocHelpers
      # @return nil or [Float] last percent
      def rcov_last_percentage
        RcovAgent.instance.last_percent
      end
      def rcov_last_percentage_pretty
        p = rcov_last_percentage || '??'
        "#{p}%"
      end
      # @return nil or [Fixnum] last sloc
      def rcov_last_sloc
        RcovAgent.instance.last_sloc
      end
      def rcov_last_sloc_pretty
        rcov_last_sloc || '??'
      end
    end
  end

  class RcovAgent

    # we will either be in <my-proj>/<my-site>  or <my-proj>
    Treebis::PersistentDotfile.include_to(self,
      ['.rcov.persistent.json','../.rcov.persistent.json']
    )

    @last_instance = nil
    class << self
      def instance
        new unless @last_instance
        @last_instance
      end
      def instance= x
        @last_instance = x
      end
    end
    def initialize &block
      self.class.instance = self
      @output_dir = nil
      @input_files = nil
      instance_eval(&block) if block_given?
    end
    def command
      @cmd ||= begin
        "rcov --text-report --exclude '.*gem.*' "<<
          "-o #{@output_dir} #{@input_files.join(' ')}"
      end
    end
    def input_file file
      @cmd = nil
      @input_files = [file]
    end
    def input_files files=nil
      files ? ( @input_files = files ) : @input_files
    end
    def last_percent
      (h = last_rcov and h['percent']) || nil
    end
    def last_sloc
      (h = last_rcov and h['sloc']) || nil
    end
    def last_rcov
      persistent_get('last_rcov')
    end
    def output_dir name=nil
      @cmd = nil
      name ? ( @output_dir = name ) : @output_dir
    end
    def run
      require 'open3'
      cmd = command
      out, err = Open3.popen3(cmd) do |inn, out, err|
        [out.read, err.read]
      end
      fail("Huh?: #{err.inspect}") unless err == ''
      $stdout.puts out
      re = /\A(\d+\.\d)%   (\d+) file\(s\)   (\d+) Lines   (\d+) LOC\Z/
      last_line = out.split("\n").last
      re =~ last_line or fail("failed to match last line against re:\n"<<
        "last line: #{last_line.inspect}\nre: #{re.source}"
      )
      percent, num_files, num_lines, num_sloc = $~.captures
      persistent_set 'last_rcov', {
        'percent' => percent.to_f,
        'sloc'    => num_sloc.to_i
      }
    end
  end
end
