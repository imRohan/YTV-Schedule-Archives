class Ui::ReactionComponent < Bridgetown::Component
  def initialize
    @reactions = %w[👋 🔥 ❤️ 🥹]
    @reactions_map = @reactions.each_with_object({}) do |icon, hash|
      hash[SecureRandom.uuid] = icon
      hash
    end
  end
end
