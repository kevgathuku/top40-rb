#!/usr/bin/env ruby

# require 'dotenv'
# require 'lastfm'
require 'api_cache'
require 'yaml/store'
require 'youtube_search'
require File.join(File.dirname(__FILE__), 'top40')
# Dotenv.load

# Repsonsible for storing info related to the Top 40 Singles
class ChartInfo
  def initialize
    @charts = Top40.new
  end

  def get_youtube(artist, track)
    cached = APICache.get('youtube link', fail: ['Read failed']) do
      link = YoutubeSearch.search("#{artist} - #{track}").first
      "https://youtu.be/#{link['video_id']}"
    end
    cached
  end

  def populate_objects
    @charts.singles.each do |song|
      song['youtube'] = get_youtube("#{song['title']}", "#{song['artist']}")
    end
  end

  def display
    @charts.singles.each do |entry|
      output = "#{entry['position']}. #{entry['artist']} - #{entry['title']}"
      output << " (#{entry['youtube']})"
      puts output
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  singles_info = ChartInfo.new
  singles_info.populate_objects
  singles_info.display
end
