#!/usr/bin/env ruby

require 'api_cache'
require 'json'
require 'moneta'
require 'optparse'
require 'tmpdir'
require 'yourub'

YOURUB_OPTIONS = {
    developer_key: ENV['YOUTUBE_DEVELOPER_KEY'],
    application_name: 'top40-rb',
    application_version: 2.0,
    log_level: 3
}

APICache.store = Moneta.new(:File, dir: Dir.tmpdir)
$client = Yourub::Client.new(YOURUB_OPTIONS)


# Main class handling fetching the charts and displaying them
class Top40
  attr_reader :singles

  def initialize(url='https://wckb0ftk67.execute-api.eu-west-1.amazonaws.com/dev/singles')
    @url = url
    fetch
    populate_youtube
  end

  def fetch
    response = APICache.get(
      @url,
      cache: 43_200,
      timeout: 15,
      fail: 'Failed to retrieve data')
    @singles = JSON.load(response)['entries']
  end

  def get_youtube(artist, track)
    link = nil
    APICache.get(
      "#{artist} - #{track}",
      cache: 43_200, # After 12 hours, fetch new data
      valid: 86_400, # Maximum time to use old data
      fail: ['Getting Youtube link failed']) do
        $client.search(query: "#{artist} - #{track}", max_results: 1) do |result|
            link = result['id']
        end
        "https://youtu.be/#{link}"
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
