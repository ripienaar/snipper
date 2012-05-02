class Snipper
  class Util
    def self.delete(snippet)
      snipper = Snipper.new

      raise "Please specify a snippet number" unless snippet =~ /^\d+$/

      snip = Snippet.new(nil, :snippet => snippet)

      snip.delete!
    end

    def self.new(snippet, syntax)
      snipper = Snipper.new

      if STDIN.tty?
        abort "Please specify a filename or provide a snippet on STDIN" if snippet.empty?

        txt = snippet
      else
        txt = STDIN.read
      end

      snip = Snippet.new(txt, {:syntax => syntax})
      snip.url_for_snippet
    end

    def self.append(snippet_id, snippet, syntax)
      snipper = Snipper.new

      if STDIN.tty?
        abort "Please specify a filename or provide a snippet on STDIN" if snippet.empty?

        txt = snippet
      else
        txt = STDIN.read
      end

      snip = Snippet.new(txt, {:syntax => syntax, :snippet => snippet_id})
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
