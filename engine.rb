require 'player.rb'

class Engine
  attr_reader :players

  def initialize
    @players = []
  end

  def generate_player_id
    highest_id = 1
    players.each do |player|
      highest_id = player.id + 1 if player.id >= highest_id
    end
    highest_id
  end

  def add_player(player)
    @players << player
  end
end
