#!/usr/bin/env ruby

require 'api_cache'
require 'json'
require 'moneta'
require 'tmpdir'
require 'youtube_search'

APICache.store = Moneta.new(:File, dir: Dir.tmpdir)

# Source: https://developer.yahoo.com/ruby/ruby-cache.html
class Top40

  def initialize(
    url: 'http://ben-major.co.uk/labs/top40/api/singles/')
    @url = url
  end

  def fetch
    response = APICache.get(@url, options = {:cache => 43_200, :fail => "Failed to retrieve data"})
    JSON.load(response)
  end

  def display(content, num: 10)
    # Takes the number of songs to display as a command line argument
    # Converts the number to an absolute value.
    num = ARGV[0].to_i.abs if ARGV[0]
    # Dirty handling if the first arg is not a number
    num += 10 if num == 0
    # If the index is out of range, prints nothing
    content['entries'][0..num - 1].each do |entry|
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
content = fetcher.fetch
fetcher.display(content)
