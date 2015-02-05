#!/usr/bin/env ruby

require 'dotenv'
require 'lastfm'
require 'yaml/store'
require 'youtube_search'
require File.join(File.dirname(__FILE__), 'top40')
Dotenv.load

Single = Struct.new :title, :artist, :mbid, :lastfm_id, :youtube

# Repsonsible for storing info related to the Top 40 Singles
class ChartInfo
  def initialize
    @charts = Top40.new
    @store = YAML::Store.new 'top40singles.yaml'
    @lastfm = Lastfm.new(ENV['LASTFM_API_KEY'], ENV['LASTFM_API_SECRET'])
  end

  def get_ids(artist, track)
    track = @lastfm.track.get_info(artist: artist, track: track)
    [track['mbid'], track['id']]
  end

  def get_youtube(artist, track)
    link = YoutubeSearch.search("#{artist} - #{track}").first
    "https://youtu.be/#{link['video_id']}"
  end

  def store
    store.transaction do
      store['top40'] ||= []
      @charts.singles.each do |song|
        store['top40'].push Single.new(
          "#{song['title']}",
          "#{song['artist']}",
          get_ids("#{song['title']}", "#{song['artist']}"),
          get_youtube("#{song['title']}", "#{song['artist']}")
          )
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  singles_info = ChartInfo.new
  singles_info.store
end
