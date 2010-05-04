package Plient::Handler::HTTPLite;
use strict;
use warnings;

require Plient::Handler unless $Plient::bundle_mode;
our @ISA = 'Plient::Handler';
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
        add_headers( $http, $args->{headers} ) if $args->{headers};
        $http->proxy( $ENV{http_proxy} ) if $ENV{http_proxy};
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
        $http->proxy( $ENV{http_proxy} ) if $ENV{http_proxy};
        add_headers( $http, $args->{headers} ) if $args->{headers};
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

sub add_headers {
    my ( $http, $headers ) = @_;
    for my $k ( keys %$headers ) {
        $http->add_req_header( $k, $headers->{$k} );
    }
}

__PACKAGE__->_add_to_plient if $Plient::bundle_mode;

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

