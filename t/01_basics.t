use strict;
use warnings;

use Test::More;

require_ok('merge_n_reveal.pl');

BEGIN {
    use_ok('RevealMerger');
}

done_testing();
