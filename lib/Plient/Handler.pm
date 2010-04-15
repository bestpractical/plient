package Plient::Handler;
use strict;
use warnings;

sub protocol { warn "you should subclass protocol"; return }
sub method {  warn "you should subclass method"; return }
sub init { };

# XXX TODO add protocol version support?
sub may_support_protocol {
    my $class    = shift;
    my $protocol = shift;
    exists $class->all_protocol->{$protocol};
}

# you must call this when you init the handle, or nothing will return
sub support_protocol {
    my $class    = shift;
    my $protocol = shift;
    exists $class->protocol->{$protocol};
}

sub support_method {
    my $class = shift;
    my $method = shift;
    $class->method->{ $method };
}


1;

__END__

=head1 NAME

Plient::Handler - 


=head1 SYNOPSIS

    use Plient::Handler;

=head1 DESCRIPTION


=head1 INTERFACE

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2010 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

