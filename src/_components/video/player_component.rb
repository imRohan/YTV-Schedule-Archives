class Video::PlayerComponent < Bridgetown::Component
  def initialize(schedule:, metadata:, interstitial_content:)
    @schedule_hash = schedule.each_with_object({}) do |row, hash|
      hash[row.Time] = { time: row.Time, show: row.Show, episode: row.Episode,
                         videoID: row["Youtube Video ID"] }
      hash
    end
    @interstitial_video_ids = interstitial_content.map do |row|
      row["Youtube Video ID"]
    end
    @schedule_date = metadata[:date]
    @schedule_updated_at = metadata[:updated_at]
  end
end
