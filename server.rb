require 'socket'
require_relative 'engine'

server = TCPServer.open(2000)
clients = []

puts "Initialized: #{server}"

engine = Engine.new(self)

loop {
  Thread.start(server.accept) do |client|
    client.puts "Connected \n
                Welcome to Werewolf! \n
                Game will proceed when eight players join."
    clients << client
    engine.add_player(client)
  end

  sleep(1)

  puts engine.players
  puts clients.length
  if clients.length == 8
    puts 'hi'
    while true
      engine.day
      engine.night
    end
  end

  #clients.each {|client| client.close}
}
