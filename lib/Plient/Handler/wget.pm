package Plient::Handler::wget;
use strict;
use warnings;

my ( $wget, %protocol, %method );
sub method { $method{ $_[-1] } }
#XXX TODO get the real protocols wget supports
@protocol{qw/HTTP HTTPS/} = ();
use Config;
sub init {
    $wget        = $ENV{PLIENT_WGET}        || 'wget' . $Config{_exe};
    return unless $wget;

    if ( exists $protocol{HTTP} ) {
        $method{http_get} = sub {
            my ( $uri, $args ) = @_;
            if ( open my $fh, "$wget -q -L $uri |" ) {
                local $/;
                <$fh>;
            }
            else {
                warn "failed to get $uri with wget: $!";
                return;
            }
        };
    }

    # have you seen https is available while http is not?
    $method{https_get} = $method{http_get} if exists $protocol{HTTPS};
    return 1;
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

