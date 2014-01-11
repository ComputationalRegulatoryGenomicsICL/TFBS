# TFBS module for TFBS::PatternGen::SimplePFM
#
# Copyright Boris Lenhard
# 
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::PatternGen::SimplePFM - a simple position frequency matrix factory

=head1 SYNOPSIS
  
    my @sequences = qw( AAGCCT AGGCAT AAGCCT
                        AAGCCT AGGCAT AGGCCT
                        AGGCAT AGGTTT AGGCAT
                        AGGCCT AGGCCT );
    my $patterngen =
            TFBS::PatternGen::SimplePFM->new(-seq_list=>\@sequences);
  
    my $pfm = $patterngen->pattern(); # $pfm is now a TFBS::Matrix::PFM object

=head1 DESCRIPTION

TFBS::PatternGen::SimplePFM generates a position frequency matrix from a set
of nucleotide sequences of equal length, The sequences can be passed either
as strings, as Bio::Seq objects or as a fasta file.

This pattern generator always creates only one pattern from a given set
of sequences.

=cut

package TFBS::PatternGen::SimplePFM;
use vars qw(@ISA);
use strict;

# Object preamble - inherits from TFBS::PatternGenI;
use TFBS::PatternGen;
use TFBS::PatternGen::Motif::Matrix;

@ISA = qw(TFBS::PatternGen);


=head2 new

 Title   : new
 Usage   : my $db = TFBS::PatternGen::SimplePFM->new(%args);
 Function: the constructor for the TFBS::PatternGen::SimplePFM
	    object
 Returns : a TFBS::PatternGen::SimplePFM obkect
 Args    : This method takes named arguments;
            you must specify one of the following
            -seq_list     # a reference to an array of strings
                          # and/or Bio::Seq objects
              # or
            -seq_stream   # A Bio::SeqIO object
              # or
            -seq_file     # the name of the fasta file containing
                          # all the sequences

=cut


sub new {
    my ($caller, %args) = @_;
    my $self = bless {}, ref($caller) || $caller;
    $self->_create_seq_set(%args) or die ('Error creating sequence set');
    $self->_check_seqs_for_uniform_length();
    $self->{'motifs'} = [$self->_create_motif()];
    return $self;    
}

=head2 pattern

=head2 all_patterns

=head2 patternSet

The three above methods are used fro the retrieval of patterns,
and are common to all TFBS::PatternGen::* classes. Please
see L<TFBS::PatternGen> for details.

=cut

sub _create_motif  {
    my  $self = shift;
    my $length = $self->{'seq_set'}->[-1]->length();
    # initialize the matrix
    my $matrixref = [];
    for my $i (0..3)  {
        for my $j (0..$length-1) {
            $matrixref->[$i][$j] = 0;
        }
    }
    #fill the matrix
    my @base = qw(A C G T);
    foreach my $seqobj ( @{ $self->{seq_set} } ) {
        for my $i (0..3) {
	    my $seqstring = $seqobj->seq;
            my @seqbase = split "", uc $seqstring;
            for my $j (0..$length-1)  {
                $matrixref->[$i][$j] += ($base[$i] eq $seqbase[$j])?1:0;
            }
        }

    }
    my $nrhits =0; for my $i (0..3) {$nrhits += $matrixref->[$i][0];}
    my $motif =
        TFBS::PatternGen::Motif::Matrix->new(-matrix => $matrixref,
                                       -nr_hits=> $nrhits);
    return $motif;
}    

sub _validate_seq  {
    # a utility function
    my ($sequence)=@_;
    $sequence=~ s/[ACGT]//g;
    return ($sequence eq "" ? 1 : 0);
}


1;