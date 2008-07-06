#!/usr/bin/perl

# server0.pl
#--------------------

use strict;
use Socket;

# use port 7890 as default
my $port = shift || 7890;
my $proto = getprotobyname('tcp');

# create a socket, make it reusable
socket(SERVER, PF_INET, SOCK_STREAM, $proto) or die "socket: $!";
setsockopt(SERVER, SOL_SOCKET, SO_REUSEADDR, 1) or die "setsock: $!";

# grab a port on this machine
my $paddr = sockaddr_in($port, INADDR_ANY);

# bind to a port, then listen
bind(SERVER, $paddr) or die "bind: $!";
listen(SERVER, SOMAXCONN) or die "listen: $!";
print "SERVER started on port $port ";

# accepting a connection
my $client_addr;
while ($client_addr = accept(CLIENT, SERVER))
{
# find out who connected
  my ($client_port, $client_ip) = sockaddr_in($client_addr);
  my $client_ipnum = inet_ntoa($client_ip);
  my $client_host = gethostbyaddr($client_ip, AF_INET);
# print who has connected
  print "got a connection from: $client_host","[$client_ipnum] ";
# send them a message, close connection
  print CLIENT "Smile from the server\n";
  close CLIENT;
}
