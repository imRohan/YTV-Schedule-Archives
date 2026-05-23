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
        track_show(row['Show'])
      end
      print '.'
    else
      print 'e'
      errors << "No Schedule found for #{date}"
    end
  end

  def track_show(show)
    return if show.nil?
    return if show.empty?

    shows[show] = shows.fetch(show, 0) + 1
  end

  def save_stats
    stats_rows = [['Show Name', 'Play Count']]
    shows_ranked = shows.sort_by { |_, value| - value }
    stats_rows.concat(shows_ranked)
    File.write('stats.csv', stats_rows.map(&:to_csv).join)
  end
end

generator = StatsGenerator.new
generator.generate
