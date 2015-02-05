require 'active_record'
require 'logger'
require 'youtube_search'

BUILD_DIR = "./db"

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: "#{BUILD_DIR}/youtube.db")
# ActiveRecord::Base.logger = Logger.new(STDOUT)

class CreateApiRequests < ActiveRecord::Migration
  def change
    create_table :api_requests do |t|
      t.timestamps null: false
      t.text :url, null: false
    end

    add_index :api_requests, :url, unique: true
  end
end

class ApiRequest < ActiveRecord::Base
  validates :url, presence: true, uniqueness: true

  def self.cache(title, cache_policy)
    find_or_initialize_by(url: title).cache(cache_policy) do
      if block_given?
        yield
      end
    end
  end

  def cache(cache_policy)
    if new_record? || updated_at < cache_policy.call
      update_attributes(updated_at: Time.now)
      yield
    end
  end
end

class Youtube
  CACHE_POLICY = lambda { 1.week.ago }

  attr_reader :video_url

  def initialize(title, artist)
    @title = title
    @artist = artist
    @video_url = ""
    fetch_link(artist, title)
  end

  def search_query
    "#{@artist} - #{@title}"
  end

  def fetch_link(artist, title)
    response = YoutubeSearch.search("#{@artist} - #{@title}").first
    @video_url << "https://youtu.be/#{response['video_id']}"
  end
end

uptown = Youtube.new('Uptown Funk (feat. Bruno Mars)', 'Mark Ronson')
query = uptown.video_url
CreateApiRequests.new.migrate :up
ApiRequest.cache(query, Youtube::CACHE_POLICY) do
  puts self.url
end

