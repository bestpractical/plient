use strict;
use warnings;

use Test::More tests => 2;

use_ok( 'Plient' );

ok( Plient->available('File','GET'), 'supports File GET' );
# ok( Plient->available('HTTP','GET'), 'supports HTTP GET' );
