class Snipper
  class Util
    def self.delete(snippet)
      snipper = Snipper.new

      raise "Please specify a snippet number" unless snippet =~ /^\d+$/

      snip = Snippet.new(nil, :snippet => snippet)

      snip.delete!
    end

    def self.search(string)
      snipper = Snipper.new

      Dir.chdir(Config[:snippets_dir]) do
        abort "Refusing to search for strings with ` in them" if string.match("'")
        system(Config[:grep].gsub("%Q%", string))
      end
    end

    def self.new(snippet, syntax, description)
      snipper = Snipper.new

      if STDIN.tty?
        if snippet.empty?
          if ARGV.empty?
            abort "When adding a snippet without providing any arguments a snippet has to be provided on STDIN, run 'snipper help add' for full details"
          else
            abort "Please specify a filename or provide a snippet on STDIN"
          end
        end

        txt = snippet
      else
        txt = STDIN.read
      end

      snip = Snippet.new(txt, {:syntax => syntax, :description => description})
      snip.url_for_snippet
    end

    def self.capture(command, syntax, description)
      snipper = Snipper.new
      Snippet.new(%x{#{command}}, {:syntax => syntax, :description => description}).url_for_snippet
    end

    def self.append(snippet_id, snippet, syntax, description)
      snipper = Snipper.new

      if STDIN.tty?
        abort "Please specify a filename or provide a snippet on STDIN" if snippet.empty?

        txt = snippet
      else
        txt = STDIN.read
      end

      snip = Snippet.new(txt, {:syntax => syntax, :snippet => snippet_id, :description => description})
      snip.url_for_snippet
    end

    def self.edit(snippet)
      snipper = Snipper.new

      raise "Please specify a snippet number" unless snippet

      snip = Snippet.new(nil, :snippet => snippet)

      files = snip.files.map {|file| File.join(snip.snippet_path, file)}

      editor = ENV["EDITOR"] || "vi"

      system "%s %s" % [editor, files.join(" ")]

      files.each do |file|
        unless File.size?(file)
          puts "Removing #{file} from the snippet"
          File.unlink(file)
        end
      end

      snip.update_html

      snip.url_for_snippet
    end

    def self.view(snippet)
      snipper = Snipper.new

      snip = Snippet.new(nil, :snippet => snippet)

      files = snip.files.map {|file| File.join(snip.snippet_path, file)}

      pager = ENV["PAGER"] || "less"

      system "cat %s|%s" % [files.join(" "), pager]

      snip.url_for_snippet
    end

    def self.list_langs
      exec "pygmentize -L lexer"
    end
  end
end
