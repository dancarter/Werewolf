require 'socket'
require 'thread'

puts "Enter IP of server(Warning! Input will not be verified): "
hostname = gets.chomp
port = 6666

server = TCPSocket.open(hostname, port)

listen = Thread.new do  #Thread to listen for messages from the server
  while line = server.gets
    puts line.chop
  end
end

while true
  listen.run #Run listening thread
  if msg = gets.chomp #Send user input to the server
    server.puts(msg)
  end
end


server.close
