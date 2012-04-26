class Snipper
  class Command
    class Search
      attr_reader :url, :snippet

      def initialize(options)
        @options = options

        snipper = Snipper.new

        raise "Please specify a search string" unless ARGV[1]

        Dir.chdir(Config[:snippets_dir]) do
          grep = Config[:grep].gsub("%Q%", ARGV[1].gsub("'", "\\'"))

          system grep
        end
      end
    end
  end
end
