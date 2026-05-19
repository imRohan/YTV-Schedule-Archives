#! /usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'csv'
require 'pry'

class CsvGenerator
  attr_accessor :start_date, :end_date, :errors, :csv_rows

  def initialize(start_date: 'September 1, 1988', end_date: Date.today)
    @start_date = Date.parse(start_date)
    @end_date = end_date
    @errors = []
    @csv_rows = []
  end

  def generate
    puts "Fetching schedules between #{start_date}-#{end_date}"
    (start_date..end_date).each do |date|
      schedule = get_schedule_for_date(date)
      csv_rows = parse_schedule(schedule)
      save_csv(date: date, rows: csv_rows)
      print '.'
    rescue => e
      print 'e'
      errors << "Error for #{date}: #{e}"
    end

    puts errors
  end

  def get_schedule_for_date(date)
    month = date.strftime('%B')
    day = date.strftime('%e').strip
    year = date.strftime('%Y')
    url = "https://ytv-schedule-archives.fandom.com/wiki/#{month}_#{day},_#{year}"

    doc = Nokogiri::HTML(URI.open(url))
    schedule_table = doc.css('table')[1]
    schedule_table.css('tr')
  end

  def parse_schedule(schedule)
    csv_rows = []
    column_names = schedule.shift.css('th').map(&:text).map(&:strip)
    csv_rows << column_names

    schedule.css('tr').each do |row|
      time = row.css('th').text.strip
      data = row.css('td').map(&:text).map(&:strip)
      csv_rows << [time, *data]
    end

    csv_rows
  end

  def save_csv(date:, rows:)
    year = date.strftime('%Y')
    Dir.mkdir(year) unless File.exist?(year)
    File.write("./#{year}/#{date}.csv", rows.map(&:to_csv).join)
  end
end

generator = CsvGenerator.new(start_date: 'July 1, 2013')
generator.generate
