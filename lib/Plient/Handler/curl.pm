package Plient::Handler::curl;
use strict;
use warnings;

require Plient::Handler unless $Plient::bundle_mode;
our @ISA = 'Plient::Handler';

require Plient::Util unless $Plient::bundle_mode;
Plient::Util->import;

my ( $curl, $curl_config, %all_protocol, %protocol, %method );

%all_protocol =
  map { $_ => undef } qw/http https ftp ftps file telnet ldap dict tftp/;
sub all_protocol { return \%all_protocol }
sub protocol { return \%protocol }
sub method { return \%method }

my $inited;
sub init {
    return if $inited;
    $inited = 1;
    $curl        = $ENV{PLIENT_CURL}        || which('curl');
    $curl_config = $ENV{PLIENT_CURL_CONFIG} || which('curl-config');
    return unless $curl && $curl_config;
    if ( my $out = `$curl_config --protocols` ) {
        @protocol{ map { lc } split /\r?\n/, $out } = ();
    }
    else {
        warn $!;
        return;
    }

    if ( exists $protocol{http} ) {
        $method{http_get} = sub {
            my ( $uri, $args ) = @_;
            my $headers = translate_headers( $args->{headers} );
            my $auth    = translate_auth($args);
            if ( open my $fh, "$curl -k -s -L $headers $auth $uri |" ) {
                local $/;
                <$fh>;
            }
            else {
                warn "failed to get $uri with curl: $!";
                return;
            }
        };

        $method{http_post} = sub {
            my ( $uri, $args ) = @_;

            my $data = '';
            if ( $args->{body} ) {
                my %kv = %{$args->{body}};
                for my $k ( keys %kv ) {
                    if ( defined $kv{$k} ) {
                        if ( ref $kv{$k} && ref $kv{$k} eq 'ARRAY' ) {
                            for my $i ( @{ $kv{$k} } ) {
                                $data .= " -d '$k=$i'";
                            }
                        }
                        else {
                            $data .= " -d $k='$kv{$k}'";
                        }
                    }
                    else {
                        $data .= " -d '$k='";
                    }
                }
            }

            my $headers = translate_headers($args);
            my $auth    = translate_auth($args);

            if ( open my $fh, "$curl -s -L $data $headers $auth $uri |" ) {
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
            my $headers = translate_headers( $args->{headers} );
            my $auth    = translate_auth($args);
            if ( open my $fh, "$curl -s -I -L $headers $auth $uri |" ) {
                local $/;
                my $head = <$fh>;
                $head =~ s/\r\n$//;
                return $head;
            }
            else {
                warn "failed to get head of $uri with curl: $!";
                return;
            }
        };
    }

    if ( exists $protocol{https} ) {
        for my $m (qw/get post head put/) {
            $method{"https_$m"} = $method{"http_$m"}
              if exists $method{"http_$m"};
        }
    }
    return 1;
}

sub translate_headers {
    my $args = shift || {};
    my $headers = $args->{headers};
    return '' unless $headers;
    my $str;
    for my $k ( keys %$headers ) {
        $str .= " -H '$k:$headers->{$k}'";
    }
    return $str;

}

sub translate_auth {
    my $args = shift || {};
    my $auth = '';
    if ( $args->{user} && defined $args->{password} ) {
        my $method = lc $args->{auth_method} || 'basic';
        if ( $method eq 'basic' ) {
            $auth = " -u '$args->{user}:$args->{password}'";
        }
        else {
            die "aborting: unsupported auth method: $method";
        }
    }
    return $auth;
}

__PACKAGE__->_add_to_plient if $Plient::bundle_mode;
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

