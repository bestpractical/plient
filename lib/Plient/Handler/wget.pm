package Plient::Handler::wget;
use strict;
use warnings;

use base 'Plient::Handler';
use Plient::Util 'which';

my ( $wget, %protocol, %all_protocol, %method );

%all_protocol =
  map { $_ => undef } qw/http https ftp/;
sub all_protocol { return \%all_protocol }

#XXX TODO get the real protocols wget supports
@protocol{qw/http https ftp/} = ();

sub protocol { return \%protocol }
sub method { return \%method }

my $inited;
sub init {
    return if $inited;
    $inited = 1;

    $wget        = $ENV{PLIENT_WGET}        || which('wget');
    return unless $wget;

    if ( exists $protocol{http} ) {
        $method{http_get} = sub {
            my ( $uri, $args ) = @_;
            if ( open my $fh, "$wget -q -O - $uri |" ) {
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
    $method{https_get} = $method{http_get} if exists $protocol{https};
    return 1;
}

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

