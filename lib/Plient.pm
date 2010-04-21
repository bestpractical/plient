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

    my $sub = dispatch( $method, $uri, $args );
    if ( $sub ) {
        $sub->();
    }
    else {
        warn "failed to $method on $uri"; 
        return;
    }
}

sub _extract_protocol {
    shift if $_[0] && $_[0] eq __PACKAGE__;
    my $uri = shift;
    return unless $uri;
    if ( $uri =~ /^http:/i ) {
        return 'http';
    }
    elsif ( $uri =~ /^https:/i ) {
        return 'https';
    }
    elsif ( $uri =~ /^file:/i ) {
        return 'file';
    }
    else {
        warn "unsupported $uri";
        return;
    }
}

sub _dispatch_protocol {
    shift if $_[0] && $_[0] eq __PACKAGE__;
    my $protocol = shift;
    return unless $protocol;
    if ( $protocol eq 'file' ) {
        require Plient::Protocol::File;
        return 'Plient::Protocol::File';
    }
    elsif ( $protocol eq 'http' ) {
        require Plient::Protocol::HTTP;
        return 'Plient::Protocol::HTTP';
    }
    elsif ( $protocol eq 'https' ) {
        require Plient::Protocol::HTTPS;
        return 'Plient::Protocol::HTTPS';
    }
    else {
        warn "unsupported protocol";
        return;
    }
}


sub dispatch {
    my ( $method, $uri, $args ) = @_;
    $method = lc $method;
    $method ||= 'get';    # people use get most of the time.
    my $class = _dispatch_protocol( _extract_protocol($uri) );
    return unless $class;

    if ( my $sub = $class->support_method( $method, $args ) ) {
        return sub { $sub->( $uri, $args ) };
    }
    else {
        warn "unsupported $method";
        return;
    }
}

my @all_handlers;
sub all_handlers {
    return @all_handlers if @all_handlers;
    @all_handlers = find_handlers();
}

sub handlers {
    shift if $_[0] && $_[0] eq __PACKAGE__;
    if ( my $protocol = lc shift ) {
        my %map =
          map { $_ => 1 }
          grep { $_->may_support_protocol($protocol) } all_handlers();
        my @handlers;
        my $preference = handler_preference($protocol);
        if ($preference) {
            @handlers =
              map { /^Plient::Handler::/ ? $_ : "Plient::Handler::$_" }
              grep {
                $_ =~ /::/
                  ? delete $map{$_}
                  : delete $map{"Plient::Handler::$_"}
              } @$preference;
        }
        push @handlers, keys %map unless $ENV{PLIENT_HANDLER_PREFERENCE_ONLY};
        return @handlers;
    }
    else {
        # fallback to return all the handlers
        return @all_handlers;
    }
}

sub find_handlers {
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

    @hd;
}

my %handler_preference = (
    http  => [qw/curl wget HTTPLite LWP/],
    https => [qw/curl wget LWP/],
);
if ( my $env = $ENV{PLIENT_HANDLER_PREFERENCE} ) {
    my %entry = map { split /:/, $_, 2 } split /;/, $env;
    %entry = map { $_ => [ split /,/, $entry{$_} || '' ] } keys %entry;
    for my $p ( keys %entry ) {
        $handler_preference{$p} = $entry{$p};
    }
}

sub handler_preference {
    shift if $_[0] && $_[0] eq __PACKAGE__;
    my ( $protocol, $handlers ) = @_;
    $protocol = lc $protocol;
    if ($handlers) {
        if ( ref $handlers eq 'ARRAY' ) {
            return $handler_preference{ $protocol } = $handlers;
        }
        else {
            warn "handlers shold be an arrayref";
            return;
        }
    }
    else {
        return $handler_preference{ $protocol };
    }
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

