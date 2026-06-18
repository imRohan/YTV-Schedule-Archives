class Video::PlayerComponent < Bridgetown::Component
  def initialize(schedule:, metadata:)
    @schedule_hash = schedule.reduce(Hash.new) do |hash, row|
      hash[row.Time] = { show: row.Show, episode: row.Episode, videoID: row["Youtube Video ID"] }
      hash
    end
    @schedule_date = metadata[:date]
    @schedule_updated_at = metadata[:updated_at]
  end
end
