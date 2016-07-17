#!/Users/robn/.plenv/versions/5.24.0/bin/perl

use 5.024;
use warnings;
use strict;

use AnyEvent;
use AnyEvent::SlackRTM;
use AnyEvent::HTTP;
use JSON;
use WWW::Form::UrlEncoded;
use Try::Tiny;
use FindBin;

chomp(my $api_token = do { local (@ARGV, $/) = ("$FindBin::Bin/api_key") });

my $cv = AnyEvent->condvar;

my $slack = AnyEvent::SlackRTM->new($api_token);

$slack->on(finish => sub {
  $cv->send;
});

$slack->on(message => sub {
  my $data = pop @_;

  try {
    return if $data->{subtype}; # ignore bot chatter, joins, etc
    return if $data->{reply_to}; # ignore leftovers from previous connection

    my ($my_name, $my_id) = @{$slack->metadata->{self}}{qw(name id)};

    return if $data->{user} eq $my_id; # ignore messages from myself

    my $text = $data->{text};
    return unless length $text;

    my $action = $text =~ m{\b$my_name\b} || $text =~ m{<\@$my_id>} ? "alert" : "activity";

    http_get "http://localhost:5595/$action", sub {};
  }
  catch {
    warn "message handler failed: $_\n";
  };
});

$slack->start;
$cv->recv;
