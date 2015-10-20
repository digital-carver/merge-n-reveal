package RevealMerger;

use strict;
use warnings;
use English;

use JSON;
use File::Spec;

use Data::Dump;

sub create_presentation
{
}

sub find_content_dir
{
    my $topics_file_name = shift;
    # splits into drive, directory path, filename
    my (undef, $content_dir, undef) = File::Spec->splitpath($topics_file_name);
    return $content_dir;

}

sub read_topics_file
{
    my $topics_file_name = shift;
    die unless length($topics_file_name);

    open(my $topics_file, '<', $topics_file_name) or die "Unable to open $topics_file_name: $OS_ERROR";

    my $json_text;
    { local $RS = undef; $json_text = (<$topics_file>);}

    return if (length($json_text) == 0);

    my $in = decode_json($json_text);

    my @file_list;
    if (exists($in->{files})) {
        my $files = $in->{files};
        foreach my $elem (@$files) {
            if (ref($elem)) {
                die 'Blaargh!! Something is wrong with the JSON in "files" - found a ' . ref($elem);
            }
            my ($volume, $dir, $slide_file) = File::Spec->splitpath($elem);
            if ($volume || $dir) { #not just a filename, so just use given path
                push @file_list, ($elem . '.html');
            }
            else { #just a filename, so assume it's under $PWD/slides/
                push @file_list, ('./slides/' . $elem . '.html');
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

    return ($in->{title}, $config_json, @file_list);
}

1;

