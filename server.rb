require 'socket'
#require_relative 'engine'
#require_relative 'player'

server = TCPServer.open(2000)

puts "Initialized: #{server}"

#engine = Engine.new

loop {
  client = server.accept
  puts "Established Connection: #{client}"
  client.puts('Welcome to Werewolf!')
  client.close
}
