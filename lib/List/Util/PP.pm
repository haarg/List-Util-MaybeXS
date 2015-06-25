# List::Util::PP.pm
#
# Copyright (c) 1997-2009 Graham Barr <gbarr@pobox.com>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package List::Util::PP;

use strict;
use warnings;
use vars qw(@ISA @EXPORT $VERSION);
require Exporter;

@ISA     = qw(Exporter);
@EXPORT  = qw(first min max minstr maxstr reduce sum shuffle);
$VERSION = "1.23";
$VERSION = eval $VERSION;

sub reduce (&@) {
  my $code = shift;
  unless ( ref $code && eval { \&$code } ) {
    require Carp;
    Carp::croak("Not a subroutine reference");
  }
  no strict 'refs';

  return shift unless @_ > 1;

  my $caller = caller;
  local(*{$caller."::a"}) = \my $a;
  local(*{$caller."::b"}) = \my $b;

  $a = shift;
  foreach (@_) {
    $b = $_;
    $a = &{$code}();
  }

  $a;
}

sub first (&@) {
  my $f = shift;
  unless ( ref $f && eval { \&$f } ) {
    require Carp;
    Carp::croak("Not a subroutine reference");
  }

  $f->() and return $_
    foreach @_;

  undef;
}

sub sum (@) {
  return undef unless @_;
  my $s = 0;
  $s += $_ foreach @_;
  return $s;
}

sub min (@) {
  return undef unless @_;
  my $min = shift;
  $_ < $min and $min = $_
    foreach @_;
  return $min;
}

sub max (@) {
  return undef unless @_;
  my $max = shift;
  $_ > $max and $max = $_
    foreach @_;
  return $max;
}

sub minstr (@) {
  return undef unless @_;
  my $min = shift;
  $_ lt $min and $min = $_
    foreach @_;
  return $min;
}

sub maxstr (@) {
  return undef unless @_;
  my $max = shift;
  $_ gt $max and $max = $_
    foreach @_;
  return $max;
}

sub shuffle (@) {
  my @a=\(@_);
  my $n;
  my $i=@_;
  map {
    $n = rand($i--);
    (${$a[$n]}, $a[$n] = $a[$i])[0];
  } @_;
}

1;
