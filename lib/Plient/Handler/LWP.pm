package Plient::Handler::LWP;
use strict;
use warnings;

use base 'Plient::Handler';
my ( $LWP, %all_protocol, %protocol, %method );

%all_protocol = map { $_ => undef }
  qw/http https ftp news gopher file mailto cpan data ldap nntp/;
sub all_protocol { return \%all_protocol }
sub protocol { return \%protocol }
sub method { return \%method }

my $inited;
sub init {
    return if $inited;
    $inited = 1;
    eval { require LWP::UserAgent } or return;
    
    undef $protocol{http};

    if ( eval { require Crypt::SSLeay } ) {
        undef $protocol{https};
    }

    $method{http_get} = sub {
        my ( $uri, $args ) = @_;

        # XXX TODO tweak the new arguments
        my $ua  = LWP::UserAgent->new;
        my $res = $ua->get($uri);
        if ( $res->is_success ) {
            return $res->decoded_content;
        }
        else {
            warn "failed to get $uri with lwp: " . $res->status_line;
            return;
        }
    };

    $method{http_post} = sub {
        my ( $uri, $args ) = @_;

        # XXX TODO tweak the new arguments
        my $ua  = LWP::UserAgent->new;
        my $res =
          $ua->post( $uri,
            $args->{body} ? ( content => $args->{body} ) : () );
        if ( $res->is_success ) {
            return $res->decoded_content;
        }
        else {
            warn "failed to get $uri with lwp: " . $res->status_line;
            return;
        }
    };

    if ( exists $protocol{https} ) {
        # have you seen https is available while http is not?
        $method{https_get} = $method{http_get};
        $method{https_post} = $method{http_post};
    }
    return 1;
}

1;

__END__

=head1 NAME

Plient::Handler::LWP - 


=head1 SYNOPSIS

    use Plient::Handler::LWP;

=head1 DESCRIPTION


=head1 INTERFACE

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2010 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

