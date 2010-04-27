package Plient;

use warnings;
use strict;
use Carp;
our $VERSION = '0.01';
use File::Spec::Functions;
use base 'Exporter';
our @EXPORT = 'plient';
our $bundle_mode = $ENV{PLIENT_BUNDLE_MODE};

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
        require Plient::Protocol::File unless $bundle_mode;
        return 'Plient::Protocol::File';
    }
    elsif ( $protocol eq 'http' ) {
        require Plient::Protocol::HTTP unless $bundle_mode;
        return 'Plient::Protocol::HTTP';
    }
    elsif ( $protocol eq 'https' ) {
        require Plient::Protocol::HTTPS unless $bundle_mode;
        return 'Plient::Protocol::HTTPS';
    }
    else {
        warn "unsupported protocol";
        return;
    }
}


sub available {
    shift if $_[0] && $_[0] eq __PACKAGE__;
    my ( $protocol, $method, $args ) = @_;
    return unless $protocol;
    $method ||= 'get';
    my $class = _dispatch_protocol(lc $protocol);
    return unless $class;
    return $class->support_method( $method, $args );
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

my %all_handlers;
my $found_handlers;
sub all_handlers {
    return keys %all_handlers if $found_handlers;
    @all_handlers{keys %all_handlers, find_handlers()} = ();
    keys %all_handlers;
}

# to include handlers not in @INC.
sub _add_handlers {
    shift if $_[0] && $_[0] eq __PACKAGE__;
    for my $handler (@_) {
        next unless $handler;
        if ( $handler->can('support_protocol')
            && $handler->can('support_method') )
        {
            $all_handlers{$handler} = ();
        }
        else {
            warn "$handler doesn't look like a Plient handler";
        }
    }

    return keys %all_handlers;
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
        return keys %all_handlers;
    }
}

sub find_handlers {
    $found_handlers = 1;
    return if $bundle_mode;
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

    @hd = grep { eval "require $_" or warn "failed to require $_" and 0 } @hd;

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

Plient - the uniform client of http, https, etc. 


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

