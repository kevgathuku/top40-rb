#!/usr/bin/env ruby

require 'api_cache'
require 'json'
require 'moneta'
require 'tmpdir'
require 'youtube_search'

APICache.store = Moneta.new(:File, dir: Dir.tmpdir)

# Source: https://developer.yahoo.com/ruby/ruby-cache.html
class Top40

  def initialize(url: 'http://ben-major.co.uk/labs/top40/api/singles/')
    @url = url
    @singles = Hash.new
  end

  def fetch
    response = APICache.get(@url, :cache => 43_200, :fail => "Failed to retrieve data")
    @singles = JSON.load(response)['entries']
  end

  def display(num: 10)
    # Takes the number of songs to display as a command line argument. Defaults to 10
    # Returns the number of songs or 0 if ARGV[0] is not a number
    if ARGV[0]
      num = ARGV[0].to_i.abs
    end
    @singles[0..num - 1].each do |entry|
      output = "#{entry['position']}. #{entry['artist']} - #{entry['title']}"
      if ARGV.include? 'links'
        link = YoutubeSearch.search(
          "#{entry['artist']} - #{entry['title']}").first
        puts "#{output} (http://youtu.be/#{link['video_id']})"
      else
        puts output
      end
    end
  end
end

fetcher = Top40.new
fetcher.fetch
fetcher.display
