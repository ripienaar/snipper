class Snipper
  class Snippet
    attr_reader :options

    def initialize(snippet, options = {:snippet => nil})
      @options = options

      if options[:snippet]
        raise "Snippets ids must be numerical" unless options[:snippet] == options[:snippet].to_i.to_s
        raise "Unknown snippet %s" % [ options[:snippet] ] unless File.exist?(snippet_path)
      end

      if snippet
        # new snippet
        begin
          unless @options[:snippet]
            @options[:snippet] = next_snippet_id

            create_snippet_dir

            append_snippet(snippet)

            update_html
          else # add to existing snippet
            append_snippet(snippet)

            update_html
          end
        rescue Exception => e
          STDERR.puts "Could not save snippet: #{e.class}: #{e}"
          # TODO: clear up half baked snippets

          raise
        end
      end
    end

    def delete!
      raise "Refusing to remove all snippets" if File.expand_path(snippet_path) == File.expand_path(Config[:public_target_dir])
      raise "Snippet path #{snippet_path} looks suspect, refusing to delete" unless snippet_path.match(/\d+$/)

      raise "Refusing to remove all snippets" if File.expand_path(snippet_html_path) == File.expand_path(Config[:public_target_dir])
      raise "Snippet path #{snippet_html_path} looks suspect, refusing to delete" unless snippet_html_path.match(/\d+$/)

      if File.directory?(snippet_path)
        puts "Removing #{snippet_path}"
        FileUtils.remove_entry_secure(snippet_path)
      end

      if File.directory?(snippet_html_path)
        puts "Removing #{snippet_html_path}"
        FileUtils.remove_entry_secure(snippet_html_path)
      end
    end

    def append_snippet(snippet)
      if snippet.is_a?(Array)
        [snippet].flatten.each do |file|
          save_next_file(snippet_file(File.read(file)))
        end
      else
        save_next_file(snippet_file(snippet))
      end
    end

    def update_html
      Output::Pygments_Output.new(self).save
    end

    def url_for_snippet
      "%s/%s" % [ Config[:baseurl], @options[:snippet] ]
    end

    def save_next_file(text)
      file_name = File.join(snippet_path, next_file_id.to_s)

      File.open(file_name, "w") do |file|
        file.puts text
      end

      return file_name
    end

    def files
      Dir.entries(snippet_path).grep(/^\d+$/).sort_by{|i| Integer(i)}
    end

    def each_file
      files.each do |file|
        headers, text = parse_file(File.read(File.join(snippet_path, file)))

        yield File.join(snippet_path, file), text, headers
      end
    end

    def parse_file(file)
      headers = {}
      text = ""
      inheader = true

      file.each_line do |line|
        # skips the first blank line
        if line == "\n" && inheader
          inheader = false
          next
        end

        if line.start_with?("##") && inheader
          if line =~ /^## (\S+): (.+)/
            headers[$1] = $2
          elsif line =~ /## (.+)/
            headers["description"] = $1
          end
        else
          inheader = false
          text += line
        end
      end

      return headers, text
    end

    def snippet_html_path
      File.expand_path(File.join(Config[:public_target_dir], @options[:snippet].to_s))
    end

    def snippet_path
      File.join(Config[:snippets_dir], @options[:snippet].to_s)
    end

    def create_snippet_dir
      FileUtils.mkdir(snippet_path)
    end

    def next_file_id
      return 1 unless files.any?
      Integer(files[-1]) + 1
    end

    def next_snippet_id
      snippets = Dir.entries(Config[:snippets_dir]).grep(/^\d+$/)
      return 1 unless snippets.any?
      Integer(snippets.map{|s| s.to_i}.sort.max) + 1
    end

    def snippet_file(text)
      snippet = StringIO.new

      unless text.start_with?("##")
        snippet.puts "## description: %s" % [ @options[:description] ] if @options[:description]
        snippet.puts "## lang: %s" % [ @options[:syntax] ] if @options[:syntax]
        snippet.puts
      end

      snippet.puts text

      snippet.string
    end
  end
end
