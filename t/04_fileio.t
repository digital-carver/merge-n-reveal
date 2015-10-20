use strict;
use warnings;

use Test::More;

BEGIN {
    use_ok('RevealMerger');
}

my $result = eval { RevealMerger::read_topics_file(''); 1; };
is($result, undef, 'should die for an empty topics filename');

my ($title, $config, @slide_files) = RevealMerger::read_topics_file('./t/test_inputs/empty.json');
is($title, undef, 'undef title from reading empty.json');
is($config, undef, 'undef config from reading empty.json');
is(scalar(@slide_files), 0, 'empty slide_files from reading empty.json');

($title, $config, @slide_files) = RevealMerger::read_topics_file('./t/test_inputs/simple.json');
is($title, undef, 'undef title from reading simple.json');
is($config, undef, 'undef config from reading simple.json');
is_deeply(\@slide_files, ['simple_file.html'], '@slide_files content on reading simple.json');

($title, $config, @slide_files) = RevealMerger::read_topics_file('./t/test_inputs/simple.json');
is($title, undef, 'undef title from reading simple.json');
is($config, undef, 'undef config from reading simple.json');
is_deeply(\@slide_files, ['simple_file.html'], '@slide_files content on reading simple.json');

done_testing();
