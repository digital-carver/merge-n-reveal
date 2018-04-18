use strict;
use warnings;

use Test::More;
use JSON;

BEGIN {
    use FindBin qw($RealBin);
    use lib "$RealBin/../lib/";

    use_ok('RevealMerger');
}

my $result;

$result = eval { RevealMerger::create_presentation(); 1; };
is($result, undef, 'should die for an no arguments to create_presentation');

$result = eval { RevealMerger::create_presentation('tapioca'); 1; };
is($result, undef, 'should die for an no reveal repo arg to create_presentation');

$result = eval { RevealMerger::create_presentation(undef, 'revealedwisdom'); 1; };
is($result, undef, 'should die for an no topics file arg to create_presentation');

done_testing();
