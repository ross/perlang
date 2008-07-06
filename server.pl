#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket::SIPC;

my $sipc = IO::Socket::SIPC->new(
  socket_handler => 'IO::Socket::INET',
  use_check_sum  => 1,
);

$sipc->connect(
  LocalAddr  => 'localhost',
  LocalPort  => 50010,
  Proto      => 'tcp',
  Listen     => 10,
  Reuse      => 1,
) or die $sipc->errstr;

$sipc->debug(1);

while ( 1 ) {
  my $client;
  while ( $client = $sipc->accept(10) ) {
    print "connect from client: ", $client->sock->peerhost, "\n";
    my $request = $client->read_raw or die $client->errstr;
    next unless $request;
    chomp($request);
    warn "client says: $request\n";
    $client->send({ foo => 'is foo', bar => 'is bar', baz => 'is baz'}) or die $client->errstr;
    $client->disconnect or die $client->errstr;
  }
  die $sipc->errstr unless defined $client;
  warn "server runs on a timeout, re-listen on socket\n";
}

$sipc->disconnect or die $sipc->errstr;
