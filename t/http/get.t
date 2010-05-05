use strict;
use warnings;

use Test::More tests => 8;

use Plient;
use Plient::Test;

my $url = start_http_server();
SKIP: {
    skip 'no plackup available', 4 unless $url;
    # to test each handler, set env PLIENT_HANDLER_PREFERENCE_ONLY to true
    for my $handler (qw/curl wget HTTPLite LWP/) {
        Plient->handler_preference( http => [$handler] );
        is( plient( GET => "$url/hello" ), 'hello', "get /hello using $handler" );
        is(
            plient(
                GET => "$url/hello",
                { headers => { 'User-Agent' => 'plient/0.01' } }
            ),
            'hello plient/0.01',
            "get /hello using $handler with customized agent"
        );
    }
}
