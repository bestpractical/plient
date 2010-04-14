package Plient::Handler::wget;
use strict;
use warnings;

use File::Which 'which';

my ( $wget, $wget_config, %protocol, %method );
sub method { $method{ $_[-1] } }

sub init {
    $wget        = $ENV{PLIENT_WGET}        || which('wget');
    $wget_config = $ENV{PLIENT_WGET_CONFIG} || which('wget-config');
    return unless $wget && $wget_config;
    if ( my $out = `$wget_config --protocols` ) {
        @protocol{ split /\r?\n/, $out } = ();
    }
    else {
        warn $!;
        return;
    }

    if ( exists $protocol{HTTP} ) {
        $method{http_get} = sub {
            my ( $uri, $args ) = @_;
            if ( open my $fh, "$wget -q -L $uri |" ) {
                local $/;
                <$fh>;
            }
            else {
                warn "failed to wget $uri: $!";
                return;
            }
        };
    }
}

init();

1;

=head1 NAME

Plient::Handler::wget - 


=head1 SYNOPSIS

    use Plient::Handler::wget;

=head1 DESCRIPTION


=head1 INTERFACE

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2010 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

