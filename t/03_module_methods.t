use strict;
use warnings;

use Test::More;

BEGIN {
    use FindBin qw($RealBin);
    use lib "$RealBin/../lib/";

    use_ok('RevealMerger');
}
can_ok('RevealMerger', 'create_presentation');
can_ok('RevealMerger', 'read_topicsfile');
can_ok('RevealMerger', 'create_present_dir');

done_testing();
