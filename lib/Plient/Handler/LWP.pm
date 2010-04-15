package Plient::Handler::LWP;
use strict;
use warnings;

my ( $LWP, %protocol, %method );
sub method { $method{ $_[-1] } } # in case people call with ->


sub init {
    eval { require LWP::UserAgent } or return;
    
    undef $protocol{HTTP};

    if ( eval { require Crypt::SSLeay } ) {
        undef $protocol{HTTPS};
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

    if ( exists $protocol{HTTPS} ) {
        # have you seen https is available while http is not?
        $method{https_get} = $method{http_get};
    }
    return 1;
}

init();

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

