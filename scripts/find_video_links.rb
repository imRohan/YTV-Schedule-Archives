#! /usr/bin/env ruby

require 'active_support/core_ext/object/blank'
require 'dotenv/load'
require 'google/apis/youtube_v3'
require 'csv'
require 'pry'

class LinkFinder
  attr_accessor :start_date, :end_date, :client, :quota_reached

  def initialize(start_date: 'January 1, 2000', end_date: Date.today.to_s,
                 client: Google::Apis::YoutubeV3::YouTubeService.new)
    @start_date = Date.parse(start_date)
    @end_date = Date.parse(end_date)
    @client = client
    @quota_reached = false
  end

  def call
    configure_client
    read_and_process_schedules
  end

  def configure_client
    client.key = ENV.fetch('GOOGLE_API_KEY')
  end

  def read_and_process_schedules
    puts "Reading schedules between #{start_date} & #{end_date}"
    (start_date..end_date).each do |date|
      if quota_reached
        puts "Quota reached: #{date}"
        break
      else
        process_schedule(date)
      end
    end
  end

  def process_schedule(date)
    year = date.strftime('%Y')
    file_path = "./#{year}/#{date}.csv"
    if File.exist?(file_path)
      update_existing_schedule(file_path: file_path)
    else
      print 'e'
    end
  end

  def update_existing_schedule(file_path:)
    schedule_rows = [['Time', 'Show', 'Episode', 'Youtube Video ID']]
    CSV.foreach(file_path, headers: true) do |row|
      schedule_rows << parse_and_update_show(row: row)
    end
    save_schedule(rows: schedule_rows, file_path: file_path)
  end

  def parse_and_update_show(row:)
    time = row['Time']
    show = row['Show'].presence
    episode = row['Episode'].presence
    youtube_id = find_youtube_id(existing_id: row['Youtube Video ID'],
                                 show: show, episode: episode)
    [time, show, episode, youtube_id]
  end

  def find_youtube_id(existing_id:, show:, episode:)
    if existing_id.present?
      print '*'
      existing_id
    else
      query_youtube!(show: show, episode: episode)
    end
  rescue => error
    @quota_reached = true
    nil
  end

  def query_youtube!(show:, episode:)
    search_string = generate_search_string(show: show, episode: episode)
    search_response = client.list_searches(['snippet'], q: search_string)

    video = search_response.items.detect do |item|
      item.id.kind == 'youtube#video'
    end

    if video.present?
      print '^'
      video.id.video_id
    else
      print '?'
      nil
    end
  end

  def generate_search_string(show:, episode:)
    if episode.blank?
      "#{show} full episode"
    else
      "#{show} - #{episode} full episode"
    end
  end

  def save_schedule(rows:, file_path:)
    File.write(file_path, rows.map(&:to_csv).join)
  end
end

finder = LinkFinder.new
finder.call
