use strict;
use warnings;

use Test::More tests => 6;
use List::Util::PP qw( zip );

is_deeply( [ zip ],
           [],
           'zip of empty list' );

is_deeply( [ zip [ qw( q w e ) ] ],
           [ qw( q w e ) ],
           'zip one array' );

is_deeply( [ zip [ qw( q w e ) ], [ 7, 8, 9 ] ],
           [ q => 7, w => 8, e => 9 ],
           'zip two arrays' );

is_deeply( [ zip [ qw( q w e ) ], [ 7, 8, 9 ], [ 12, 13, 14 ] ],
           [ 'q', 7, 12, 'w', 8, 13, 'e', 9, 14 ],
           'zip three arrays' );

is_deeply( [ zip [ qw( q w e ) ], [ 7, 8 ] ],
           [ q => 7, w => 8, e => undef ],
           'zip of arrays of unequal length' );

is_deeply( [ zip [ qw( q w ) ], [ 7, 8, 9 ] ],
           [ q => 7, w => 8, undef, 9 ],
           'zip of arrays of unequal length' );
