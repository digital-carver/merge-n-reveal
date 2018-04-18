#!/usr/bin/perl

use strict;
use warnings;
use English qw(-no_match_vars);

use Getopt::Long qw(GetOptionsFromArray);
use File::Basename;
use File::Spec;

use FindBin qw($Bin);
use lib "$Bin/../lib/";
use RevealMerger qw(find_content_dir read_topicsfile);

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

    my $content_dir = RevealMerger::find_content_dir($topicsfile_name);
    my ($title, $config_json, @slide_files) = RevealMerger::read_topicsfile($topicsfile_name);
    print_slides_list(@slide_files);

    my $present_dir = RevealMerger::create_present_dir($reveal_repo_dir, $content_dir);
    open(my $reveal_index, '<', File::Spec->join($reveal_repo_dir, 'index.html')) or die "Couldn't open repo index.html: $OS_ERROR";
    open(my $presentation, '>', File::Spec->join($present_dir, 'index.html')) or die "Couldn't open present/index.html: $OS_ERROR";

    my $line;
    while (($line = <$reveal_index>) !~ m/<div class="slides">/) { #FIXME regex parsing on HTML
        $line =~ s|<title>\K(.*?)(?=</title>)|$title| if defined($title); #XXX hack upon a hack!
        print $presentation $line;
    }
    print $presentation $line; #print the class="slides" line also to the file

    chdir($content_dir); #JSON lists filepaths relative to itself, so cd there
    for my $slide_filename (@slide_files) {
        #$slide_filename .= '.html';
        open(my $slide_file, '<', $slide_filename) or die "Couldn't open $slide_filename: $OS_ERROR";
        my $slide_content;
        { local $RS = undef; $slide_content = (<$slide_file>);}
        print $presentation $slide_content;
        close($slide_file);
    }

    while (defined($line = <$reveal_index>) && ($line !~ m|<script src="lib/js/head\.min\.js"></script>|)) {
        ; #skip all the lines till the div.slides gets closed
        #XXX HACK: will break if the line after the div closure changes
    }
    print $presentation "</div>\n</div>\n";
    print $presentation $line; #print the head.min.js line
    while (defined($line = <$reveal_index>)) {
        if ($line =~ m|</body>| && defined($config_json)) { #the amount of XXX hacks is too damn high!
            print $presentation <<CONFIG_SCRIPT
<script>
Reveal.configure($config_json);
</script>

CONFIG_SCRIPT
        }
        print $presentation $line;
    }

    close($presentation);
    close($reveal_index);
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

sub print_slides_list
{
    print "These slide files will be included:\n";
    local $LIST_SEPARATOR = "\n";
    print "@_\n";
}

unless (defined caller) {
    main();
}

1;
