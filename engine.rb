require 'socket'

class Engine
  attr_reader :players, :day, :game_over

  def initialize(server)
    @players = {}
    @day = false
    @game_over = false
    @cops = 0
    @killers = 0
    @server = server
  end

  def generate_player_id
    highest_id = 1
    players.each_key do |id|
      highest_id = id + 1 if id >= highest_id
    end
    highest_id
  end

  def generate_player_role
    role = nil
    role = 'killer' if @players.length == 4 and @killers < 1
    role = 'cop' if @players.length == 4 and @cops < 1
    return role if role
    while !role
      num = (Random.rand(3)) + 1
      role = 'cop' if num == 1 and @cops < 2
      role = 'killer' if num == 2 and @killers < 2
      role = 'innocent' if !role
    end
    role
  end

  def add_player(player)
    role = generate_player_role
    @players[generate_player_id] = [player,role,true]
    player.puts "Added to game. Your role: #{generate_player_role}"
  end

  def is_game_over?
    true if @cops == 0 or @killers == 0
  end

  def good_input?(input)
    return false if input =~ /[a-zA-Z]/
    input = input.to_i
    return false if input < 1 or input > 8
    return false if !@players[input][2]
    true
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
    @players.each_key do |key|
      @players[key][0].puts "Player #{murdered_player} has been lynched by the mob."
    end
    @players[murdered_player][2] = false
    @cops -= 1 if @players[murdered_player][1] == 'cop'
    @killers -= 1 if @players[murdered_player][1] == 'killer'
  end

  def collude(role,message)
    abort if is_game_over?
    victim_1, victim_2, victim = 0, 0, 0
    collusion_complete = false
    while !collusion_complete
      @players.each_key do |key|
        if player[key][1] == role && player[key][2] == true
          #People of role collude to choose victim, set victim variable to that players id
          vic = nil
          while !good_input(vic)
            player[key][0].puts "#{role.capitalize}, who do you choose? (enter player #): "
            vic = player[key][0].gets
          end
          victim_2 = vic if victim_1 != 0
          victim_1 = vic unless victim_1 != 0
        else
          player[key][0].puts message
        end
      end
      if victim_1 != 0 and victim_2 != 0 and victim_2 != victim_1
        @players.each_key {|key| @players[key][0].puts "A decision has not been made."}
      else
        collusion_complete = true
        victim = victim_1
      end
    end
    victim
  end

  def day
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
          @players[key][0].puts "Who is a killer? (Enter player #): "
          vote = @players[key][0].gets.chop
        else
          @players[key][0].puts "The dead don't vote."
          break
        end
      end
      votes << vote.to_i unless !@players[key][2]
    end
    town_killing(votes) #array of each persons votes goes to town_killing method and player with most votes dies
    @day = false
  end

  def night
    abort if is_game_over?
    victim_killed = collude('killer',"Killers are lurking about.")
    suspect_fingered = collude('cop',"The cops are investigating.")
    @players[victim_killed][2] = false
    ops -= 1 if @players[victim_killed][1] == 'cop'
    killers -= 1 if @players[victim_killed][1] == 'killer'
    @players.each_key do |key|
      @players[key][0].puts "#{victim_killed} has been murdered."
      @players[key][0].puts "#{suspect_fingered} is a/an #{@players[suspect_fingered][2]}." unless @players[key][2] != 'cop'
    end
    @day = true
  end
end
