#! /usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'csv'
require 'pry'

first_schedule_date = Date.parse('September 1, 1988')
today = Date.today
errors = []

(first_schedule_date..today).each do |date|
  month = date.strftime('%B')
  day = date.strftime('%e').strip
  year = date.strftime('%Y')
  file_name = "#{month}_#{day}_#{year}.csv"
  Dir.mkdir(year) unless File.exist?(year)

  begin
    url = "https://ytv-schedule-archives.fandom.com/wiki/#{month}_#{day},_#{year}"

    doc = Nokogiri::HTML(URI.open(url))
    csv_rows = []

    schedule_table = doc.css('table')[1]
    rows = schedule_table.css('tr')

    column_names = rows.shift.css('th').map(&:text).map(&:strip)
    csv_rows << column_names

    rows.css('tr').each do |row|
      time = row.css('th').text.strip
      data = row.css('td').map(&:text).map(&:strip)
      csv_rows << [time, *data]
    end

    File.write("./#{year}/#{date}.csv", csv_rows.map(&:to_csv).join)
    print '.'
  rescue => e
    print 'e'
    errors << "Error for #{file_name}: #{e}"
  end
end
