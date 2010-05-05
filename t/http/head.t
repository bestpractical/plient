use strict;
use warnings;

use Test::More tests => 2;

use Plient;
use Plient::Test;

my $url = start_http_server();
SKIP: {
    skip 'no plackup available', 2 unless $url;
    # to test each handler, set env PLIENT_HANDLER_PREFERENCE_ONLY to true
    for my $handler (qw/curl wget/) {
        Plient->handler_preference( http => [$handler] );
        like( plient( HEAD => "$url/hello" ), qr/Plient-Head-Path: \/hello/, "get head /hello using $handler" );
    }
}
