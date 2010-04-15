package Plient;

use warnings;
use strict;
use Carp;
our $VERSION = '0.01';
use File::Spec::Functions;
use base 'Exporter';
our @EXPORT = 'plient';

sub plient {
    my ( $method, $uri, $args ) = @_;
    if ( $args && ref $args ne 'HASH' ) {
        warn 'invalid args: should be a hashref';
        return;
    }
    $args ||= {};
    return unless $uri;
    $uri =~ s/^\s+//;

    # XXX TODO move this $uri tweak thing to HTTP part
    # http://localhost:5000 => http://localhost:5000/
    $uri .= '/' if $uri =~ m{^https?://[^/]+$};

    my $sub = dispatch( $method, $uri );
    if ( $sub ) {
        $sub->( $args );
    }
    else {
        warn "failed to $method on $uri"; 
        return;
    }
}

my %dispatch_map = (
    'file://'  => 'Plient::Protocol::File',
    'http://'  => 'Plient::Protocol::HTTP',
    'https://' => 'Plient::Protocol::HTTPS',
);

sub dispatch {
    my ( $method, $uri ) = @_;
    $method = lc $method;
    $method ||= 'get';    # people use get most of the time.

    for my $prefix ( keys %dispatch_map ) {
        if ( $uri =~ m{^\Q$prefix} ) {
            my $class = $dispatch_map{$prefix};
            eval "require $class" or warn "failed to require $class" && return;
            if ( my $sub = $class->can($method) || $class->method($method) ) {
                return sub { $sub->( $uri, @_ ) };
            }
            else {
                warn "unsupported $method";
            }
        }
    }
}

my @handlers;
sub handlers {
    return @handlers if @handlers;
    load_handlers();
}

sub load_handlers {
    my @hd;
    for my $inc (@INC) {
        my $handler_dir = catdir( $inc, 'Plient', 'Handler' );
        if ( -e $handler_dir ) {
            if ( opendir my $dh, $handler_dir ) {
                push @hd,
                  map { /(\w+)\.pm/ ? "Plient::Handler::$1" : () } readdir $dh;
            }
            else {
                warn "can't read $handler_dir";
            }
        }
    }
    for my $hd (@hd) {
        eval "require $hd" or warn "failed to require $hd";
    }
    @handlers = @hd;
}

1;

__END__

=head1 NAME

Plient - 


=head1 SYNOPSIS

    use Plient;

=head1 DESCRIPTION


=head1 INTERFACE


=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2010 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

