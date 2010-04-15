package Plient::Util;

use warnings;
use strict;
use Carp;
use Config;

use File::Spec::Functions;
use base 'Exporter';
our @EXPORT = 'which';

use constant WIN32 => $^O eq 'MSWin32';
my $bin_quote = WIN32 ? q{"} : q{'};
my $bin_ext = $Config{_exe};
my %cache;
sub which {
    my $name = shift;
    return $cache{$name} if $cache{$name};

    my $path;
    eval '$path = `which $name`';
    chomp $path;
    if ( !$path ) {

        # fallback to our way
        for my $dir ( path() ) {
            my $path = catfile( $dir, $name );

            # XXX  any other names need to try?
            my @try = grep { -x } ( $path, $path .= $bin_ext );
            for my $try (@try) {
                return $path;
            }
        }
    }

    if ( $path =~ /\s/ && $path !~ /^$bin_quote/ ) {
        $path = $bin_quote . $path . $bin_quote;
    }

    if ($path) {
        return $cache{$path} = $path;
    }
    return;
}

1;

__END__

=head1 NAME

Plient::Util - 


=head1 SYNOPSIS

    use Plient::Util;

=head1 DESCRIPTION


=head1 INTERFACE


=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2010 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

