package Plient::Handler::HTTPLite;
use strict;
use warnings;

use base 'Plient::Handler';
my ( $HTTPLite, %all_protocol, %protocol, %method );

%all_protocol = ( http => undef );
sub all_protocol { return \%all_protocol }
sub protocol { return \%protocol }
sub method { return \%method }

my $inited;
sub init {
    return if $inited;
    $inited = 1;
    eval { require HTTP::Lite } or return;
    undef $protocol{http};
    $method{http_get} = sub {
        my ( $uri, $args ) = @_;
        my $http  = HTTP::Lite->new;
        my $res = $http->request($uri) || '';
        if ( $res == 200 || $res == 301 || $res == 302 ) {

            # XXX TODO handle redirect
            return $http->body;
        }
        else {
            warn "failed to get $uri with HTTP::Lite: "  . $res;
            return;
        }
    };

    $method{http_post} = sub {
        my ( $uri, $args ) = @_;
        my $http  = HTTP::Lite->new;
        $http->prepare_post( $args->{body} ) if $args->{body};
        my $res = $http->request($uri) || '';
        if ( $res == 200 || $res == 301 || $res == 302 ) {

            # XXX TODO handle redirect
            return $http->body;
        }
        else {
            warn "failed to post $uri with HTTP::Lite: "  . $res;
            return;
        }
    };

    return 1;
}

1;

__END__

=head1 NAME

Plient::Handler::HTTPLite - 


=head1 SYNOPSIS

    use Plient::Handler::HTTPLite;

=head1 DESCRIPTION


=head1 INTERFACE

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2010 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

