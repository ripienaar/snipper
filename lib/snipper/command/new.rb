class Snipper
  class Command
    class New
      attr_reader :url, :snippet

      def initialize(options)
        @options = options

        @snipper = Snipper.new

        # if the first arg is a number and it isnt a file path
        # then assume this is a snippet id we want to append to
        if ARGV.first =~ /^\d+$/ && !File.exist?(ARGV.first)
          options[:snippet] = ARGV.shift
        end

        if STDIN.tty?
          abort "Please specify a filename or provide one on STDIN" if ARGV.empty?

          txt = ARGV
        else
          txt = STDIN.read
        end

        @snippet = Snippet.new(txt, @options)
        @url = @snippet.url_for_snippet
      end
    end
  end
end
