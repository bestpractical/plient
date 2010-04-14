use Test::More tests => 2;

BEGIN {
use_ok( 'Plient' );
use_ok( 'Plient::HTTP' );
}

diag( "Testing Plient $Plient::VERSION" );
