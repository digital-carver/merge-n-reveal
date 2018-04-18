package RevealMerger;

use strict;
use warnings;
use English;

use JSON;
use File::Spec;
use File::Copy::Recursive qw(dircopy);
use Exporter qw(import);
our @EXPORT = qw(create_presentation);
our @EXPORT_OK = qw(read_topicsfile); 

sub create_presentation
{
    my ($topicsfile_name, $reveal_repo_dir) = @_;

    my $content_dir = find_content_dir($topicsfile_name);
    my ($title, $config_json, @slide_files) = read_topicsfile($topicsfile_name);
    print_slides_list(@slide_files);

    my $present_dir = create_present_dir($reveal_repo_dir, $content_dir);
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
        ; #skip all the lines till the div.slides and div.reveal get closed
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

sub find_content_dir
{
    my $topicsfile_name = shift;

    # splits into drive, directory path, filename
    my ($drive, $dir_path, undef) = File::Spec->splitpath($topicsfile_name);
    return File::Spec->catpath($drive, $dir_path);
}

sub read_topicsfile
{
    my $topicsfile_name = shift;
    die unless defined($topicsfile_name) && length($topicsfile_name);

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
            else { #just a filename, so assume it's under $content_dir/slides/
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

    die "RevealJS repo directory undefined. Exiting..." unless $reveal_repo_dir;
    die "Output directory undefined. Exiting..." unless $content_dir;

    die "RevealJS repo directory $reveal_repo_dir doesn't seem to exist. Exiting..." unless -d $reveal_repo_dir;
    die "Output directory $content_dir is supposed to already exist. Exiting..." unless -d $content_dir;

    my $present_dir = File::Spec->join($content_dir, "present");
    dircopy($reveal_repo_dir, $present_dir);
    File::Copy::Recursive::pathrmdir($present_dir.'/.git/') or warn(".git folder couldn't be removed from present/ $!");
    return $present_dir;
}

sub print_slides_list
{
    print "These slide files will be included:\n";
    local $LIST_SEPARATOR = "\n";
    print "@_\n";
}

1;

