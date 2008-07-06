#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use IO::Socket::SIPC;

my $sipc = IO::Socket::SIPC->new(
  socket_handler => 'IO::Socket::INET',
  use_check_sum  => 1,
);

$sipc->connect(
  PeerAddr => 'localhost',
  PeerPort => 50010,
  Proto    => 'tcp',
) or die $sipc->errstr;

$sipc->debug(1);

$sipc->send_raw("Hello server, gimme some data :-)\n") or die $sipc->errstr;
my $answer = $sipc->read or die $sipc->errstr;
warn "server data: \n";
warn Dumper($answer);
$sipc->disconnect or die $sipc->errstr;
