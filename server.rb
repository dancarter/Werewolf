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

  if clients.length == 8
    while true

    end
  end
}
