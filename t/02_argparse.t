use strict;
use warnings;

use Test::More;

require_ok('merge_n_reveal.pl');

my @test_argv = qw();
ok(!defined(parse_args(\@test_argv)), 'undef from parse_args on empty ARGV');

@test_argv = qw(--topicsfile tapioca --revealdir revealedwisdom);
my ($t, $r) = parse_args(\@test_argv);
is($t, 'tapioca', 'topicsfile from parse_args with "tapioca"');
is($r, 'revealedwisdom', 'revealdir from parse_args with "revealedwisdom"');

@test_argv = qw(--topicsfile 0 --revealdir 0);
($t, $r) = parse_args(\@test_argv);
is($t, '0', 'topicsfile from parse_args with 0');
is($r, '0', 'revealdir from parse_args with 0');

@test_argv = qw(--topicsfile tapioca);
($t, $r) = parse_args(\@test_argv);
is($t, undef, 'topicsfile from parse_args given only topicsfile');
is($r, undef, 'revealdir from parse_args given only topicsfile');

@test_argv = qw(--revealdir revealedwisdom);
($t, $r) = parse_args(\@test_argv);
is($t, undef, 'parse_args given only revealdir');
is($r, undef, 'parse_args given only revealdir');

done_testing();

