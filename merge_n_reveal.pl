#!/usr/bin/perl 

use strict;
use warnings;
use English qw(-no_match_vars);

use JSON;
use Data::Dumper;

main();

sub main
{
    unless (@ARGV) {
        die "Usage: $0 <topic_list.json>";
    }

    my $topics_file_name = shift @ARGV;
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

    print "@file_list";
}


