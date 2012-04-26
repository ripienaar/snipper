class Snipper
  class Command
    class View
      attr_reader :url, :snippet

      def initialize(options)
        @options = options

        snipper = Snipper.new

        raise "Please specify a snippet number" unless ARGV[1] =~ /^\d+$/

        options[:snippet] = ARGV[1]

        snippet = Snippet.new(nil, @options)

        files = snippet.files.map {|file| File.join(snippet.snippet_path, file)}

        pager = ENV["PAGER"] || "less"

        system "cat %s|%s" % [files.join(" "), pager]
      end
    end
  end
end
