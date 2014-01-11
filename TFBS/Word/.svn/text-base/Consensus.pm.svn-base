# TFBS module for TFBS::Word::Consensus
#
# Copyright Boris Lenhard
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::Word - IUPAC DNA consensus word-based pattern class
=head1 DESCRIPTION

TFBS::Word is a base class consisting of universal constructor called by
its subclasses (TFBS::Matrix::*), and word pattern manipulation methods that
are independent of the word type. It is not meant to be instantiated itself.

=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut

package TFBS::Word::Consensus;

use vars '@ISA';

use TFBS::Word;
use TFBS::Matrix::PWM;

use strict;

@ISA = qw(TFBS::Word);


=head2 new

 Title   : new
 Usage   : my $pwm = TFBS::Matrix::PWM->new(%args)
 Function: constructor for the TFBS::Matrix::PWM object
 Returns : a new TFBS::Matrix::PWM object
 Args    : # you must specify the -word argument:
           -word,       # a strig consisting of letters in
                        # IUPAC degenerate DNA alphabet
                        # (any of ACGTSWKMPYBDHVN)

	   #######

           -name,        # string, OPTIONAL
           -ID,          # string, OPTIONAL
           -class,       # string, OPTIONAL
           -tags         # a hash reference reference, OPTIONAL

=cut

# "new" is inherited from TFBS::Word

=head2 search_seq

 Title   : search_seq
 Usage   : my $siteset = $pwm->search_seq(%args)
 Function: scans a nucleotide sequence with the pattern represented
	   by the PWM
 Returns : a TFBS::SiteSet object
 Args    : # you must specify either one of the following three:

	   -file,       # the name od a fasta file (single sequence)
	      #or
	   -seqobj      # a Bio::Seq object
		        # (more accurately, a Bio::PrimarySeqobject or a
		        #  subclass thereof)
	      #or
	   -seqstring # a string containing the sequence

	   -max_mismatches,  # number of allowed positions in the site that do
	                     # not match the consensus
			             # OPTIONAL: default 0

=cut


sub search_seq  {
    my ($self,  @args) = @_;
    my ($max_mismatch) = $self->_rearrange([qw(MAX_MISMATCHES)], @args) or 0;
    $max_mismatch = 0 unless defined $max_mismatch;
    my $pwm = $self->to_PWM;
    my $siteset = $pwm->search_seq(@args,
                                   -threshold => $self->length - $max_mismatch);
    $self->_replace_patterns_in_siteset($siteset);
    return $siteset;
}


=head2 search_aln

 Title   : search_aln
 Usage   : my $site_pair_set = $pwm->search_aln(%args)
 Function: Scans a pairwise alignment of nucleotide sequences
	   with the pattern represented by the word: it reports only
           those hits that are present in equivalent positions of both
	   sequences and exceed a specified threshold score in both, AND
	   are found in regions of the alignment above the specified
	   conservation cutoff value.
 Returns : a TFBS::SitePairSet object
 Args    : # you must specify either one of the following three:

	   -file,       # the name of the alignment file in Clustal
			       format
	      #or
	   -alignobj      # a Bio::SimpleAlign object
		        # (more accurately, a Bio::PrimarySeqobject or a
		        #  subclass thereof)
	      #or
	   -alignstring # a multi-line string containing the alignment
			# in clustal format
	   #############

	   -max_mismatches,  # number of allowed positions in the site that do
	                      # not match the consensus
			              # OPTIONAL: default 0

	   -window,     # size of the sliding window (inn nucleotides)
			# for calculating local conservation in the
			# alignment
			# OPTIONAL: default 50

	   -cutoff      # conservation cutoff (%) for including the
			# region in the results of the pattern search
			# OPTIONAL: default "70%"

=cut




sub search_aln  {
    my ($self,  @args) = @_;
    my ($max_mismatch) = $self->_rearrange([qw(MAX_MISMATCHES)], @args) or 0;
    $max_mismatch = 0 unless defined $max_mismatch;
    my $pwm = $self->to_PWM;
    my $sitepairset = $pwm->search_aln(@args,
                                       -threshold => $self->length - $max_mismatch);
    $self->_replace_patterns_in_sitepairset($sitepairset);
    return $sitepairset;

}

=head2 to_PWM

=cut

sub to_PWM  {
    my ($self,  @args) = @_;
    my $pwm = TFBS::Matrix::PWM->new(-ID     => $self->ID,
                                     -name   => $self->name,
                                     -class  => $self->class,
                                     -matrix => _consensus2matrixref($self->word),
                                     -tags   => {$self->all_tags}
                                    );
    return $pwm;
}

=head2 validate_word

=cut


sub validate_word  {
    my ($self, $word) = @_;
    $word =~ s/[ACGTSWKMRYBDHVN]//gi;
    return ($word eq "");
}

=head2 length

=cut


sub length  {
    return length $_[0]->word;
}



# private methods


sub _replace_patterns_in_siteset  {
    my ($self, $siteset) = @_;
    my $iter = $siteset->Iterator;
    while (my $site = $iter->next)  {
        $site->pattern($self);
    }
}



sub _replace_patterns_in_sitepairset  {
    my ($self, $sitepairset) = @_;
    my $iter = $sitepairset->Iterator;
    while (my $sitepair = $iter->next)  {
        $sitepair->feature1->pattern($self);
        $sitepair->feature2->pattern($self);
    }

}

# utility functions

sub _consensus2matrixref  {
    my ($word) = @_;
    my %iupac = ( T => [0,0,0,1],
                  G => [0,0,1,0],
                  K => [0,0,1,1],
                  C => [0,1,0,0],
                  Y => [0,1,0,1],
                  S => [0,1,1,0],
                  B => [0,1,1,1],
                  A => [1,0,0,0],
                  W => [1,0,0,1],
                  R => [1,0,1,0],
                  D => [1,0,1,1],
                  M => [1,1,0,0],
                  H => [1,1,0,1],
                  V => [1,1,1,0],
                  N => [1,1,1,1]
                );
    my @vert_array;
    foreach my $letter (split '', $word)  {
        push @vert_array,
                ($iupac{uc($letter)}
                 or croak ("$letter is not a legal IUPAC DNA character"));
    }
    return _transpose_arrayref(\@vert_array);

}



sub _transpose_arrayref {
    my $vert_arrayref = shift;
    my $maxcol = scalar(@$vert_arrayref) - 1;
    my @horiz_array;
    foreach my $row (0..3) {
        push @horiz_array, [ map { $vert_arrayref->[$_][$row] } 0..$maxcol ];

    }
    return \@horiz_array;
}



1;
