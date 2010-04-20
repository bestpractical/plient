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

    @protocol{qw/http https ftp/} = ();

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

    $method{http_post} = sub {
        my ( $uri, $args ) = @_;
        $args ||= {};

        my $data = '';
        if ( $args->{body} ) {
            my %kv = %{ $args->{body} };
            for my $k ( keys %kv ) {
                if ( defined $kv{$k} ) {
                    if ( ref $kv{$k} && ref $kv{$k} eq 'ARRAY' ) {
                        for my $i ( @{ $kv{$k} } ) {
                            $data .= " --post-data $k=$i";
                        }
                    }
                    else {
                        $data .= " --post-data $k=$kv{$k}";
                    }
                }
                else {
                    $data .= " --post-data $k=";
                }
            }
        }

        if ( open my $fh, "$wget -q -O - $data $uri |" ) {
            local $/;
            <$fh>;
        }
        else {
            warn "failed to post $uri with curl: $!";
            return;
        }
    };

    $method{http_head} = sub {
        my ( $uri, $args ) = @_;
        # we can't use -q here, or some version may not show the header
        if ( open my $fh, "$wget -S --spider $uri 2>&1 |" ) {
            my $head = '';
            my $flag;
            while ( my $line = <$fh>) {
                # yeah, the head output has 2 spaces as indents
                if ( $line =~ m{^\s{2}HTTP} ) {
                    $flag = 1;
                }

                if ($flag) {
                    if ($line =~ s/^\s{2}(?=\S)//) {
                        $head .= $line;
                    }
                    else {
                        undef $flag;
                        last;
                    }
                }
            }
            return $head;
        }
        else {
            warn "failed to get head of $uri with wget: $!";
            return;
        }
    };

    if ( exists $protocol{https} ) {
        for my $m (qw/get post head put/) {
            $method{"https_$m"} = $method{"http_$m"}
              if exists $method{"http_$m"};
        }
    }

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

