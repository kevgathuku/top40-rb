#!/usr/bin/env ruby

require 'optparse'
require_relative 'data_fetcher'

class Top40

  def initialize(options, data_fetcher = DataFetcher.new)
    @options = options
    @singles = data_fetcher.fetch_singles
    if options.links
        @singles_with_links = data_fetcher.fetch_singles_with_links
    end
  end

  def display
    if @options.links
        @singles_with_links.take(@options.num).each do |entry|
          output = "#{entry['position']}. #{entry['artist']} - #{entry['title']}"
          output << " (#{entry[:youtube_link]})"
          puts output
        end
    else
        @singles.take(@options.num).each do |entry|
          output = "#{entry['position']}. #{entry['artist']} - #{entry['title']}"
          puts output
        end
    end
  end
end

# Parse command line arguments passed to the script
class Parser
  def self.parse(args)
    options = OpenStruct.new
    options.links = false
    options.num = 10

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{File.basename($PROGRAM_NAME)} [options]"

      opts.on(
        '-n',
        '--num NUMBER',
        Integer,
        "Number of songs to display (Default: #{options.num})") do |n|
          options.num = n
        end

        opts.on('-l', '--links', 'Display Youtube links along with songs') do
          options.links = true
        end

        opts.on('-h', '--help', 'Prints this help') do
          puts opts
          exit
        end
    end

    opt_parser.parse!(args)
    options
  end
end

if __FILE__ == $PROGRAM_NAME
  options = Parser.parse(ARGV)
  fetcher = Top40.new(options)
  fetcher.display
end
