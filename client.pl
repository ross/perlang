#!/usr/bin/perl

use strict;
use Socket;

# initialize host and port
my $host = shift || 'localhost';
my $port = shift || 7890;

my $proto = getprotobyname('tcp');

# get the port address
my $iaddr = inet_aton($host);
my $paddr = sockaddr_in($port, $iaddr);
# create the socket, connect to the port
socket(SOCKET, PF_INET, SOCK_STREAM, $proto)
  or die "socket: $!";
connect(SOCKET, $paddr) or die "connect: $!";

my $line;
while ($line = <SOCKET>)
{
  print $line;
}
close SOCKET or die "close: $!";
