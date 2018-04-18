use strict;
use warnings;

use Test::More;
use FindBin qw($RealBin);
use lib "$RealBin/../bin/";
require_ok('merge_n_reveal.pl');

BEGIN {
    use FindBin qw($RealBin);
    use lib "$RealBin/../lib/";

    use_ok('RevealMerger');
}

done_testing();
