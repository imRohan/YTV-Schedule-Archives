#! /usr/bin/env ruby

require 'active_support/core_ext/object/blank'
require 'dotenv/load'
require 'google/apis/youtube_v3'
require 'csv'
require 'pry'

class ScheduleUpdater
  attr_accessor :date, :client, :year, :quota_reached

  def initialize(date:, client: Google::Apis::YoutubeV3::YouTubeService.new,
                 year: 2001)
    @date = date
    @client = client
    @year = year
    @quota_reached = false
  end

  def call
    configure_client
    process_schedule
  end

  def configure_client
    client.key = ENV.fetch('GOOGLE_API_KEY')
  end

  def schedule_date
    month = date.strftime('%B')
    day = date.day
    Date.parse("#{month} #{day}, #{year}")
  end

  def process_schedule
    puts "Updating schedule for #{schedule_date}"
    year = schedule_date.strftime('%Y')
    file_path = "./#{year}/#{schedule_date}.csv"
    if File.exist?(file_path)
      update_existing_schedule(file_path: file_path, date: date)
    else
      puts '❎'
    end
  end

  def update_existing_schedule(file_path:, date:)
    schedule_rows = [['Time', 'Show', 'Episode', 'Youtube Video ID']]
    CSV.foreach(file_path, headers: true) do |row|
      schedule_rows << parse_and_update_show(row: row)
    end
    update_frontend_schedule(rows: schedule_rows, date: date)
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
    print "#{show} #{episode} - #{existing_id} "
    if existing_id.present?
      puts '✅'
      existing_id
    else
      query_youtube!(show: show, episode: episode)
    end
  rescue => error
    @quota_reached = true
    nil
  end

  def query_youtube!(show:, episode:)
    if quota_reached
      puts '🛑'
      nil
    else
      search_string = generate_search_string(show: show, episode: episode)
      search_response = client.list_searches(['snippet'], q: search_string)

      video = search_response.items.detect do |item|
        item.id.kind == 'youtube#video'
      end

      if video.present?
        puts '🆕'
        video.id.video_id
      else
        puts '🐛'
        nil
      end
    end
  end

  def generate_search_string(show:, episode:)
    if episode.blank?
      "#{show} full episode"
    else
      "#{show} - #{episode} full episode"
    end
  end

  def update_frontend_schedule(rows:, date:)
    return if quota_reached
    save_frontend_schedule(rows: rows)
    save_frontend_schedule_metadata(date: date)
  end

  def save_frontend_schedule(rows:)
    file_path = './src/_data/schedule.csv'
    File.write(file_path, rows.map(&:to_csv).join)
  end

  def save_frontend_schedule_metadata(date:)
    metadata = {
      date: date.to_s,
      updated_at: Time.now.strftime('%d/%m/%Y %H:%M')
    }.transform_keys(&:to_s)
    file_path = './src/_data/schedule_metadata.yml'
    File.write(file_path, YAML.dump(metadata))
  end
end

updater = ScheduleUpdater.new(date: Date.today)
updater.call
