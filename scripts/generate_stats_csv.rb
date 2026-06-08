#! /usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'csv'
require 'pry'

class StatsGenerator
  attr_accessor :start_date, :end_date, :errors, :shows

  def initialize(start_date: 'September 1, 1988', end_date: Date.today.to_s)
    @start_date = Date.parse(start_date)
    @end_date = Date.parse(end_date)
    @errors = []
    @shows = {}
  end

  def generate
    puts "Reading schedules between #{start_date}-#{end_date}"
    (start_date..end_date).each do |date|
      parse_schedule_for_date(date)
    end

    save_stats
    puts errors
  end

  def parse_schedule_for_date(date)
    year = date.strftime('%Y')
    file_path = "./#{year}/#{date}.csv"
    if File.exist?(file_path)
      CSV.foreach(file_path, headers: true) do |row|
        track_show(show: row['Show'], episode: row['Episode'], date: date)
      end
      print '.'
    else
      print 'e'
      errors << "No Schedule found for #{date}"
    end
  end

  def track_show(show:, episode:, date:)
    return if show.nil?
    return if show.empty?

    record = { date: date.to_s, episode: episode }
    shows[show] = shows.fetch(show, []) << record
  end

  def save_stats
    stats_rows = [['Show Name', 'Date Aired', 'Episode Name']]
    shows.each do |show, episodes|
      episodes.each do |episode|
        stats_rows << [show, episode[:date], episode[:episode]]
      end
    end
    File.write('stats.csv', stats_rows.map(&:to_csv).join)
  end
end

generator = StatsGenerator.new
generator.generate
