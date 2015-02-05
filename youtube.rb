require 'active_record'
require 'logger'
require 'youtube_search'

BUILD_DIR = "./db"

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: "#{BUILD_DIR}/youtube.db")
# ActiveRecord::Base.logger = Logger.new(STDOUT)

class CreateApiRequests < ActiveRecord::Migration
  def self.change
    create_table :api_requests do |t|
      t.timestamps null: false
      t.text :query, null: false
    end

    add_index :api_requests, :query, unique: true
  end
end

class ApiRequest < ActiveRecord::Base
  validates :query, presence: true, uniqueness: true

  def self.cache(title, cache_policy)
    find_or_initialize_by(query: title).cache(cache_policy) do
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
    @video_url = nil
  end

  def search_query
    "#{@artist} - #{@title}"
  end

  def set_video_url=(search_query)
    response = YoutubeSearch.search(search_query).first
    @video_url = "https://youtu.be/#{response['video_id']}"
    @video_url
  end
end

uptown = Youtube.new('Uptown Funk (feat. Bruno Mars)', 'Mark Ronson')
query = uptown.search_query
# CreateApiRequests.change
ApiRequest.cache(query, Youtube::CACHE_POLICY) do
  puts uptown.video_url
end
