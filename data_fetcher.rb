require 'dotenv/load'
require 'api_cache'
require 'json'
require 'moneta'
require 'tmpdir'
require 'yt'

APICache.store = Moneta.new(:File, dir: Dir.tmpdir)
Yt.configure do |config|
  config.log_level = :debug
  config.api_key = ENV['YOUTUBE_DEVELOPER_KEY']
end

class DataFetcher
  attr_accessor :singles, :url

  TOP40_API_URL = 'https://wckb0ftk67.execute-api.eu-west-1.amazonaws.com/dev/singles'

  def initialize(api_url=TOP40_API_URL)
    @videos = Yt::Collections::Videos.new
    url = api_url
  end

  def fetch_singles
    response = APICache.get(
      url,
      cache: 43_200,
      timeout: 15,
      fail: 'Failed to retrieve data'
    )
    singles = JSON.load(response)['entries']
  end

  def fetch_youtube_link(artist, track)
    # Generate a unique cache key from the artist and track
    cache_key = Digest::MD5.hexdigest("#{artist}#{track}")
    APICache.get(cache_key, cache: 43_200) do
      begin
        @videos.where(q: "#{artist} - #{track}", order: 'relevance').first.id
      rescue
        puts "Could not fetch the YouTube Link for #{artist} - #{track}"
      end
    end
  end

  def fetch_singles_with_links
    singles.map { |song|
        title, artist = song['title'], song['artist']
        link = fetch_youtube_link(title, artist)
        merge_data = {
          youtube_link: "https://youtu.be/#{link}"
        }
        song.merge(merge_data)
    }
  end
end
