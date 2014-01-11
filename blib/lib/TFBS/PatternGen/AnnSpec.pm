
# TFBS module for TFBS::PatternGen::AnnSpec
#
# Copyright Wynand Alkema
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::PatternGen::AnnSpec - a pattern factory that uses the AnnSpec program

=head1 SYNOPSIS

    my $patterngen =
            TFBS::PatternGen::AnnSpec->new(-seq_file=>'sequences.fa',
                                            -binary => 'ann-spec '


    my $pfm = $patterngen->pattern(); # $pfm is now a TFBS::Matrix::PFM object


=head1 DESCRIPTION

TFBS::PatternGen::AnnSpec builds position frequency matrices
using an external program AnnSpec (Workman, C. and Stormo, G.D. (2000) ANN-Spec: A method for discovering transcription factor binding sites with improved specificity. Proc. Pacific Symposium on Biocomputing 2000).

=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Wynand Alkema

Wynand Alkema E<lt>Wynand.Alkema@cgb.ki.seE<gt>

=cut

package TFBS::PatternGen::AnnSpec;
use vars qw(@ISA);
use strict;


# Object preamble - inherits from TFBS::PatternGen;

use TFBS::PatternGen;
use TFBS::PatternGen::AnnSpec::Motif;
use File::Temp qw(:POSIX);
use Bio::Seq;
use Bio::SeqIO;

@ISA = qw(TFBS::PatternGen);

=head2 new

 Title   : new
 Usage   : my $pattrengen = TFBS::PatternGen::AnnSpec->new(%args);
 Function: the constructor for the TFBS::PatternGen::AnnSpec object
 Returns : a TFBS::PatternGen::AnnSpec object
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
                          #  OPTIONAL: default 'ann-spec'
            -additional_params  # a string containing additional
                                #   command-line switches for the
                                #   ann-spec program

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
    $self->{'binary'} = $args{'-binary'} || 'ann-spec';
    $self->_create_seq_set(%args) or die ('Error creating sequence set');
    $self->_run_AnnSpec() or $self->throw("Error running AnnSpec.");
    return $self;
}


=head2 pattern

=head2 all_patterns

=head2 patternSet

The three methods listed above are used for the retrieval of patterns,
and are common to all TFBS::PatternGen::* classes. Please
see L<TFBS::PatternGen> for details.

=cut

sub _run_AnnSpec{
    my ($self)=shift;
    my $tmp_file = tmpnam();
    my $outstream = Bio::SeqIO->new(-file=>">$tmp_file", -format=>"fasta");
    foreach my $seqobj (@{ $self->{'seq_set'} } ) {
        $outstream->write_seq($seqobj);
    }
    $outstream->close();
    my $command_line =
        $self->{'binary'}." ".
        "-p ".$tmp_file." ".
#        $self->{'motif_length_string'}." ".
#        $self->{'nr_hits_string'}." ".
        $self->{'additional_params'}.
"";
  #  print STDERR "$command_line\n";
    my $resultstring = `$command_line`;
 #   print STDERR $resultstring;
    $self->_parse_AnnSpec_output($resultstring,$command_line);
    unlink $tmp_file;
    return 1
}

sub _parse_AnnSpec_output{
    my ($self,$resultstring,$command_line)=@_;
    if ($resultstring eq''){
#        warn "Error running AnnSpec\nNo patterns produced";
        $self->throw ("Error running AnnSpec using command:\n $command_line");
        return;
    }
    my ($consensus,$matrix)=$self->_parse_raw_matrix($resultstring);
    my ($score,$sites)=$self->_parse_sites($resultstring);
    my $motif =TFBS::PatternGen::AnnSpec::Motif->new
     (
      #-length => $length."",
      #     -bg_probabilities => [split /\s+/, $raw_bp],
           -tags => {consensus => $consensus,
                     score=>$score},
                    
           -nr_hits => 1,
          -sites=>$sites,
           -matrix => $matrix
      );
    push @{ $self->{'motifs'} }, $motif;
    return 
}

sub _parse_sites{
    my ($self,$string)=@_;
#    print $raw_motif;
    my @hits;
    my ($sites)=$string=~/STR BEST_SITES\n(.*)STR ave\(S\)/s;
    my ($average)=$string=~/STR ave\(S\)\s+(\d*\.*\d*)/;
    my ($score)=$string=~/STR ln\(ave\(sum\(exp\(S\)\)\)\)\s+(\d*\.*\d*)/;
   # print STDERR $score,"\n";
    my @sites=split/\n/,$sites;
    shift @sites;
#    print "@sites\n";
    foreach my $site (@sites){
        my @site_array=split(/\s+/,$site);
#        print "$site_array[3]\n";
#        print "$site_array[5]\n";
        my ($seq_id)=$site_array[5]=~/>(.*)/;
        my $strand=1;
        $strand=-1 if $site_array[3]=~/\'/;#MEans we have a pattern in the reverse strand
        my ($start)=$site_array[3]=~/(\d+)/;
        my $site = Bio::SeqFeature::Generic->new ( -start => $start,
						   -end => $start+(length$site_array[4])-1,
						   -strand => $strand,
						   -source => 'AnnSpec',
						   -score  => $site_array[2],
						   );
#
        foreach my $seq(@{$self->{'seq_set'}}){
            if ($seq->id eq $seq_id){
                $site->attach_seq ($seq);
            }
        }
        push (@hits,$site);
    }
    return $score,\@hits;

}

sub _parse_raw_matrix{
    my ($self,$string)=@_;
    my ($matrix)=$string=~/ALR ALIGNMENT_MATRIX.*ALR\s+-+(.*)ALR CONSENSUS/s;
    my ($consensus)=$string=~/ALR CONSENSUS (.*)\n/;
    
    #print $consensus;
    
    my @matrix=split("\n",$matrix);
    shift @matrix;
    my @pfm;
    foreach my $row(@matrix){
       # print $row;
        my @row=split /\s+/, $row;
        push @pfm, [@row[2..scalar@row-1]];
    }
    return $consensus, \@pfm;
    
}


1;
