#!/usr/bin/perl

use strict;
use warnings;
use English qw(-no_match_vars);

use Getopt::Long qw(GetOptionsFromArray);
use File::Basename;
use File::Spec;

use FindBin qw($RealBin);
use lib "$RealBin/../lib/";
use RevealMerger;

sub main
{
    my ($topicsfile_name, $reveal_repo_dir) = parse_args(\@ARGV);

    unless (defined($topicsfile_name)) {
        die("Usage: $0 --topicsfile <file.json> --revealdir <path_to_reveal.js_repo>\n");
    }

    $topicsfile_name = File::Spec->rel2abs($topicsfile_name);
    die "Topics file $topicsfile_name doesn't seem to exist" unless (-f $topicsfile_name);
    $reveal_repo_dir = File::Spec->rel2abs($reveal_repo_dir);
    die "Reveal repo dir $reveal_repo_dir doesn't seem to exist" unless (-d $reveal_repo_dir);

    create_presentation($topicsfile_name, $reveal_repo_dir);
}

sub parse_args
{
    my $ARGV_REF = shift;
    my $topicsfile_name;
    my $reveal_repo_dir;
    my $getopt_success = GetOptionsFromArray($ARGV_REF,
        "topicsfile=s" => \$topicsfile_name,
        "revealdir=s" => \$reveal_repo_dir);

    unless ($getopt_success && defined($topicsfile_name) && defined($reveal_repo_dir)) {
        return undef;
    }

    return ($topicsfile_name, $reveal_repo_dir);
}

unless (defined caller) {
    main();
}

1;
