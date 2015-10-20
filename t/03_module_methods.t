use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('RevealMerger');
}
can_ok('RevealMerger', 'create_presentation');
can_ok('RevealMerger', 'find_content_dir');
can_ok('RevealMerger', 'read_topics_file');

done_testing();
