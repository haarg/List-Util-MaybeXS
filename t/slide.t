use strict;
use warnings;

use Test::More tests => 7;

use Config;
use List::Util::PP qw(slide);

eval { slide {} };
like $@, qr/slide requires two or more parameters/;

eval { slide {} 1 };
like $@, qr/slide requires two or more parameters/;

my @out = slide { $a + $b } 1 .. 5;

is 0+@out, 4;
is $out[0], 3;
is $out[1], 5;
is $out[2], 7;
is $out[3], 9;
