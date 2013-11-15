require 'socket'
require_relative 'engine'

server = TCPServer.open(6666)
clients = []

puts "Initialized: #{server}"
puts server.addr.inspect

engine = Engine.new(self)

server_message_listener = Thread.new do
  while line = gets.chomp
    clients.each do |client|
      client.puts "SERVER MESSAGE: " + line
    end
  end
end

loop {
  Thread.start(server.accept) do |client|
    client.puts "Connected \n
                Welcome to Werewolf! \n
                Game will proceed when eight players join."
    clients << client
    engine.add_player(client)
    puts "New connection: #{client}"
    clients.each do |connected_client|
      connected_client.puts "Currently #{clients.length} player(s) is/are connected."
    end
  end

  sleep(1)

  server_message_listener.run

  if clients.length == 8
    puts engine.players
    while true
      engine.day
      break if engine.game_won?
      engine.night
      break if engine.game_won?
    end
  end

  #clients.each {|client| client.close}
}
