#!/usr/bin/env perl -w
use strict;
use warnings;
use Plack::Builder;
my $app = sub {
    my $env = shift;
    if ( $env->{REQUEST_METHOD} eq 'GET' ) {
        if ( $env->{PATH_INFO} eq '/hello' ) {
            return [ 200, [ 'Content-Type' => 'text/plain' ], ['hello'] ] 
        }
    }
    [ 200, [], ['ok']];
};

builder {
#    enable 'Debug';
    $app;
};

