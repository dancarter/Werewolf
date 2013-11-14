class Engine
  attr_reader :players, :day, :game_over

  def initialize
    @players = []
    @day = false
    @game_over = false
    @cops = 0
    @killers = 0
  end

  def generate_player_id
    highest_id = 1
    players.each do |player|
      highest_id = player[1] + 1 if player[1] >= highest_id
    end
    highest_id
  end

  def generate_player_role
    role = nil
    role = 'cop' if @players.length == 4 and @cops < 1
    role = 'killer' if @players.length == 4 and @killers < 1
    while !role
      num = Random.rand(3) + 1
      role = 'cop' if num == 1 and @cops < 2
      role = 'killer' if num == 2 and @killers < 2
      role = 'innocent'
    end
    role
  end

  def add_player(player)
    @players << [player,generate_player_id,generate_player_role,true]
  end

  def is_game_over?
    true if @cops == 0 or @killers == 0
  end

  def collude(role,message)
    abort if is_game_over?
    victim = 0
    collusion_complete = false
    while !collusion_complete
      @players.each do |player|
        if player[2] == role && player[3] == true
          #People of role collude to chose victim, set victim variable to that players id
        else
          #People not of role receive the message
        end
      end
    end
    victim
  end

  def day
    @players.each do |player|
      #each player makes statement
    end
    @players.each do |player|
      #each player votes who to kill
    end
    town_killing(votes) #array of each persons votes goes to town_killing method and player with most votes dies
    @day = false
  end

  def night
    abort if is_game_over?
    victim_killed = collude('killer',"Killers are lurking about.")
    suspect_fingered = collude('cop',"The cops are investigating.")
    #Kill victim, report if suspect is a killer
    @day = true
  end
end
