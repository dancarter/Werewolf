require 'socket'
#require_relative 'player'

#puts "Enter IP of server(Warning! IP will not be verified): "
hostname = 'localhost' #gets.chomp
port = 2000

server = TCPSocket.open(hostname, port)
#player = Player.new

while line = server.gets
  puts line.chop
end

server.close
