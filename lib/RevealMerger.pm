package RevealMerger;

use strict;
use warnings;
use English;

use JSON;
use File::Spec;
use File::Copy::Recursive qw(dircopy);
use Exporter;
our @EXPORT = qw(create_presentation);
our @EXPORT_OK = qw(read_topicsfile find_content_dir); #FIXME find_content_dir shouldn't need to be exported

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

    my $json_text = read_file_as_string($topicsfile);
    return if (length($json_text) == 0);

    my $in = decode_json($json_text);

    my @slide_files = get_slide_files($in->{files});
    my $title = get_title($in->{title});
    my $config_json = get_config_json($in->{config});

    close($topicsfile);

    return ($in->{title}, $config_json, @slide_files);
}

sub read_file_as_string
{
    my $filehandle = shift;
    local $RS = undef;
    my $file_str = (<$filehandle>);
    return $file_str;
}

sub get_slide_files
{
    my $files_aref = shift;
    my @slide_files;
    if (ref($files_aref) eq 'ARRAY') {
        foreach my $elem (@$files_aref) {
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
    return @slide_files;
}

sub get_title
{
    my $in_title = shift;
    if (defined($in_title)) {
        return $in_title;
    }
    else {
        return 'Presentation';
    }
}

sub get_config_json
{
    my $in_config = shift;
    if (defined($in_config)) {
        return to_json($in_config, {utf8=>1, pretty=>1}); #convert back to JSON!
    }
    else {
        return;
    }
}

sub create_present_dir
{
    my ($reveal_repo_dir, $content_dir) = @_;
    my $present_dir = File::Spec->join($content_dir, "present");
    dircopy($reveal_repo_dir, $present_dir);
    File::Copy::Recursive::pathrmdir($present_dir.'/.git/') or warn(".git folder couldn't be removed from present/ $!");
    return $present_dir;
}

1;

