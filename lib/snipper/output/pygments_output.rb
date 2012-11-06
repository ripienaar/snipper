class Snipper
  class Output
    class Pygments_Output
      def initialize(snippet)
        @snippet = snippet
      end

      def self.list_langs
        Pygments.lexers.map{|l| l[1][:aliases]}.flatten.sort
      end

      def save
        theme = Config[:theme] || "default"

        basecss = Config[:dark_theme] ? 'darkbg' : 'lightbg'

        raise "Please set the :public_target_dir setting" unless Config[:public_target_dir]

        path = @snippet.snippet_html_path

        FileUtils.mkdir_p(path)

        File.open(File.join(path, "index.html"), "w") do |html|
          html.puts "<!DOCTYPE html>"
          html.puts "<html>"
          html.puts "<head>"
          html.puts "<link rel='stylesheet' type='text/css' href='../css/#{theme}.css' media='all' />"
          html.puts "<link rel='stylesheet' type='text/css' href='../css/#{basecss}.css' media='all' />"
          html.puts "</head>"

          html.puts "<body>"


          @snippet.each_file do |file, text, headers|
            html.puts "<table class='content'>"
            html.puts "<tr><td>"
            File.open(File.join(path, "#{File.basename(file)}.raw"), "w") do |f|
              f.puts text
            end

            syntax = headers["lang"]

            unless syntax
              lexer = Pygments::Lexer.find_by_extname(File.extname(file))

              if lexer
                syntax = lexer.name
              else
                syntax = Config[:default_syntax] || "ruby"
              end
            end

            raise "Unknown syntax #{syntax}" unless self.class.list_langs.include?(syntax)


            html.puts "<h3>%s</h3>" % [ headers["description"] ] if headers["description"]
            html.puts Pygments.highlight(text, :lexer => syntax, :options => {:linenos => "table", :style => theme})
            #html.puts "<br /><br />"

            html.puts "</td></tr>"
            html.puts "</table>"

            html.puts "<div id='left'>"
            html.puts "<a class='button-link' href='%s.raw'>raw</a> download - Syntax : %s " % [ File.basename(file), syntax ]
            html.puts "</div>"
          end

          html.puts "<div id='right'>"
          html.puts "<a class='button-link' href='%s'>Snipper</a>" % [ "http://github.com/ripienaar/snipper" ]
          html.puts "</div>"

          html.puts "</body>"
          html.puts "</html>"
        end
      end
    end
  end
end
