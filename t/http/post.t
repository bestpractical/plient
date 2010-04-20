use strict;
use warnings;

use Test::More tests => 6;

use_ok('Plient');
use_ok('Plient::Test');

my $url = start_http_server();
SKIP: {
    skip 'no plackup available', 1 unless $url;
    # to test each handler, set env PLIENT_HANDLER_PREFERENCE_ONLY to true
    for my $handler (qw/curl wget HTTPLite LWP/) {
        Plient->handler_preference( http => [$handler] );
        is( plient( POST => "$url/hello", { body => { name => 'foo' } } ),
            'hello foo', "post /hello using $handler" );
    }
}
