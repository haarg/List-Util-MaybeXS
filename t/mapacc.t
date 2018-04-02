use strict;
use warnings;

use List::Util::PP qw(mapacc);
use Test::More;
plan tests => 3;

my @v = mapacc { $a + $b } (0..5);

is_deeply \@v, [ 1, 3, 6, 10, 15 ], '$a+$b';

@v = mapacc { 1 + $b } (0..5);

is_deeply \@v, [ 2..6 ], '1+$b';

sub concat { $a . $b }

@v = mapacc \&concat, '', qw/ a b c /;
is_deeply \@v, [qw/ a ab abc /], '$a.$b';

done_testing;
