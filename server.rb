require 'socket'
require_relative 'engine'

server = TCPServer.open(2000)

puts "Initialized: #{server}"

engine = Engine.new

loop {
  client = server.accept
  puts "Established Connection: #{client}"
  engine.add_player(client)
  client.puts('Hello')
  client.close
}
