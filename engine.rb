require 'player.rb'

class Engine
  attr_reader :players, :day, :game_over

  def initialize
    @players = []
    @day = false
    @game_over = false
  end

  def generate_player_id
    highest_id = 1
    players.each do |player|
      highest_id = player[1] + 1 if player[1] >= highest_id
    end
    highest_id
  end

  def add_player(player)
    @players << [player,generate_player_id]
  end
end
