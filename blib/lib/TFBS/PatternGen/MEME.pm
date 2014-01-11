
# TFBS module for TFBS::PatternGen::MEME
#
# Copyright Wynand Alkema
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::PatternGen::MEME - a pattern factory that uses the MEME program

=head1 SYNOPSIS

    my $patterngen =
            TFBS::PatternGen::MEME->new(-seq_file=>'sequences.fa',
                                            -binary => 'meme'


    my $pfm = $patterngen->pattern(); # $pfm is now a TFBS::Matrix::PFM object

=head1 DESCRIPTION

TFBS::PatternGen::MEME builds position frequency matrices
using an external program MEME written by Bailey and Elkan.
For information and source code of MEME see

http://www.sdsc.edu/MEME


=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Wynand Alkema


Wynand Alkema E<lt>Wynand.Alkema@cgb.ki.seE<gt>

=cut

package TFBS::PatternGen::MEME;
use vars qw(@ISA);
use strict;


# Object preamble - inherits from TFBS::PatternGen;

use TFBS::PatternGen;
use TFBS::PatternGen::SimplePFM;
use TFBS::PatternGen::MEME::Motif;
use File::Temp qw(:POSIX);
use Bio::Seq;
use Bio::SeqIO;

@ISA = qw(TFBS::PatternGen);

=head2 new

 Title   : new
 Usage   : my $pattrengen = TFBS::PatternGen::MEME->new(%args);
 Function: the constructor for the TFBS::PatternGen::MEME object
 Returns : a TFBS::PatternGen::MEME object
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
            -binary       # a fully qualified path to the 'meme' executable
                          #  OPTIONAL: default 'meme'
            -additional_params  # a string containing additional
                                #   command-line switches for the
                                #   meme program

=cut

sub new {
    my ($caller, %args) = @_;
    my $self = bless {}, ref($caller) || $caller;
    $self->{'filename'} =$args{'-seq_file'};
    
    $self->{'additional_params'} =
        ($args{'-additional_params'}
         ? (ref($args{'-additional_params'})
            ? join(' ', @{$args{'-additional_params'}})
            : $args{'-additional_params'})
         : "" );
    $self->{'binary'} = $args{'-binary'} || 'meme';

    $self->_create_seq_set(%args) or die ('Error creating sequence set');
   
    $self->_run_meme() or $self->throw("Error running MEME.");
    return $self;
}

=head2 pattern

=head2 all_patterns

=head2 patternSet

The three methods listed above are used for the retrieval of patterns,
and are common to all TFBS::PatternGen::* classes. Please
see L<TFBS::PatternGen> for details.

=cut

sub _run_meme{
    my ($self)=shift;
    my $tmp_file = tmpnam();
    my $outstream = Bio::SeqIO->new(-file=>">$tmp_file", -format=>"fasta");
    foreach my $seqobj (@{ $self->{'seq_set'} } ) {
        $outstream->write_seq($seqobj);
    }
    $outstream->close();
    my $command_line =
        $self->{'binary'}." ".
        $tmp_file." ".
        "-text ".
        "-dna ".
        $self->{'additional_params'}
        ." 2>/dev/null"
        ;
#    print STDERR "$command_line\n";
    my $resultstring = `$command_line`;
   # print STDERR $resultstring;
    $self->_parse_meme_output($resultstring,$command_line);
    unlink $tmp_file;
    return 1
}

sub _parse_meme_output{
    my ($self,$resultstring,$command_line)=@_;
    if ($resultstring=~/^error/){
#        warn "Error running AnnSpec\nNo patterns produced";
        $self->throw ("Error running MEME command:\n $command_line");
        return;
    }
    my @motifs=split(/\*\nMOTIF/,$resultstring);
    shift @motifs;#discard the first one
    #print STDERR scalar @motifs,"\n";
    foreach my $raw_motif(@motifs){
        my ($matrix,$sites,$score)=$self->_parse_raw_matrix($raw_motif);
  #  print STDERR $matrix;
    my $motif =TFBS::PatternGen::MEME::Motif->new
     (
           -tags => {score=>$score},#The score in this case is the E-value given in the output
           -sites=>$sites,
           -matrix => $matrix
      );
    push @{ $self->{'motifs'} }, $motif;
    }
 return 
}
#
#
sub _parse_raw_matrix{
    my ($self,$string)=@_;
    my @sites;
    my @matrix;
    $string=~s/(Motif \d+ block diagrams.*)//s;
#    print STDERR $string;
    my ($width,$e_value)=$string=~/width =\s+(\d+)\s+sites.*E-value =(.*)\n/;
#    print STDERR $e_value,"\n";
    $string=~s/.*Motif \d+ sites sorted by position p-value//s;
    #print STDERR $string;
    my @array=split("\n",$string);
    foreach my $line(@array){
        my $nr=0;
        my $strand=1;#if revcomp is not selected teh strand is always 1
        next if $line=~/^-/;
        next if $line=~/P-value\s+Site/;
        my (@properties)=split(/\s+/,$line);
        next if @properties<1;
#        print STDERR "@properties\n";
        #First determine whether -revcomp switch is used and thus strand info is given
        if ($properties[1] eq "+" or $properties[1] eq "-"){
            $strand=$properties[1];
            $nr=1;
        }
        my $site = Bio::SeqFeature::Generic->new ( -start =>$properties[1+$nr],
                                                   -end =>$properties[1+$nr]+$width-1,
                                                   -strand=>$strand,
                                                   -source=>'MEME',
                                                   -score=>$properties[2+$nr]
        );
        foreach my $seq(@{$self->{'seq_set'}}){
            if ($seq->id eq $properties[0]){
                $site->attach_seq ($seq);
            }
        }
        push @sites,$site;
    }
    foreach my $site(@sites){
        push @matrix,$site->seq->seq;
    }
    my $patterngen=TFBS::PatternGen::SimplePFM->new(-seq_list=>\@matrix);
    my $matrix=$patterngen->pattern->rawprint;
 #   print STDERR $matrix;
    return ($matrix,\@sites,$e_value);
}


1;