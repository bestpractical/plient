use strict;
use warnings;

use Test::More tests => 5;

use Plient;
use Plient::Test;

my $url = start_http_server();
SKIP: {
    skip 'no plackup available', 5 unless $url;
    # to test each handler, set env PLIENT_HANDLER_PREFERENCE_ONLY to true
    for my $handler (qw/curl wget HTTPTiny HTTPLite LWP/) {
        Plient->handler_preference( http => [$handler] );
        is( plient( POST => "$url/hello", { body => { name => 'foo' } } ),
            'hello foo', "post /hello using $handler" );
    }
}
