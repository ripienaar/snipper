class Snipper
  class Command
    class Edit
      attr_reader :url, :snippet

      def initialize(options)
        @options = options

        snipper = Snipper.new

        raise "Please specify a snippet number" unless ARGV[1] =~ /^\d+$/

        options[:snippet] = ARGV[1]

        snippet = Snippet.new(nil, @options)
        @url = snippet.url_for_snippet

        files = snippet.files.map {|file| File.join(snippet.snippet_path, file)}

        editor = ENV["EDITOR"] || "vi"

        system "%s %s" % [editor, files.join(" ")]

        files.each do |file|
          unless File.size?(file)
            puts "Removing #{file} from the snippet"
            File.unlink(file)
          end
        end

        snippet.update_html
      end
    end
  end
end
