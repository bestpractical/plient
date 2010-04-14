package Plient::Handler::curl;
use strict;
use warnings;

use File::Which 'which';

my ( $curl, $curl_config, %protocol, %method );
sub method { $method{ $_[-1] } } # in case people call with ->

sub init {
    $curl        = $ENV{PLIENT_CURL}        || which('curl');
    $curl_config = $ENV{PLIENT_CURL_CONFIG} || which('curl-config');
    return unless $curl && $curl_config;
    if ( my $out = `$curl_config --protocols` ) {
        @protocol{ split /\r?\n/, $out } = ();
    }
    else {
        warn $!;
        return;
    }

    if ( exists $protocol{HTTP} ) {
        $method{http_get} = sub {
            my ( $uri, $args ) = @_;
            if ( open my $fh, "$curl -s -L $uri |" ) {
                local $/;
                <$fh>;
            }
            else {
                warn "failed to get $uri with curl: $!";
                return;
            }
        };
    }

    if ( exists $protocol{HTTPS} ) {
        # have you seen https is available while http is not?
        $method{https_get} = $method{http_get};
    }
}

init();

1;

__END__

=head1 NAME

Plient::Handler::curl - 


=head1 SYNOPSIS

    use Plient::Handler::curl;

=head1 DESCRIPTION


=head1 INTERFACE

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2010 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

