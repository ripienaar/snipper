## description: shitty config class
class Snipper
  class Config
    class << self
      def load(source)
        @config = {:renderer => "ultraviolet",
                   :grep     => "grep --color=auto -riHn -C 2 '%Q%' *",
                   :snipper_dir => File.join(Etc.getpwuid.dir, ".snipper"),
                   :snippets_dir => File.join(Etc.getpwuid.dir, ".snipper", "snippets"),
                   :config_file => File.join(Etc.getpwuid.dir, ".snipper", "config.yml")}

        if source.is_a?(String)
          raise "Config file #{source} not found" unless File.exist?(source)

          config = YAML.load_file(source)
          @config.merge! config if config

        elsif source.is_a?(Hash)
          @config.merge! source
        end
      end

      def include?(key)
        @config.include?(key)
      end

      def [](key)
        @config[key]
      end

      def to_yaml
        @config.to_yaml
      end
    end
  end
end
