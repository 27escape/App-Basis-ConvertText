
=head1 NAME

App::Basis::ConvertText2::Plugin::Badge

=head1 SYNOPSIS

Create badges/shields like http://shields.io/
use CSS to style all the badges

=head1 DESCRIPTION

Create a badge style image

~~~~{.badge subject='The Christmas Tree' status='' color=''}
~~~~

=cut

# ----------------------------------------------------------------------------

package App::Basis::ConvertText2::Plugin::Badge;

use 5.14.0;
use strict;
use warnings;
use Path::Tiny;
use Moo;
use App::Basis::ConvertText2::Support;
use feature 'state';
use namespace::autoclean;

has handles => (
    is       => 'ro',
    init_arg => undef,
    default  => sub { [qw{badge shield}] }
);

# -----------------------------------------------------------------------------

=item badge | shield

aka shield

Create abadge/shield to show status of something

 parameters

    hashref params of
        subject - whats the badge for
        status  - how well is it doing
        color   - what color is the status part, defaults to goldenrod
        size    - change the font-size from the CSS one to this


=cut

sub badge
{
    my $self = shift;
    my ( $tag, $content, $params, $cachedir ) = @_;

    my $out;
    $params->{color} //= 'goldenrod' ;
    my $subject_style = "" ;
    my $status_style = "background-color: $params->{color}; "  ;
    $params->{subject} //= 'Missing subject' ;
    $params->{status} //= 'Missing status' ;

    if( $params->{size}) {
        $params->{size} =~ s/%//g ;
        $status_style .= "font-size: $params->{size}%; " ;
        $subject_style .= "font-size: $params->{size}%; " ;
    }

    # create something suitable for the HTML, no spaces
    $out = "<span class='badge'>" .
        "<span class='subject' style='$subject_style'>&nbsp;&nbsp;" . $params->{subject} .
        "&nbsp;</span><span class='status' style='$status_style'>&nbsp;" . $params->{status} . "&nbsp;&nbsp;</span>
</span>";

    return $out;
}

# ----------------------------------------------------------------------------
# decide which simple handler should process this request

sub process
{
    my $self = shift;
    my ( $tag, $content, $params, $cachedir ) = @_;

    $tag = 'badge' if( $tag eq 'shield') ;
    if ( $self->can($tag) ) {
        return $self->$tag(@_);
    }
    return undef;
}
# ----------------------------------------------------------------------------

1;

__END__
