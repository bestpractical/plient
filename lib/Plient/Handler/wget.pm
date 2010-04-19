package Plient::Handler::wget;
use strict;
use warnings;

use base 'Plient::Handler';
use Plient::Util 'which';

my ( $wget, %protocol, %all_protocol, %method );

sub all_protocol { return \%all_protocol }

@all_protocol{qw/http https ftp/} = ();

sub protocol { return \%protocol }
sub method { return \%method }

my $inited;
sub init {
    return if $inited;
    $inited = 1;

    $wget = $ENV{PLIENT_WGET} || which('wget');
    return unless $wget;

    @protocol{qw/http https ftp/}     = ();

    {
        local $ENV{LC_ALL} = 'en_US';
        my $message = `$wget https:// 2>&1`;
        if ( $message && $message =~ /HTTPS support not compiled in/i ) {
            delete $protocol{https};
        }
    }
    
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

