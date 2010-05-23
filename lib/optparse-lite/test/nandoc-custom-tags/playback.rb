require 'shellwords'

module OptparseLite
  class PlaybackTag < ::NanDoc::Filters::CustomTag
    ::NanDoc::Filters::CustomTags.register_class(self)
    include NanDoc::SpecDoc::Playback::Terminal::ColorToHtml
    include NanDoc::StringMethods
    include Nanoc3::Helpers::HTMLEscape
    class << self
      def =~ whole_file
        /\(see: test[^ ]*\.rb - playback - ["']/ =~ whole_file
      end
    end
    def name
      'optparse lite custom tag - playback'
    end
    def run content
      numetal = content.gsub(
        /\(see: (test[^ ]*\.rb) - playback - ["']([^"']+)["'](?: - (.+))?\)/
      ) do
        html = show_playback($1, $2, $3)
        html
      end
      numetal
    end
    def show_playback testfile, testname, xtra
      opts =
      if xtra
        JSON.parse(xtra) or fail("failed to parse json: #{xtra}")
      else
        {}
      end
      proj = NanDoc::Project.instance
      proxy = proj.test_framework_proxy_for_file(testfile)
      sexp = proxy.sexp_get testfile, testname
      scn = NanDoc::SpecDoc::Playback::SexpScanner.new(sexp)
      scn.scan_assert(:method)
      doc = NanDoc::Html::Tags.new
      while true do
        app = scn.scan_assert(:app)[1]
        name = app.spec.invocation_name
        argv = scn.scan_assert(:argv)[1]
        # command = "./#{name} #{argv.shelljoin}"
        # shelljoin is ugly and dumb
        command = "./#{name} #{myshelljoin(argv)}"
        out = scn.scan_assert(:out)[1]
        cmd_html = prompt_highlight2('~ > ', command)
        doc.push_smart("pre", 'terminal', cmd_html, opts)
        opts.clear
        colored = terminal_color_to_html(out) || html_escape(out)
        doc.content.push colored
        if scn.current && scn.current.first == :app
          doc.content.push "\n\n"
          # stay -- rare tests that do multiple commands
        else
          break
        end
      end
      html = doc.to_html
      html
    end
  end
end
