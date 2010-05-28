require 'nandoc'
require 'stringio'

module Hipe
  module Differ
    class << self
      def get_diff file_a, file_b
        DiffWrapper.diff(file_a, file_b)
      end
    end
    class DiffWrapper < ::NanDoc::DiffProxy::Diff
      extend ::NanDoc::DiffProxy
      include ::NanDoc::SpecDoc::Playback::Terminal::ColorToHtml
      class << self
        alias_method :get_diff, :diff
        def diff_class
          self
        end
      end
      def to_html
        io = StringIO.new('w+')
        colorize(io)
        io.rewind
        justin_beaver = io.read
        html = terminal_color_to_html(justin_beaver)
        html
      end
    end
  end
end
