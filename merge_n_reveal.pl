#!/usr/bin/perl 

use strict;
use warnings;
use English qw(-no_match_vars);

use Getopt::Long;
use JSON;
use Data::Dumper;
use File::Basename;
use File::Spec;
use File::Copy::Recursive qw(dircopy);

main();

sub main
{
    my $topics_file_name;
    my $reveal_repo_dir;
    my $getopt_success = GetOptions("topicsfile=s" => \$topics_file_name, 
                                    "revealdir=s" => \$reveal_repo_dir);
    unless ($getopt_success && defined($topics_file_name) && defined($reveal_repo_dir)) {
        die("Usage: $0 --topicsfile <file.json> --revealdir <path_to_reveal.js_repo>\n");
    }

    # splits into drive, directory path, filename
    my (undef, $content_dir, undef) = File::Spec->splitpath($topics_file_name);

    open(my $topics_file, '<', $topics_file_name) or die "Unable to open $topics_file_name: $OS_ERROR";

    my $json_text;
    { local $RS = undef; $json_text = (<$topics_file>);}
    my $in = decode_json($json_text);

    my @file_list;
    if (exists($in->{files})) {
        my $files = $in->{files};
        foreach my $elem (@$files) {
            if (ref($elem) eq "HASH") {
                while (my ($key, $val) = each(%$elem)) {
                    push @file_list, map { $key . '/' . $_ } @$val;
                }
            }
            elsif (! ref($elem)) {
                push @file_list, $elem;
            }
            else {
                die 'Blaargh!! Something is wrong with the JSON in files - found a ' . ref($elem); 
            }
        }
    }

    print "DEBUG @file_list";
    close($topics_file);

    my $present_dir = File::Spec->join($content_dir, "present");
    dircopy($reveal_repo_dir, $present_dir);
    #TODO exclude or remove .git directory
    open(my $reveal_index, '<', File::Spec->join($reveal_repo_dir, 'index.html'));
    open(my $presentation, '>', File::Spec->join($present_dir, 'index.html'));

    my $line;
    while (($line = <$reveal_index>) !~ m/<div class="slides">/) { #FIXME regex parsing on HTML
        print $presentation $line;
    }
    print $presentation $line; #print the class="slides" line also to the file
    chdir($content_dir);

    close($reveal_index);
}


