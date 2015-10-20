use strict;
use warnings;

use Test::More;
use JSON;

BEGIN {
    use_ok('RevealMerger');
}

my $result = eval { RevealMerger::read_topicsfile(''); 1; };
is($result, undef, 'should die for an empty topics filename');

my ($title, $config, @slide_files) = RevealMerger::read_topicsfile('./t/test_inputs/empty.json');
is($title, undef, 'undef title from reading empty.json');
is($config, undef, 'undef config from reading empty.json');
is(scalar(@slide_files), 0, 'empty slide_files from reading empty.json');

($title, $config, @slide_files) = RevealMerger::read_topicsfile('./t/test_inputs/simple.json');
is($title, undef, 'undef title from reading simple.json');
is($config, undef, 'undef config from reading simple.json');
is_deeply(\@slide_files, ['./slides/simple_file.html'], '@slide_files content on reading simple.json');

($title, $config, @slide_files) = RevealMerger::read_topicsfile('./t/test_inputs/complex.json');
is($title, "Complex Topic Spec", 'title from reading complex.json');
is_deeply(from_json($config), {testval => 99, teststr => 'str'}, 'config from reading complex.json');
is_deeply(\@slide_files, ['./slides/simple_file.html', '../../somewhere/else/file.html'], '@slide_files content on reading complex.json');

isnt(length($ENV{REVEAL_REPO_DIR}), undef, 'REVEAL_REPO_DIR env var is defined');
my $content_dir = "$ENV{PWD}/t/test_inputs/";
RevealMerger::create_present_dir($ENV{REVEAL_REPO_DIR}, $content_dir);
is(-d "$content_dir/present", 1, 'present directory is present');
is(-d "$content_dir/present/.git", undef, 'present/.git is not present');

done_testing();
