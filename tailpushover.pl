#!/usr/bin/perl

use v5.14;
use strict;
use warnings;

use IO::File;
use WWW::Mechanize;

sub main() {
    my $webhook_url = 'https://api.pushover.net/1/messages.json';

    my $token = $ARGV[0] or die 'no token';
    my $user = $ARGV[1] or die 'no user';
    my $filename = $ARGV[2] or die 'no filename';
    my $filter = $ARGV[3] // '';

    my $fh = IO::File->new("tail -F -n0 ${filename} |");
    my $ua = WWW::Mechanize->new(autocheck => 0);

    while (my $line = <$fh>) {
        next unless $line =~ $filter;

        my $res = $ua->post(
            $webhook_url, [
                token => $token,
                user => $user,
                message => $line,
            ]
        );

        say $res->decoded_content if $ua->status != 200;
    }

    $fh->close;
}

&main;

__END__
