require 'rubygems'
require 'pygments.rb'
require 'optparse'
require 'etc'
require 'snipper/config'
require 'snipper/snippet'
require 'snipper/command/new'
require 'snipper/command/edit'
require 'snipper/command/delete'
require 'snipper/command/search'
require 'snipper/command/view'
require 'snipper/version'
require 'snipper/output/pygments_output.rb'
require 'yaml'
require 'fileutils'

class Snipper
  def initialize
    config = File.join(Etc.getpwuid.dir, ".snipper", "config.yml")

    if File.exist?(config)
      Config.load(config)
    else
      Config.load({:config_file => config})
    end

    setup
  end

  def setup
    FileUtils.mkdir_p(Config[:snippets_dir])

    unless File.exist?(Config[:config_file])
      File.open(Config[:config_file], "w") do |c|
        c.print Config.to_yaml
      end
    end
  end
end

class Array
  def in_groups_of(chunk_size, padded_with=nil, &block)
    arr = self.clone

    # how many to add
    padding = chunk_size - (arr.size % chunk_size)

    # pad at the end
    arr.concat([padded_with] * padding) unless padding == chunk_size

    # how many chunks we'll make
    count = arr.size / chunk_size

    # make that many arrays
    result = []
    count.times {|s| result <<  arr[s * chunk_size, chunk_size]}

    if block_given?
      result.each_with_index do |a, i|
        case block.arity
          when 1
            yield(a)
          when 2
            yield(a, (i == result.size - 1))
          else
            raise "Expected 1 or 2 arguments, got #{block.arity}"
        end
      end
    else
      result
    end
  end unless method_defined?(:in_groups_of)
end
