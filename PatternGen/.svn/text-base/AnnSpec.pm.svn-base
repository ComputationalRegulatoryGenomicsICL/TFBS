
# TFBS module for TFBS::PatternGen::AnnSpec
#
# Copyright Wynand Alkema
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::PatternGen::AnnSpec - a pattern factory that uses the AnnSpec program (version 2.1)

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

Wynand Alkema E<lt>Wynand.Alkema@cgb.ki.se<gt>

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
    $self->{'binary'} = $args{'-binary'} || 'annspec';
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
        "-f ".$tmp_file." ".
#        $self->{'motif_length_string'}." ".
#        $self->{'nr_hits_string'}." ".
        $self->{'additional_params'}.
"";
  #  print STDERR "$command_line\n";
    my $resultstring = `$command_line`;
    print "$resultstring\n";
#    open(TEST, "test.out"); # this sentense is the one I add
#    my @lines = <TEST>;# this sentense is the one I add
#    my $resultstring = join '', @lines;# this sentense is the one I add
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

    for(my $x = 0; $x < scalar(@$consensus); $x++){
	my $motif =TFBS::PatternGen::AnnSpec::Motif->new
	    (
	     #-length => $length."",
	     #     -bg_probabilities => [split /\s+/, $raw_bp],
	     -tags => {consensus => $consensus->[$x],
		       score=>$score->[$x]},
	     
	     -nr_hits => 1,
	     -sites=>$sites->[$x],
	     -matrix => $matrix->[$x]
	     );
	push @{ $self->{'motifs'} }, $motif;
    }
    return 
}

sub _parse_sites{
    my ($self,$string)=@_;

    my (@hits, @scores);

    foreach my $substring (split /REPORTING/, $string ){
	my @sub_hits;
	my ($sites)=$substring=~/STR\s+n.*seq\n(.*)RUN\s+ALIGNMENT.*/s;
	my ($average)=$substring=~/RUN INFORMATION_CONTENT\s+(\d*\.*\d*)/;
	my ($score)=$substring=~/RUN\s+SCORE\s+(\d*\.*\d*)/;

	if($sites){
	    my @sites=split/\n/,$sites;

	    foreach my $site (@sites){
		my @site_array=split(/\s+/,$site);
		my ($seq_id)=$site_array[6]=~/>(.*)/;
		my $strand=1;
		$strand=-1 if $site_array[3]=~/\'/;#MEans we have a pattern in the reverse strand
		    my ($start)=$site_array[3]=~/(\d+)/;
		my $site = Bio::SeqFeature::Generic->new ( -start => $start,
							   -end => $start+(length$site_array[4])-1,
							   -strand => $strand,
							   -source => 'AnnSpec',
							   -score  => $site_array[2],
							   );

		foreach my $seq(@{$self->{'seq_set'}}){
		    if ($seq->id eq $seq_id){
			$site->attach_seq ($seq);
		    }
		}
		push (@sub_hits,$site);
	    }


	    push @scores, $score;
	    push @hits, \@sub_hits;
	}

    }
    return \@scores,\@hits;

}

sub _parse_raw_matrix{
    my ($self,$string)=@_;

    my (@pfms, @consensus);
    foreach my $sub_string (split /REPORTING/, $string){
	my ($ma)=$sub_string=~/RUN\s+WEIGHTS_CONS.*ALR\s+\/.*ALR\s+\#.*(ALR.*\nALR.*\nALR.*\nALR.*\s+\d+\n)ALR\s+=+.*/s;
  	my ($con)=$sub_string=~/WEIGHTS_CONS\s+(.*)\n/;

	if($ma){
	    my @matrix=split("\n",$ma);
	    my @pfm;
	    foreach my $row(@matrix){
		# print $row;
		my @row=split /\s+/, $row;
		push @pfm, [@row[2..scalar@row-1]];
	    }
	    push @pfms, \@pfm;
	    push @consensus, $con;
	}
    }
    
    return \@consensus, \@pfms;
    
}


1;
