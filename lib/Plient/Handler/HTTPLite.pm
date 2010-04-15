package Plient::Handler::HTTPLite;
use strict;
use warnings;

my ( $HTTPLite, %protocol, %method );
sub method { $method{ $_[-1] } } # in case people call with ->

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

