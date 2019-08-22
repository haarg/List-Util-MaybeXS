use strict;
use warnings;
use Test::More;

use Config ();

BEGIN {
  my $IMPL = 'List::Util::PP';
  my $sub = 'uniqnum';
  if (@ARGV) {
    my $impl = $ARGV[0];
    if ($impl =~ /\A(?:List::Util|(?:List::Util::)?XS)\z/i) {
      $IMPL = 'List::Util';
    }
    elsif ($impl =~ /\A(?:List::Util::)?PP\z/i) {
      $IMPL = 'List::Util::PP';
    }
    elsif ($impl =~ /\A(\w+(?:::\w+)*)::(uniq(?:num)?)\z/) {
      ($IMPL, $sub) = ($1, $2);
    }
    else {
      die "Invalid implementation '$impl'!\n";
    }
  }
  (my $f = "$IMPL.pm") =~ s{::}{/}g;
  require $f;
  *uniqnum = \&{"${IMPL}::${sub}"};
  print "# Testing ${IMPL}::${sub}\n";
}

use constant INF => 9**9**9**9;
use constant NAN => 0*9**9**9**9;
use constant INF_NAN_SUPPORT => (
  INF == 10 * INF
  and !(NAN == 0 || NAN == 0.1 || NAN + 0 == 0)
);

my $nvmantbits = $Config::Config{nvmantbits} || do {
  my $nvsize = $Config::Config{nvsize} * 8;
    $nvsize == 16  ? 11
  : $nvsize == 32  ? 24
  : $nvsize == 64  ? 53
  : $nvsize == 80  ? 64
  : $nvsize == 128 ? 113
  : $nvsize == 256 ? 237
                   : 237 # i dunno
};
my $precision = 2 + int( log(2)/log(10)*$nvmantbits );

my $maxuint = ~0;
my $maxint = ~0 >> 1;
my $minint = -(~0 >> 1) - 1;

my @numbers = (
  -20 .. 20,
  -0.0,
  qw(00 01 .0 .1 0.0 0.00 00.00 0.10 0.101),
  '0 but true',
  '0e0',
  (map +("1e$_", "-1e$_"), -50, -5, 0, 1, 5, 50),
  (map 1 / $_, -10 .. -2, 2 .. 10),
  (map +(1 / 9) * $_, -9 .. -1, 1 .. 9),
  (map $_ x 100, 1 .. 9),
  3.14159265358979323846264338327950288419716939937510,
  2.71828182845904523536028747135266249775724709369995,
  $maxuint,
  $maxuint-1,
  $maxint,
  $maxint+1,
  $minint,
  (INF_NAN_SUPPORT ? ( INF, -(INF), NAN, -(NAN) ) : ()),
);

my @more_numbers = map +(
  0+sprintf('%.'.($precision-3).'g', $_),
  0+sprintf('%.'.($precision-2).'g', $_),
  0+sprintf('%.'.($precision-1).'g', $_),
  0+sprintf('%.'.($precision  ).'g', $_),
  0+sprintf('%.'.($precision+1).'g', $_),
), @numbers;

sub accurate_uniqnum {
  local $@;
  my @uniq;
  IN: for my $in (@_) {
    for my $uniq (@uniq) {
      # this can't do a simple == comparison, due to conflicts between
      # floating point and unsigned int comparisons.  In particular:
      # maxuint     == maxuint converted to float
      # maxunit-1   == maxuint converted to float
      # maxunit     != maxuint-1
      #
      # It isn't possible to combine these into any concept of uniqueness that
      # doesn't depend either heavily on order, or could result in less
      # outputs by adding additional inputs.
      #
      # To work around this, we isolate the different numeric formats using
      # pack with perl's internal native formats (j for IV, J for UV, F for
      # NV).  Values are considered equal if all parts are equal.  The values
      # will truncate in the same way if they don't fit in the requested size.
      #
      # evals are needed to handle Inf and NaN, since they may die in
      # int/uint conversions.

      my ($uj) = eval { unpack 'j', pack 'j', $uniq };
      my ($uJ) = eval { unpack 'J', pack 'J', $uniq };
      my ($uF) =        unpack 'F', pack 'F', $uniq;
      my ($ij) = eval { unpack 'j', pack 'j', $in };
      my ($iJ) = eval { unpack 'J', pack 'J', $in };
      my ($iF) =        unpack 'F', pack 'F', $in;

      # Inf/NaN
      if ($uniq != $uniq || $in != $in || !defined $uj || !defined $ij) {
        # some platforms may stringify NaN and -NaN differently, and others
        # will not, even if the internal representation is different.  We just
        # use the stringification for the identity, rather than trying to peek
        # further into if the NaN is negative or has a payload.
        if ($uF eq $iF) {
          next IN;
        }
      }
      elsif ($uj == $ij && $uJ == $iJ && $uF == $iF) {
        next IN;
      }
    }
    push @uniq, $in;
  }
  return @uniq;
}

my @uniq = accurate_uniqnum(@numbers, @more_numbers, @numbers, @more_numbers);
my @ppuniq = uniqnum(@numbers, @more_numbers, @numbers, @more_numbers);

is 0+@ppuniq, 0+@uniq,
  'correct count of unique numbers';

for my $i ( 0 .. $#uniq ) {
  my ($got, $want) = ($ppuniq[$i], $uniq[$i]);
  if (!defined $got) {
    fail "Found correct $want in uniqnum output"
      or diag "Wanted : $want\nGot    : [undef]";
  }
  elsif ($want != $want) {
    ok $got != $got,
      "Found correct $want in uniqnum output"
      or diag "Got: $got";
  }
  else {
    cmp_ok $want, '==', $got,
      "Found correct $want in uniqnum output";
  }
}
for my $i ( @uniq .. $#ppuniq ) {
  is $ppuniq[$i], undef,
    "Found no extra elements in uniqnum output";
}

done_testing;
