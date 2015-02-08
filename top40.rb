#!/usr/bin/env ruby

require 'api_cache'
require 'json'
require 'moneta'
require 'optparse'
require 'tmpdir'
require 'youtube_search'

APICache.store = Moneta.new(:File, dir: Dir.tmpdir)

# Main class handling fetching the charts and displaying them
class Top40
  attr_reader :singles

  def initialize(url: 'http://ben-major.co.uk/labs/top40/api/singles/')
    @url = url
    fetch
    populate_youtube
  end

  def fetch
    response = APICache.get(
      @url,
      cache: 43_200,
      fail: 'Failed to retrieve data')
    @singles = JSON.load(response)['entries']
  end

  def get_youtube(artist, track)
    APICache.get(
      "#{artist} - #{track}",
      cache: 43_200, # After 12 hours, fetch new data
      valid: 86_400, # Maximum time to use old data
      fail: ['Getting Youtube link failed']) do
      link = YoutubeSearch.search("#{artist} - #{track}").first
      "https://youtu.be/#{link['video_id']}"
    end
  end

  def populate_youtube
    @singles.each do |song|
      song['youtube'] = get_youtube("#{song['title']}", "#{song['artist']}")
    end
  end

  def display(options)
    @singles[0..options.num - 1].each do |entry|
      output = "#{entry['position']}. #{entry['artist']} - #{entry['title']}"
      output << " (#{entry['youtube']})" if options.links
      puts output
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
  fetcher = Top40.new
  fetcher.display(options)
end
