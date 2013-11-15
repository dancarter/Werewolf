require 'socket'
require 'thread'

#puts "Enter IP of server(Warning! IP will not be verified): "
hostname = 'localhost' #gets.chomp
port = 2000

server = TCPSocket.open(hostname, port)

listen = Thread.new do
  while line = server.gets
    puts line.chop
  end
end

while true
  listen.run
  if msg = gets.chomp
    server.puts(msg)
  end
end


server.close
