use strict;
use warnings;

use Test::More tests => 3;

use_ok('Plient');
use_ok('Plient::Test');

my $url = start_http_server();
SKIP: {
    skip 'no plackup available', 1 unless $url;
    is( plient( GET => "$url/hello" ), 'hello', 'get /hello' );
}
