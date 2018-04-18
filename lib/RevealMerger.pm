package RevealMerger;

use strict;
use warnings;
use English;
use open qw(:utf8);

use JSON;
use File::Spec;
use File::Copy::Recursive qw(dircopy);
use HTML::TreeBuilder 5 -weak;

use Exporter qw(import);
our @EXPORT = qw(create_presentation);
our @EXPORT_OK = qw(read_topicsfile); 

sub create_presentation
{
    my ($topicsfile_name, $reveal_repo_dir) = @_;

    my $content_dir = find_content_dir($topicsfile_name);
    my ($title_text, $config_json, @slide_files) = read_topicsfile($topicsfile_name);
    print_slides_list(@slide_files);

    my $present_dir = create_present_dir($reveal_repo_dir, $content_dir);
    open(my $reveal_index, '<', File::Spec->join($reveal_repo_dir, 'index.html'))
        or die "Couldn't open repo index.html: $OS_ERROR";
    my $reveal_html = _get_pristine_htmltree($reveal_index);    

    open(my $presentation, '>', File::Spec->join($present_dir, 'index.html'))
        or die "Couldn't open present/index.html: $OS_ERROR";

    my $head = $reveal_html->find_by_tag_name('head');
    my $title_el = $head->find_by_tag_name('title');
    $title_el->splice_content(0, scalar($title_el->content_list), $title_text);

    my $slides_div = $reveal_html->look_down(_tag => 'div', class => 'slides');
    $slides_div->delete_content();
    chdir($content_dir); #JSON lists filepaths relative to itself, so cd there
    for my $slide_filename (@slide_files) {
        #$slide_filename .= '.html';
        open(my $slide_file, '<', $slide_filename) or die "Couldn't open $slide_filename: $OS_ERROR";

        my $slide_html = _get_pristine_htmltree($slide_file, 1);
        $slides_div->push_content($slide_html); 
        #remove unnecessary <html> tag around every slide's content, auto-inserted by TreeBuilder
        $slide_html->replace_with_content();

        close($slide_file);
    }

    if (defined($config_json)) {
        my $cfg_script_el = _create_cfg_script_el($config_json);
        my $body = $reveal_html->find_by_tag_name('body');
        $body->push_content($cfg_script_el);
    }

    print $presentation $reveal_html->as_HTML();
    close($presentation);
    close($reveal_index);
}

sub _get_pristine_htmltree
{
    my $htmlfile = shift;
    my $partial_content = shift;

    my $htmltree = HTML::TreeBuilder->new();
    $htmltree->implicit_tags(0) if $partial_content;
    $htmltree->no_space_compacting(1);
    $htmltree->store_comments(1);
    $htmltree->ignore_ignorable_whitespace(0);
    $htmltree->ignore_unknown(0); #<section> is unknown to TreeBuilder
    $htmltree->warn(1);
    $htmltree->parse_file($htmlfile);
    return $htmltree;
}

sub _create_cfg_script_el
{
    my $config_json = shift;
    my $cfg_script_el = HTML::Element->new('script'); 
    $cfg_script_el->push_content("\nReveal.configure($config_json);\n");
    return $cfg_script_el;
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

