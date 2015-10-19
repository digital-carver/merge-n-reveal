use strict;
use warnings;

use Test::More;

require_ok('merge_n_reveal.pl');

my @test_argv = qw();
ok(!defined(parse_args(\@test_argv)), 'undef on empty ARGV');

done_testing();

