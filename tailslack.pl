#!/usr/bin/perl

use v5.14;
use strict;
use warnings;

use IO::File;
use JSON::PP;
use WWW::Mechanize;

sub main() {
    my $webhook_url = $ARGV[0] or die 'no webhook_url';
    my $filename = $ARGV[1] or die 'no filename';
    my $filter = $ARGV[2] // '';

    my $fh = IO::File->new("tail -F -n0 ${filename} |");
    my $ua = WWW::Mechanize->new(autocheck => 0);

    while (my $line = <$fh>) {
        next unless $line =~ $filter;

        my $payload = {text => $line, type => 'plain_text'};

        my $res = $ua->post(
            $webhook_url,
            'Content-Type' => 'application/json',
            Content => encode_json($payload),
        );

        say $res if $ua->status != 200;
    }

    $fh->close;
}

&main;

__END__
