
# TFBS module for TFBS::PatternGen::Gibbs
#
# Copyright Boris Lenhard
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::PatternGen::Gibbs - a pattern factory that uses Chip Lawrences Gibbs program

=head1 SYNOPSIS

    my $patterngen =
            TFBS::PatternGen::Gibbs->new(-seq_file=>'sequences.fa',
                                         -binary => '/Programs/Gibbs-1.0/bin/Gibbs'
                                         -nr_hits => 24,
                                         -motif_length => [8, 9, 10],
                                         -additional_params => '-x -r -e');

    my $pfm = $patterngen->pattern(); # $pfm is now a TFBS::Matrix::PFM object

=head1 DESCRIPTION

TFBS::PatternGen::Gibbs builds position frequency matrices
using an advanced Gibbs sampling algorithm implemented in external
I<Gibbs> program by Chip Lawrence. The algorithm can produce
multiple patterns from a single set of sequences.

=cut



package TFBS::PatternGen::Gibbs;
use vars qw(@ISA);
use strict;


# Object preamble - inherits from TFBS::PatternGen;

use TFBS::PatternGen;
use TFBS::PatternGen::Gibbs::Motif;
use File::Temp qw(:POSIX);
use Bio::Seq;
use Bio::SeqIO;

@ISA = qw(TFBS::PatternGen);

=head2 new

 Title   : new
 Usage   : my $db = TFBS::PatternGen::Gibbs->new(%args);
 Function: the constructor for the TFBS::PatternGen::Gibbs object
 Returns : a TFBS::PatternGen::Gibbs object
 Args    : This method takes named arguments;
            you must specify one of the following three
            -seq_list     # a reference to an array of strings
                          #   and/or Bio::Seq objects
              # or
            -seq_stream   # A Bio::SeqIO object
              # or
            -seq_file     # the name of the fasta file containing
                          #   all the sequences
           Other arguments are:
            -binary       # a fully qualified path to Gibbs executable
                          #  OPTIONAL: default 'Gibbs'
            -nr_hits      # a presumed number of pattern occurences in the
                          #   sequence set: it can be a single integer, e.g.
                          #   -nr_hits => 24 , or a reference to an array of
                          #   integers, e.g -nr_hits => [12, 24, 36]
            -motif_length # an expected length of motif in nucleotides:
                          #   it can be a single integer, e.g.
                          #   -motif_length => 8 , or a reference to an
                          #   array ofintegers, e.g -motif_length => [8..12]
            -additional_params  # a string containing additional
                                #   command-line switches for the
                                #   Gibbs program

=cut

sub new {
    my ($caller, %args) = @_;
    my $self = bless {}, ref($caller) || $caller;
    $self->{'motif_length_string'} =
        ($args{'-motif_length'}
         ? (ref($args{'-motif_length'})
            ? join(',', @{$args{'-motif_length'}})
            : $args{'-motif_length'})
         : 8 );
    $self->{'nr_hits_string'} =
        ($args{'-nr_hits'}
         ? (ref($args{'-nr_hits'})
            ? join(',', @{$args{'-nr_hits'}})
            : $args{'-nr_hits'})
         : "" );
    $self->{'additional_params'} =
        ($args{'-additional_params'}
         ? (ref($args{'-additional_params'})
            ? join(' ', @{$args{'-additional_params'}})
            : $args{'-additional_params'})
         : "" );
    $self->{'binary'} = $args{'-binary'} || 'Gibbs';
    $self->{'motifs'} = [];
    $self->_create_seq_set(%args) or die ('Error creating sequence set');
    #print $self->{'seq_set'}->[0]->seq;
    #$self->_seq_props;
    $self->_run_Gibbs() or $self->throw("Error running Gibbs.");
    return $self;
}


sub _run_Gibbs {
    my $self = shift;
    my $tmp_file = tmpnam();
    my $outstream = Bio::SeqIO->new(-file=>">$tmp_file", -format=>"fasta");
    foreach my $seqobj (@{ $self->{'seq_set'} } ) {
        $outstream->write_seq($seqobj);
    }
    $outstream->close();
    my $command_line =
        $self->{'binary'}." ".
        " -PBernoulli ".
        $tmp_file." ".
        $self->{'motif_length_string'}." ".
        $self->{'nr_hits_string'}." ".
        $self->{'additional_params'}." -n";

    my $resultstring = `$command_line`;
    $self->_parse_Gibbs_output($resultstring);
    #print STDERR "$command_line\n";
    #print STDERR $resultstring;
   
    unlink $tmp_file;
    return 1
}

=head2 pattern

=head2 all_patterns

=head2 patternSet

The three methods listed above are used for the retrieval of patterns,
and are common to all TFBS::PatternGen::* classes. Please
see L<TFBS::PatternGen> for details.

=cut

sub _parse_Gibbs_output  {
    my ($self, $resultstring) = @_;
    #print $resultstring;
    #print"===========END_RESULTSTRING===============================\n";
    $resultstring =~ s/.*=== MAP MAXIMIZATION RESULTS ===//s;
    my @raw_motifs = split /\-+\n\s+MOTIF \w\n/s, $resultstring;
    shift @raw_motifs; # discard the first one
    foreach my $raw_motif (@raw_motifs)  {
        #print $raw_motif;
        my $motif =$self->_parse_raw_motif($raw_motif) || next;
        push @{ $self->{'motifs'} }, $motif;
    }
    return 1;
}

sub _site_props{
    my ($self,$raw_motif)=@_;
    my @sites;
#    print $raw_motif;
    $raw_motif=~s/.*Num Motifs:\s+\d+\n//s;
#    print $raw_motif;
    #print "#####################################################\n";
    $raw_motif=~s/\n\s+\*+.*//s;
    #print $raw_motif,"\n";
    my @site_lines=(split("\n", $raw_motif));
    foreach my $site(@site_lines){
	my $start_seq;
	my $end_seq;
	my ($seq_nr,$pattern_nr,$start,$seq,$end,$score,$strand,$desc)=$site=~/\s+(\d+),\s+(\d+)\s+(\d+)\s+([\w,\s]+)\s+(\d+)\s+(\d\.\d+)\s+([F,R])(.*)/;
#	print $seq_nr,$pattern_nr,$start,$seq;
	if ($strand eq "F"){
	    $strand=1;
	    $start_seq=$start;
	    $end_seq=$end;
	}
	else{
	    $strand=-1;
	    $start_seq=$end;
	    $end_seq=$start;
	}
       #print $site;
        my $site = Bio::SeqFeature::Generic->new ( -start => $start_seq,
						   -end => $end_seq,
						   -strand => $strand,
						   -source => 'Gibbs sampler',
						   -score  => $score,
						   );

        $site->attach_seq ($self->{'seq_set'}->[$seq_nr-1]);
        push (@sites,$site);
    }
    foreach my $site(@sites){
        #print $site->start."\n";
    }

    return \@sites;
}

sub _parse_raw_motif  {
    # a utility function
    my ($self,$raw_motif) = @_;
#    print $raw_motif;

    my ($raw_matrix, $raw_bp, $length, $nr_hits, $MAP_score) =
        $raw_motif =~ /Motif model \(residue frequency x 100\)\n(.+)Motif probability model\n.+Background probability model\n\s+(.+?)\n.+\D(\d+) columns\nNum Motifs\: (\d+).+Difference of Logs of Maps = ([\-\.\d]+)\n/s;
    
#print $raw_matrix;    
return undef unless $raw_matrix;
    my $sites = $self->_site_props($raw_motif);
    # print STDERR
        # join ":", ($raw_matrix, $raw_bp, $length, $nr_hits); print "\n";
    my $matrix = _parse_raw_matrix($raw_matrix);
#print $matrix;    
return
      TFBS::PatternGen::Gibbs::Motif->new
#This object does not contain a new method. Instead the new method is than searched in the first ISA package. Remember that the object is still a TFBS::PatternGen::Gibbs::Motif.    
#The only ISA in the package is TFBS::PatternGen::Motif.pm. This package indeed contains the new method 
     (-length => $length."",
           -bg_probabilities => [split /\s+/, $raw_bp],
           -MAP_score => $MAP_score,
           -tags => {MAP_score => $MAP_score},
           -nr_hits => $nr_hits,
           -sites=>$sites,
           -matrix => $matrix );
}

sub _parse_raw_matrix  {
    # a utility function
    my $raw_matrix = shift;
    my @lines = split "\n", $raw_matrix;
    my (@A, @C, @G, @T);
    foreach my $line (@lines)  {
        my $value_string;
        next unless ($value_string) = $line =~ /\s+\d+\s+\|\s+(.+)/;
        $value_string =~ s/\./0/g;
        my ($a, $t, $c, $g) = split /\s+/, $value_string;
        push @A, $a;
        push @C, $c;
        push @G, $g;
        push @T, $t;
    }
    # print STDERR join(" ",@A, "\n", @C, "\n", @G, "\n", @T, "\n");
    return [\@A, \@C, \@G, \@T];

}


1;
