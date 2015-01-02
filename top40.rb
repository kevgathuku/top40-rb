#!/usr/bin/env ruby

require 'digest'
require 'json'
require 'net/http'
require 'tmpdir'
require 'youtube_search'

# Source: https://developer.yahoo.com/ruby/ruby-cache.html
class Top40Fetcher
  def initialize(
    url='http://ben-major.co.uk/labs/top40/api/singles/',
    cache_dir=Dir.tmpdir)
      # this is the dir where we store our cache
      @cache_dir = cache_dir
      @url = url
      @file_name = Digest::MD5.hexdigest(@url)
      @file_path = File.join("", @cache_dir, @file_name)
  end

  def fetch(max_age = 43200)
      # we check if the file -- a MD5 hexdigest of the URL -- exists
      #  in the dir. If it does and the data is fresh, we just read
      #  data from the file and return
      if File.exist? @file_path
        return File.new(@file_path).read if Time.now - File.mtime(@file_path) < max_age
      end
      # if the file does not exist (or if the data is not fresh), we
      #  make an HTTP request and save it to a file
      File.open(file_path, 'w') do |data|
        res = Net::HTTP.get_response(URI.parse(@url))
        data << res.body if res.code == '200'
      end
  end

  def display(num = 10)
    # Can take the number of songs to display as a command line argument
    # Converts the number to an absolute value.
    num = ARGV[0].to_i.abs if ARGV[0]
    # Dirty handling if the first arg is not a number
    num = 10 if num == 0
    content = JSON.load(File.read(@file_path, :encoding => 'utf-8'))
    # If the index is out of range, prints nothing
    content['entries'][0..num-1].each do |entry|
      if ARGV.include? 'links'
        link = YoutubeSearch.search("#{entry['artist']} - #{entry['title']}").first
        puts "#{entry['position']}. #{entry['artist']} - #{entry['title']} (http://youtu.be/#{link['video_id']})"
      else
        puts "#{entry['position']}. #{entry['artist']} - #{entry['title']}"
      end
    end
  end
end

fetcher = Top40Fetcher.new
fetcher.fetch
fetcher.display
