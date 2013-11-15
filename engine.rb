require 'socket'
require_relative 'player_handler'

class Engine
  attr_reader :players

  def initialize
    @players = {}
    @interacter = PlayerHandler.new
    @hunters = 0
    @werewolfs = 0
    @players_alive = 0
    @available_roles = ['hunter','hunter','werewolf','werewolf','innocent','innocent','innocent','innocent'].shuffle
  end

  def generate_player_id
    highest_id = 1
    players.each_key do |id|
      highest_id = id + 1 if id >= highest_id
    end
    highest_id
  end

  def assign_player_role
    @available_roles.shift
  end

  def add_player(player)
    role = assign_player_role
    id = generate_player_id
    @players[id] = [role,true]
    @interacter.add_player(player)
    @interacter.send_player_message(id,"Added to game. Your role: #{role}")
  end

  def game_won?
    if @werewolfs >= @players_alive
      @interacter.send_all_message("The werewolves have won!")
      return true
    elsif @werewolfs == 0
      @interacter.send_all_message("The werewolves have been thwarted!")
      return true
    end
    false
  end

  def good_input?(input)
    return false if input =~ /[a-zA-Z]/
    input = input.to_i
    return false if input < 1 or input > 8
    return false if !@players[input][1]
    true
  end

  def murder_player(dead_player)
    @interacter.send_player_message(dead_player,"You have been killed.")
    @players[dead_player][1] = false
    @hunters -= 1 if @players[dead_player][0] == 'hunter'
    @werewolfs -= 1 if @players[dead_player][0] == 'werewolf'
    @players_alive -= 1
  end

  def town_killing(votes)
    most_votes = 0
    murdered_player = 0
    votes.uniq.each do |elem|
      if votes.count(elem) > most_votes
        most_votes = votes.count(elem)
        murdered_player = elem
      end
    end
    murder_player(murdered_player)
    @interacter.send_all_message("Player #{murdered_player} has been lynched by the mob.")
  end

  def collude(role, message)
    vic = 0
    collusion_complete = false
    dead_associate = false
    while !collusion_complete
      @players.each_key do |key|
          if @players[key][0] == role and @players[key][1]
            vic_2 = 0
            while !good_input?(vic_2)
              @interacter.send_player_message(key,"#{role.capitalize}, who do you choose?") if vic == 0
              @interacter.send_player_message(key,"#{role.capitalize}, your associate chose #{vic}, who will you choose?") if vic != 0 and !dead_associate
              vic_2 = @players[key][0].gets.chomp
            end
            collusion_complete = true if vic_2 == vic
            vic = vic_2
          elsif @players[key][0] == role
            dead_associate = true
          else
            @interacter.send_player_message(key, message)
          end
      end
    end
    vic
  end

  def day
    message_all("The sun shines on a new day.")
    @players.each_key do |key|
      #each living player makes statement
      msg = nil
      if @players[key][1]
        @interacter.send_player_message(key,"What is your statement?: ")
        msg = @interacter.send_player_message(key)
      else
        @interacter.send_player_message(key,"The dead don't speak.")
      end
      if msg
        @players.each_key do |key2|
          @interacter.send_player_message(key2,"Player #{key}: " + msg) unless key2 == key
        end
      end
    end
    votes = []
    @players.each_key do |key|
      #each player votes who to kill
      vote = 0
      while !good_input?(vote)
        if @players[key][1]
          @interacter.send_player_message(key,"Who is a werewolf? (Enter player #): ")
          vote = @interacter.get_player_message(key)
        else
          @interacter.send_player_message(key,"The dead don't vote.")
          break
        end
      end
      votes << vote.to_i unless !@players[key][1]
    end
    town_killing(votes) #array of each persons votes goes to town_killing method and player with most votes dies
  end

  def night
    message_all("The darkness of night has fallen. Beware.")
    victim_killed = collude('werewolf',"Werewolves are on the prowl.")
    suspect_fingered = collude('hunter',"The hunters are investigating.")
    murder_player(victim_killed.to_i)
    @interacter.send_all_message("Player #{victim_killed} has been murdered.")
    @players.each_key do |key|
      @interacter.send_player_message(key,"Player #{suspect_fingered} is a/an #{@players[suspect_fingered.to_i][1]}.") if @players[key][0] == 'hunter' and @players[key][1]
    end
  end
end
