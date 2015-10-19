use strict;
use warnings;

use Test::More;

require_ok('merge_n_reveal.pl');

my @test_argv = qw();
ok(!defined(parse_args(\@test_argv)), 'undef on empty ARGV');

@test_argv = qw(--topicsfile tapioca --revealdir revealedwisdom);
my ($t, $r) = parse_args(\@test_argv);
is($t, 'tapioca', 'topicsfile argument parsing');
is($r, 'revealedwisdom', 'revealdir argument parsing');

done_testing();

