#!/usr/bin/env perl -w
use strict;
use warnings;
use Plack::Builder;
use Plack::Request;
my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
    if ( $req->method eq 'GET' ) {
        if ( $req->path eq '/hello' ) {
            return [ 200, [ 'Content-Type' => 'text/plain' ], ['hello'] ] 
        }
    }
    if ( $req->method eq 'POST' ) {
        my $name = $req->body_parameters->get_all('name');
        if ( $req->path eq '/hello' ) {
            return [ 200, [ 'Content-Type' => 'text/plain' ], ["hello $name"] ]; 
        }
    }
    [ 200, [], ['ok']];
};

builder {
#    enable 'Debug';
    $app;
};

