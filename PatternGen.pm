# TFBS module for TFBS::PatternGen
#
# Copyright Boris Lenhard
# 
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::PatternGen - a base class for pattern generators


=head1 DESCRIPTION

TFBS::PatternGen is a base classs providing methods common to all pattern generating
modules. It is meant to be inherited by a concrete pattern generator, which must have its own
constructor.

=cut


package TFBS::PatternGen;

# Object preamble - inherits from TFBS::PatternGenI;
use vars qw(@ISA);
use strict;
use TFBS::PatternGenI;
# use TFBS::PatternGen::_Motif_;
use Bio::Seq;
use Bio::SeqIO;
use Carp;

@ISA = qw(TFBS::PatternGenI);

sub new  {
    confess("TFBS::PatterGen is a base class for particular pattern generators".
            "and cannot be instantiated itself.");
}


=head2 pattern

 Title   : pattern
 Usage   : my $pattern_obj = $patterngen->pattern()
 Function: retrieves a pattern object produced by the pattern generator
 Returns : a pattern object (currently available pattern generators
	   return a TFBS::Matrix::PFM object)
 Args    : none
 Warning : If a pattern generator produces more than one pattern,
	   this method call returns only the first one and prints
	   a warning on STDERR, In those cases you should use
	   I<all_patterns> or I<patternSet> methods.
	

=cut

sub pattern {
    my ($self, %args) =@_;
    my @PFMs = $self->_motifs_to_patterns(%args);
    if (scalar(@PFMs) > 1) {
	$self->warn("The pattern generator produced multiple patterns. ".
		    "Please use patternSet method to retrieve a set object, ".
		    "or all_patterns method to retrieve an array of patterns"); 
    }
    return $PFMs[0];
}

=head2 patternSet

 Title   : patternSet
 Usage   : my $patternSet = $patterngen->patternSet()
 Function: retrieves a pattern set object containing all the patterns
	   produced by the pattern generator
 Returns : a pattern set object (currently available pattern generators
	   return a TFBS::MatrixSet object)
 Args    : none

=cut


sub patternSet {
    my ($self, %args) = @_;
    my @PFMs = $self->_motifs_to_patterns(%args);
    my $set = TFBS::MatrixSet->new();
    $set->add_matrix(@PFMs);
    return $set;
}

=head2 all_patterns

 Title   : all_patterns
 Usage   : my @patterns = $patterngen->all_patterns()
 Function: retrieves an array of pattern objects
	   produced by the pattern generator
 Returns : an array of pattern set objects (currently available 
	   pattern generators return an array of
	   TFBS::Matrix::PFM objects)
 Args    : none

=cut


sub all_patterns {
    my ($self, %args) = @_;
    my @patterns = $self->_motifs_to_patterns(%args);
    return @patterns;
}

sub _create_seq_set  {
    my ($self, %args) = @_;
    my (@raw_set, @final_set);

    if ($args{-seq_list}) {
	@raw_set = @{$args{-seq_list}};
    }
    elsif ($args{-seq_stream} ) {
	while (my $seqobj = $args{-seq_stream}->next_seq()) {
	    push @raw_set, $seqobj;
	}
    }
    elsif ($args{-seq_file} )  {
	my $seqstream = Bio::SeqIO->new(-file=>$args{-seq_file},
					-format=>"fasta");
	while (my $seqobj = $seqstream->next_seq()) {
	    push @raw_set, $seqobj;
	}
    }
	
    foreach my $seqobj (@raw_set)  {
	my $i = 1; #for unnamed sequences
	if (ref($seqobj))  {
	    my $seqstring;
	    eval { $seqstring = $seqobj->seq() };
	    if ($@) { 
		$self->throw("Invalid sequence object passed in -seq_set.");
	    } 
	    else  {
		_validate_seq(uc $seqstring) 
		    or $self->throw("Illegal character(s) in sequence: $seqstring");
	    }
	    push @final_set, $seqobj;
	}
	else  {
	    my $seqstring = $seqobj;
	    _validate_seq(uc $seqstring) 
		or $self->throw("Illegal character(s) in sequence: $seqstring");
	    push @final_set, Bio::Seq->new(-seq=>$seqstring,
					   -ID=>"unnamed".$i++,
					   -type=>"dna");
	}
    }
    
    $self->{'seq_set'} = \@final_set;
    return 1;
}


sub _motifs_to_patterns  {
    my ($self, %args) = @_;
    my $i = 1;
    my @patterns;
    my %params = ( -name => "motif",
		   -ID   => "motif",
		   -class => "unknown",
		   %args);
    foreach my $motif (@{ $self->{'motifs'} }) {
	push @patterns, $motif->pattern(-name => $params{-name}.$i,
				-ID   => $params{-ID}."#".$i,
				-class => $params{-class});
	$i++;
    }
    return @patterns;
}


sub _validate_seq  {
    # a utility function
    my $sequence = uc $_[0];
    $sequence=~ s/[ACGTN]//g;
    return ($sequence eq "" ? 1 : 0);
}

sub _check_seqs_for_uniform_length  {
    my $self = shift;
    my $reflength = $self->{'seq_set'}->[-1]->length();
    foreach my $seqobj ( @{ $self->{'seq_set'} } )  {
	if ($seqobj->length() != $reflength)  {
	    $self->throw(ref($self). "object has received sequences of unequal length");
	}
    }
}


sub all_motifs  {
    return @{$_[0]->{'motifs'}} if $_[0]->{'motifs'};
}
