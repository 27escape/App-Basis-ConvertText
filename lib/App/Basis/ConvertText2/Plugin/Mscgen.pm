=head1 NAME

App::Basis::ConvertText2::Plugin::Mscgen

=head1 SYNOPSIS



=head1 DESCRIPTION

convert a mscgen text string into a PNG, requires mscgen program

=cut

# ----------------------------------------------------------------------------

package App::Basis::ConvertText2::Plugin::Mscgen;

use 5.10.0;
use strict;
use warnings;
use Image::Resize;
use Moo;
use Path::Tiny;
use App::Basis;
use App::Basis::ConvertText2::Support;
use namespace::autoclean;

has handles => (
    is       => 'ro',
    init_arg => undef,
    default  => sub { [qw{mscgen}]}
);

use constant MSCGEN => 'mscgen';

# ----------------------------------------------------------------------------

=item mscgen

create a simple msc image

 parameters
    data   - msc text      
    filename - filename to save the created image as 

 hashref params of
        size    - size of image, widthxheight - optional

=cut
sub process {
    my $self = shift;
    my ( $tag, $content, $params, $cachedir ) = @_;
    $params->{size} ||= "";
    my ( $x, $y ) = ( $params->{size} =~ /^\s*(\d+)\s*x\s*(\d+)\s*$/ );
    $params->{title} ||= "";

    # strip any ending linefeed
    chomp $content ;
    return "" if( !$content) ;

    # we can use the cache or process everything ourselves
    my $sig = create_sig( $content, $params );
    my $filename = cachefile( $cachedir, "$sig.png" );
    if ( !-f $filename ) {
        my $mscfile = Path::Tiny->tempfile("mscgen.XXXX");
        path( $mscfile)->spew_utf8( $content );
        my $cmd = MSCGEN . " -Tpng -o$filename $mscfile";
        my ( $exit, $stdout, $stderr ) = run_cmd($cmd);
        warn "Could not run script " . MSCGEN if( $exit) ;
        # if we want to force the size of the graph
        if ( -f $filename && $x && $y ) {
            my $image = Image::Resize->new($filename);
            my $gd = $image->resize( $x, $y );

            # overwrite original file with resized version
            if ($gd) {
                path($filename)->spew_raw( $gd->png );
            }
        }
    }

    my $out;
    if ( -f $filename) {

        # create something suitable for the HTML
        $out = create_img_src( $filename, $params->{title} );
    }
    return $out;

}

# ----------------------------------------------------------------------------

1;
