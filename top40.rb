#!/usr/bin/env ruby

require 'digest'
require 'json'
require 'net/http'
require 'tmpdir'
require 'youtube_search'

# Source: https://developer.yahoo.com/ruby/ruby-cache.html
class DiskFetcher
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

  def display
    content = JSON.load(File.read(@file_path, :encoding => 'utf-8'))
    content['entries'].each do |entry|
      puts "#{entry['position']}. #{entry['title']} by #{entry['artist']}"
    end
  end
end

fetcher = DiskFetcher.new
fetcher.fetch
fetcher.display()
# if 'links' in ARGV
#   search = YoutubeSearch.search(content['entries'][0]['title']).first
#   puts "#{content['entries'][0]['title']} -
# http://youtu.be/#{search['video_id']}"
