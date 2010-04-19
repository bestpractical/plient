package Plient::Test;

use warnings;
use strict;
use Carp;
use Plient::Util 'which';
use File::Spec::Functions;
use FindBin '$Bin';

use base 'Exporter';
our @EXPORT = qw/start_http_server/;
my @pids;

sub start_http_server {
    my $plackup = which('plackup');
    return unless $plackup;

    my $psgi = catfile( $Bin, 'app.psgi' );
    my $port = 5000 + int(rand(1000));
    my $pid = fork;
    if ( defined $pid ) {
        if ($pid) {
            sleep 1; # give plackup sometime to run ;)
            push @pids, $pid;
            return "http://localhost:$port";
        }
        else {
            exec "plackup --port $port -E deployment $psgi";
            exit;
        }
    }
    else {
        die "fork server failed";
    }
}

END {
    kill TERM => @pids;
}

1;

__END__

=head1 NAME

Plient::Test - 


=head1 SYNOPSIS

    use Plient::Test;

=head1 DESCRIPTION


=head1 INTERFACE


=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2010 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

