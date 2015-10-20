package RevealMerger;

use strict;
use warnings;
use English;

use JSON;
use File::Spec;

sub create_presentation
{
}

sub find_content_dir
{
    my $topicsfile_name = shift;
    # splits into drive, directory path, filename
    my (undef, $content_dir, undef) = File::Spec->splitpath($topicsfile_name);
    return $content_dir;

}

sub read_topicsfile
{
    my $topicsfile_name = shift;
    die unless length($topicsfile_name);

    open(my $topicsfile, '<', $topicsfile_name) or die "Unable to open $topicsfile_name: $OS_ERROR";

    my $json_text;
    { local $RS = undef; $json_text = (<$topicsfile>);}

    return if (length($json_text) == 0);

    my $in = decode_json($json_text);

    my @slide_files;
    if (exists($in->{files})) {
        my $files = $in->{files};
        foreach my $elem (@$files) {
            if (ref($elem)) {
                die 'Blaargh!! Something is wrong with the JSON in "files" - found a ' . ref($elem);
            }
            my ($volume, $dir, $slide_file) = File::Spec->splitpath($elem);
            if ($volume || $dir) { #not just a filename, so just use given path
                push @slide_files, ($elem . '.html');
            }
            else { #just a filename, so assume it's under $PWD/slides/
                push @slide_files, ('./slides/' . $elem . '.html');
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

    print "List of slide files: @slide_files\n";
    close($topicsfile);

    return ($in->{title}, $config_json, @slide_files);
}

1;

