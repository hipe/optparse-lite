require 'syntax/convertors/html'
module OptparseLite
  class AppTag < ::NanDoc::Filters::CustomTag
    ::NanDoc::Filters::CustomTags.register_class(self)
    include NanDoc::SpecDoc::Playback::Terminal::ColorToHtml
    include NanDoc::StringMethods # module_basename
    ColorizeRuby = ::Syntax::Convertors::HTML.for_syntax('ruby')

    class << self
      def =~ whole_file
        /\(see: test[^ ]*\.rb - app - ["']/ =~ whole_file
      end
    end
    def name
      'optparse lite custom tag - app'
    end
    def run content
      numetal = content.gsub(
        /\(see: (test[^ ]*\.rb) - app - ["']([^"']+)["'](.*)\)/
      ) do
        show_app_code($1, $2, $3)
      end
    end
    def tag_parser
      TagParser.new
    end
    def show_app_code testfile, label, rest
      opts = parse_rest_assert(rest)
      NanDoc::Project.instance.require_test_file testfile
      recs = NanDoc::SpecDoc::Recordings.get_for_key(:generic)
      scn = NanDoc::SpecDoc::Playback::SexpScanner.new(recs)
      scn.skip_to_after_assert :story, label
      aa = scn.offset
      scn.skip_to_after_assert :story_stop
      bb = scn.offset - 2
      these = scn.sexp[aa..bb]
      meth = NanDoc::SpecDoc::Playback::Method.new
      doc = NanDoc::Html::Tags.new
      html_opts = opts[:epilogue] ? {} : opts # hack
      doc.push_smart 'pre', 'ruby', '', html_opts
      # the below is written inline in the tests, because we can
      # if opts[:prologue]
      #   code = "#!/usr/bin/env ruby\n\n"
      #   doc.push_smart('pre','ruby', code) # no colorize!
      # end
      meth.run_sexp doc, these
      if opts[:epilogue]
        # scan back
        j = scn.offset - 1
        j -=1 while scn.sexp[j] && scn.sexp[j][0] != :optparse_app_module
        if ! scn.sexp[j]
          fail("primus sucks")
        end
        mod = scn.sexp[j][1]
        use_mod = module_basename(mod)
        ruby = "\n#{use_mod}.run"
        doc.content.push "<br />"<<ColorizeRuby.convert(ruby, false)
      end
      html = doc.to_html
      html
    end
  private
    def parse_rest_assert str
      return {} if str == ""
      /\A - (.+)\Z/ =~ str or fail("can't parse rest: #{str.inspect}")
      things = {}
      case $1
      when 'full'; things[:prologue] = true; things[:epilogue] = true;
      else
        things = JSON.parse($1) or fail("wanted json had: #{$1.inspect}")
      end
      things
    end
  end
  class AppTag
    class TagParser < ::NanDoc::Filters::CustomTag::TagParser
      Symbols = {
        :start => :path,
        :path => {
          :re => /[-\/_a-z0-9]*(?:test|spec)[-_a-z0-9]*\.rb/,
          :desc => "test file path",
          :next => [:sep, :app_keyword]
        },
        :sep => {
          :re => / *(?:-|\/) */,
          :desc => "separator {-|\\/}",
          :no_sexp => true
        },
        :app_keyword => {
          :re => /app\b/,
          :desc => "'app' keyword",
          :next => [:sep, :more_token]
        },
        :more_token => {
          :desc => "open token (\"foo\" or \"'foo'\" or '\"foo\"')",
          :re => /'[^']*'|"[^"]"|[^[:space:]]+/,# yeah we're not etc..
          :next => Or[ :end, [:sep, :more_token] ]
        }
      }
    end
  end
end
