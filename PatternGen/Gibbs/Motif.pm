# TFBS module for TFBS::PatternGen::Gibbs::Motif
#
# Copyright Boris Lenhard and Wynand Alkema
# 
# You may distribute this module under the same terms as perl itself
#

# POD


# POD

=head1 NAME

TFBS::PatternGen::Gibbs::Motif - class for unprocessed motifs and associated 
numerical scores created by the Gibbs program


=head1 SYNOPSIS

=head1 DESCRIPTION

TFBS::PatternGen::Gibbs::Motif is used to store and manipulate unprocessed 
motifs and associated numerical scores created by the Gibbs program. You do not 
normally want to create a TFBS::PatternGen::Gibbs::Motif yourself. They are created
by running TFBS::PatternGen::Gibbs 

=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard and Wynand Alkema

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>
Wynand Alkema E<lt>Wynand.Alkema@cgb.ki.seE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut



# the code begins here:

package TFBS::PatternGen::Gibbs::Motif;
use vars qw(@ISA);
use strict;

use TFBS::Matrix::PFM;
use TFBS::PatternGen::Motif::Matrix;
@ISA = qw(TFBS::PatternGen::Motif::Matrix);



=head2 MAP

 Title   : MAP
 Usage   : my $map_score = $motif->MAP;
 Function: returns MAP score for the detected motif
	   (This is a backward compatibility method. For consistency,
	    you should use $motif->tag('MAP_score') instead
 Returns : float (a scalar)
 Args    : none

=head2 Other methods

TFBS::PatterGen::Motif::Gibbs inherits from TFBS::PatternGen::Motif,
which inherits from TFBS::Matrix. Please consult the documentation of those modules
for additional available methods.


=cut

sub MAP{
    my ($self) = @_;
    return $self->tag("MAP_score");
}



sub _calculate_PFM  {
    my $self = shift;
    unless ($self->{'nr_hits'}) {
	$self->throw(ref($self).
		     " objects must be created with a (nonzero)".
		     " -nr_hits parameter in constructor"
		     );
    }
    my @PFM;
    foreach my $rowref ( @{$self->{'matrix'}} )  {
	my @PFMrow;
	foreach my $element (@$rowref) {
	    push @PFMrow, int($self->{'nr_hits'}*$element/100 + 0.5);
	}
	push @PFM, [@PFMrow];
    }
    return \@PFM;
}

