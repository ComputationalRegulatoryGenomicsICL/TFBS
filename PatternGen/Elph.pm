
# TFBS module for TFBS::PatternGen::Elph
#
# Copyright Wynand Alkema
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::PatternGen::Elph - a pattern factory that uses the Elph program

=head1 SYNOPSIS

    my $patterngen =
            TFBS::PatternGen::Elph->new(-seq_file=>'sequences.fa',
                                         -binary => '/Elph/elph'
                                         -motif_length => [8, 9, 10],
                                         -additional_params => '-x -r -e');

    my $pfm = $patterngen->pattern(); # $pfm is now a TFBS::Matrix::PFM object

=head1 DESCRIPTION

TFBS::PatternGen::Gibbs builds position frequency matrices
using an advanced Gibbs sampling algorithm implemented in external
I<Gibbs> program by Chip Lawrence. The algorithm can produce
multiple patterns from a single set of sequences.

=cut



package TFBS::PatternGen::Elph;
use vars qw(@ISA);
use strict;


# Object preamble - inherits from TFBS::PatternGen;

use TFBS::PatternGen;
use TFBS::PatternGen::Elph::Motif;
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
    $self->{'additional_params'} =
        ($args{'-additional_params'}
         ? (ref($args{'-additional_params'})
            ? join(' ', @{$args{'-additional_params'}})
            : $args{'-additional_params'})
         : "" );
    $self->{'binary'} = $args{'-binary'} || 'elph';
  
    $self->{'motifs'} = [];
    $self->_create_seq_set(%args) or die ('Error creating sequence set');
   
    $self->_run_elph() or $self->throw("Error running elph.");
    return $self;
}


sub _run_elph {
    my $self = shift;
    my $tmp_file = tmpnam();
    my $outstream = Bio::SeqIO->new(-file=>">$tmp_file", -format=>"fasta");
    foreach my $seqobj (@{ $self->{'seq_set'} } ) {
        $outstream->write_seq($seqobj);
    }
    $outstream->close();
    $self->{'additional_params'}=~s/-b//;
    #This removes a -b switch. This enables long output containgin info about the sites
        
    my $command_line =
        $self->{'binary'}." ".
        $tmp_file." ".
        "LEN=".$self->{'motif_length_string'}." ".
        $self->{'additional_params'}." 2>/dev/null";

    my $resultstring = `$command_line`;
    $self->_parse_elph_output($resultstring,$command_line);
    #print STDERR "$command_line\n";
    #print STDERR $resultstring;
   
   # unlink $tmp_file;
    return 1
}

=head2 pattern

=head2 all_patterns

=head2 patternSet

The three methods listed above are used for the retrieval of patterns,
and are common to all TFBS::PatternGen::* classes. Please
see L<TFBS::PatternGen> for details.

=cut

sub _parse_elph_output  {
    my ($self, $resultstring,$command_line) = @_;
    #print $resultstring;
       if ($resultstring=~/^error/){
        $self->throw ("Error running elp command:\n $command_line");
        return;
    }
    

#Motif after optimizing
#MAP for motif: 46.735 InfoPar=0.098
#
#Motif found:
#
#Background probability model:
#   a      c      g      t
#   0.30   0.20   0.19   0.31
#
#Background counts:
#a: 1456
#c: 948
#g: 909
#t: 1487
#
#
#Motif probability model:
#Pos:     1     2     3     4     5     6
#a     1.00  0.00  1.00  0.83  0.00  0.00
#c     0.00  0.00  0.00  0.00  0.00  0.17
#g     0.00  1.00  0.00  0.17  1.00  0.83
#t     0.00  0.00  0.00  0.00  0.00  0.00
#------------------------------------------
#Info  1.73  2.42  1.73  1.19  2.42  1.75
#
#Motif counts:
#a:               6               0               6               5               0               0
#c:               0               0               0               0               0               1
#g:               0               6               0               1               6               5
#t:               0               0               0               0               0               0
#
#
(my $MAP)=$resultstring=~/MAP for motif: (.*) InfoPar=/;
($resultstring)=~s/.*Motif counts:\n//s;

#print STDERR $resultstring;
    my @array=split "\n",$resultstring;
    my @matrix;
    #print $array[0],"\n";
    foreach (0..3){
        my (@line)=split(/\s+/,$array[$_]);
        #print "@line\n";
        shift @line;
        push @matrix,\@line;
#        print "@line\n";
    }
#    print @matrix;
#print $resultstring;
    my $sites=$self->_site_props($resultstring);   
    my $motif =TFBS::PatternGen::Elph::Motif->new
     (
           -tags => {score=>$MAP},#The score in this case is the E-value given in the output
           -sites=>$sites,
           -matrix => \@matrix
      );
#    Seq.no  Pos ***** Motif  ***** Prob    D Seq.Id
#         1  354 ggatt AGAAGC cgccg 0.1389 -1 GAL1
#         2  636 caaag AGAAGG ttttt 0.6942 -1 GAL10
#         3  456 aaggc AGAAGG cagta 0.6942 -1 GAL2
#         4  444 aaagt AGAGGG ggtaa 0.1388 -1 GAL7
#         5  324 tagag AGAAGG agcaa 0.6942 -1 GAL80
#         6  165 gttac AGAAGG gccgc 0.6942 -1 GCY1
    #$resultstring =~ s/.*=== MAP MAXIMIZATION RESULTS ===//s;
    #my @raw_motifs = split /\-+\n\s+MOTIF \w\n/s, $resultstring;
    #shift @raw_motifs; # discard the first one
    #foreach my $raw_motif (@raw_motifs)  {
    #    #print $raw_motif;
    #    my $motif =$self->_parse_raw_motif($raw_motif) || next;
        push @{ $self->{'motifs'} }, $motif;
    #}
    #return 1;
}

sub _site_props{
    my ($self,$resultstring)=@_;
    my @sites;
#    print $resultstring;
    #($resultstring)=~s/.*Motif counts:\n//s;
    my @array=split(/Seq\.no/,$resultstring);
    #print $array[1];
    my @sites_array=split "\n", $array[1];
    foreach my $line(@sites_array){
#        print $line;
        next if $line=~/Pos/;
        last if $line eq'';
        my @site=split(/\s+/,$line);
#        print $site[1],"\n";
        my $nr=0;
        $nr = 1 if $site[2]==1;
        #A special case when the site startsat the first base.
        #Then no preceding quence is given and the site array =shorter by 1
        my $motif_seq=$site[4-$nr];
     #   print $motif_seq,"\n";
        my $site = Bio::SeqFeature::Generic->new ( -start => $site[2],
						   -end => $site[2]+(length$motif_seq)-1,
						   -strand => 1,
						   #Always 1 with elph
						   -source => 'Elph',
						   -score  => $site[-3],
						   );
        foreach my $seq(@{$self->{'seq_set'}}){
            if ($seq->id eq $site[-1]){#last element of the array
                $site->attach_seq ($seq);
            }
        }
        push (@sites,$site);
    }

    return \@sites;
}




1;
