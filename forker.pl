#!/usr/bin/perl

use strict;
use warnings;

my $process = Process->new;
$process->test ({key => 'value'});

package Process;

use strict;
use warnings;
use Carp;
use IO::Socket::SIPC;

sub new
{
  my ($class, @args) = @_;

  # fork off the worker process
  my $pid = fork;
  if (not defined $pid)
  {
    croak "failed to create process: $!";
  }
  elsif ($pid == 0)
  {
    # child, create the server
    my $server = Server->new (@args);
    $server->run;

    return 1;
  }
  else
  {
    # parent, create the client
    return Client->new (@args);
  }
}

package Client;

use strict;
use warnings;
use Carp;
use IO::Socket::SIPC;

sub new
{
  my ($class, @args) = @_;

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

  bless {
    sipc => $sipc,
    @args
  }, $class;
}

sub test
{
  my ($self, @args) = @_;
  $self->{sipc}->send (@args);
}

package Server;

use strict;
use warnings;
use Carp;
use IO::Socket::SIPC;

sub new
{
  my ($class, @args) = @_;

  my $sipc = IO::Socket::SIPC->new(
    socket_handler => 'IO::Socket::INET',
    use_check_sum  => 1,
  );

  $sipc->connect(
    LocalAddr  => 'localhost',
    LocalPort  => 50010, # TODO: process specific
    Proto      => 'tcp',
    Listen     => 10,
    Reuse      => 1,
  ) or croak $sipc->errstr;

  $sipc->debug(1);

  bless {
    sipc => $sipc,
    @args
  }, $class;
}

sub run
{
  my ($self) = @_;
  while ( 1 ) 
  {
    my $client;
    while ( $client = $self->{sipc}->accept(10) ) 
    {
      print "connect from client: ", $client->sock->peerhost, "\n";
      my $request = $client->read_raw or die $client->errstr;
      next unless $request;
      chomp($request);
      warn "client says: $request\n";
      $client->send({ foo => 'is foo', bar => 'is bar', baz => 'is baz'}) or die $client->errstr;
      $client->disconnect or die $client->errstr;
    }
    die $self->{sipc}->errstr unless defined $client;
    warn "server runs on a timeout, re-listen on socket\n";
  }

  $self->{sipc}->disconnect or die $self->{sipc}->errstr;
}

package Module;

use strict;
use warnings;
use base qw/Server/;

