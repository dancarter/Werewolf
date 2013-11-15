require 'socket'

class Engine
  attr_reader :players

  def initialize(server)
    @players = {}
    @game_over = false
    @hunters = 0
    @werewolfs = 0
    @players_alive = 0
    @server = server
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
    @players[generate_player_id] = [player,role,true]
    player.puts "Added to game. Your role: #{role}"
  end

  def game_won?
    if @werewolfs >= @players_alive
      message_all("The werewolfs have won!")
      return true
    elsif @werewolfs == 0
      message_all("The werewolfs have been thwarted!")
      return true
    end
    false
  end

  def good_input?(input)
    return false if input =~ /[a-zA-Z]/
    input = input.to_i
    return false if input < 1 or input > 8
    return false if !@players[input][2]
    true
  end

  def message_all(message)
    @players.each_key do |key|
      @players[key][0].puts message
    end
  end

  def murder_player(dead_player)
    @players[dead_player][0].puts "You have been killed."
    @players[dead_player][2] = false
    @hunters -= 1 if @players[dead_player][1] == 'hunter'
    @werewolfs -= 1 if @players[dead_player][1] == 'werewolf'
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
    message_all("Player #{murdered_player} has been lynched by the mob.")
  end

  def collude(role, message)
    vic = 0
    collusion_complete = false
    dead_associate = false
    while !collusion_complete
      @players.each_key do |key|
          if @players[key][1] == role and @players[key][2]
            vic_2 = 0
            while !good_input?(vic_2)
              @players[key][0].puts "#{role.capitalize}, who do you choose?" if vic == 0
              @players[key][0].puts "#{role.capitalize}, your associate chose #{vic}, who will you choose?" if vic != 0 and !dead_associate
              vic_2 = @players[key][0].gets.chomp
            end
            collusion_complete = true if vic_2 == vic
            vic = vic_2
          elsif @players[key][1] == role
            dead_associate = true
          else
            @players[key][0].puts message
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
      if @players[key][2]
        @players[key][0].puts "What is your statement?: "
        msg = @players[key][0].gets
      else
        @players[key][0].puts "The dead don't speak."
      end
      if msg
        @players.each_key do |key2|
          @players[key2][0].puts "Player #{key}: " + msg unless key2 == key
        end
      end
    end
    votes = []
    @players.each_key do |key|
      #each player votes who to kill
      vote = 0
      while !good_input?(vote)
        if @players[key][2]
          @players[key][0].puts "Who is a werewolf? (Enter player #): "
          vote = @players[key][0].gets.chop
        else
          @players[key][0].puts "The dead don't vote."
          break
        end
      end
      votes << vote.to_i unless !@players[key][2]
    end
    town_killing(votes) #array of each persons votes goes to town_killing method and player with most votes dies
  end

  def night
    message_all("The darkness of night has fallen. Beware.")
    victim_killed = collude('werewolf',"Werewolves are on the prowl.")
    suspect_fingered = collude('hunter',"The hunters are investigating.")
    murder_player(victim_killed.to_i)
    message_all("Player #{victim_killed} has been murdered.")
    @players.each_key do |key|
      @players[key][0].puts "Player #{suspect_fingered} is a/an #{@players[suspect_fingered.to_i][1]}." if @players[key][1] == 'hunter' and @players[key][2]
    end
  end
end
