class Snipper
  class Command
    class Delete
      attr_reader :url, :snippet

      def initialize(options)
        @options = options

        snipper = Snipper.new

        raise "Please specify a snippet number" unless ARGV[1] =~ /^\d+$/

        options[:snippet] = ARGV[1]

        snippet = Snippet.new(nil, @options)

        snippet.delete!
      end
    end
  end
end
