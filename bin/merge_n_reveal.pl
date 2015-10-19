#!/usr/bin/perl 

use strict;
use warnings;
use English qw(-no_match_vars);

use Getopt::Long qw(GetOptionsFromArray);
use JSON;
use File::Basename;
use File::Spec;
use File::Copy::Recursive qw(dircopy);

sub main
{
    my ($topics_file_name, $reveal_repo_dir) = parse_args(\@ARGV);

    unless (defined($topics_file_name)) {
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
                    push @file_list, map { $key . '/' . $_ . '.html' } @$val;
                }
            }
            elsif (! ref($elem)) {
                push @file_list, ($elem . '.html');
            }
            else {
                die 'Blaargh!! Something is wrong with the JSON in files - found a ' . ref($elem); 
            }
        }
    }

    my $title = 'Presentation';
    if (exists($in->{title})) {
        $title = $in->{title};
    }

    my $config_json;
    if (exists($in->{config})) {
        $config_json = to_json($in->{config}, {utf8=>1, pretty=>1}); #convert back to JSON!
    }

    print "List of slide files: @file_list\n";
    close($topics_file);

    my $present_dir = File::Spec->join($content_dir, "present");
    dircopy($reveal_repo_dir, $present_dir);
    File::Copy::Recursive::pathrmdir($present_dir.'/.git/') or warn(".git folder couldn't be removed from present/ $!");
    open(my $reveal_index, '<', File::Spec->join($reveal_repo_dir, 'index.html')) or die "Couldn't open repo index.html: $OS_ERROR";
    open(my $presentation, '>', File::Spec->join($present_dir, 'index.html')) or die "Couldn't open present/index.html: $OS_ERROR";

    my $line;
    while (($line = <$reveal_index>) !~ m/<div class="slides">/) { #FIXME regex parsing on HTML
        $line =~ s|<title>\K(.*?)(?=</title>)|$title|; #XXX hack upon a hack!
        print $presentation $line;
    }
    print $presentation $line; #print the class="slides" line also to the file

    chdir($content_dir); #JSON lists filepaths relative to itself, so cd there
    for my $slide_filename (@file_list) {
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
        if ($line =~ m|</body>|) { #the amount of XXX hacks is too damn high!
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
    my $topics_file_name;
    my $reveal_repo_dir;
    my $getopt_success = GetOptionsFromArray($ARGV_REF,
                                            "topicsfile=s" => \$topics_file_name, 
                                            "revealdir=s" => \$reveal_repo_dir);
    unless ($getopt_success && defined($topics_file_name) && defined($reveal_repo_dir)) {
        return undef;
    }
    return ($topics_file_name, $reveal_repo_dir);
}

unless (defined caller) {
    main();
}

1;
