require 'socket'
require_relative 'engine'

server = TCPServer.open(6666)
clients = []

puts "Initialized: #{server}"
puts server.addr.inspect

engine = Engine.new(self)

loop {
  Thread.start(server.accept) do |client|
    client.puts "Connected \n
                Welcome to Werewolf! \n
                Game will proceed when eight players join."
    clients << client
    engine.add_player(client)
    puts "New connection: #{client}"
  end

  sleep(1)

  if clients.length == 8
    puts engine.players
    while true
      engine.day
      engine.night
    end
  end

  #clients.each {|client| client.close}
}
