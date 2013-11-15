require 'socket'
require 'thread'

puts "Enter IP of server(Warning! Input will not be verified): "
hostname = gets.chomp
port = 6666

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
