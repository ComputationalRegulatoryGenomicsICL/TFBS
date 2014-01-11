# TFBS module for TFBS::Matrix::ICM
#
# Copyright Boris Lenhard
# 
# You may distribute this module under the same terms as perl itself
#

# POD


=head1 NAME

TFBS::Matrix::Alignment - class for alignment of PFM objects

=head1 SYNOPSIS

=over 1

=item * Making an alignment:
(See documentation of individual TFBS::DB::* modules to learn
how to connect to different types of pattern databases and retrieve
TFBS::Matrix::* objects from them.)

    my $db_obj = TFBS::DB::JASPAR2->new
		    (-connect => ["dbi:mysql:JASPAR2:myhost",
				  "myusername", "mypassword"]);
    my $pfm1 = $db_obj->get_Matrix_by_ID("M0001", "PFM");
    my $pfm2 = $db_obj->get_Matrix_by_ID("M0002", "PFM");
    
    my $alignment= new TFBS::Matrix::Alignment(
                                      -pfm1=>$pfm1,
                                      -pfm2=>$pfm2,
                                      -binary=>"/TFBS/Ext/matrix_aligner",
                                    );




=head1 DESCRIPTION

TFBS::Matrix::Alignment is a class for representing and performing
pairwise alignments of profiles (in the form of TFBS::PFM objects)
Alignments are preformed using a semi-global variant of the
Needleman-Wunsch algorithm that only permits the opening of one internal gap.
Fore reference, the algorithm is described in Sandelin et al
Funct Integr Genomics. 2003 Jun 25


=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut

# The code starts HERE:

package TFBS::Matrix::Alignment;

use vars '@ISA';
use strict;
use Bio::Root::Root;
use TFBS::Matrix;
use File::Temp qw/:POSIX/;
@ISA = qw(TFBS::Matrix Bio::Root::Root);

#alignment methods: for making and storing a single matrix-alignments
=head2 new

 Title   : new
 Usage   : my $alignment = TFBS::Matrix::Alignment->new(%args)
 Function: constructor for the TFBS::Matrix::Alignment object
 Returns : a new TFBS::Matrix::Alignment object
 Args    : # you must specify:
 
	   -pfm1,      # a TFBS::Matrix::PFM object
	   -pfm2,      # another TFBS::Matrix::PFM object
            -binary,  # a valid path to the comparison algorithm (matrixalign)
	   
	   
	   #######
 
           -ext_penalty            #OPTIONAL gap extension penalty in Needleman-Wunsch
                                    algorithmstring. Default 0.01
           -open_penalty,          #OPTIONAL gap opening penalty in Needleman-Wunsch
                                    algorithmstring. Default 3.0
            

=cut
sub new  {
    #defines and createa an alignment
    # args: two pfm objects
    # binary file
    #optional scoring penalites
    my ($class, %args) = @_;
    my $self={
            _pfm1=> $args{'-pfm1'},
            _pfm2=> $args{'-pfm2'},
            _ext_penalty=>$args{'-ext_penalty'}|| 0.01,
            _open_penalty=> $args{'-open_penalty'}|| 3.00,
            _strand=>'',
            _align_string=>'',
            _gaps=>'',
            _aligned_positions =>'',
            _score=>'', 
             };
    
    bless $self, "TFBS::Matrix::Alignment";
    # errorcheck:
    
    
    
    # save temp files
    my($fh1, $file1) = tmpnam();
    print $fh1 $args{'-pfm1'}->rawprint()|| die " Cannot save temporary files for alignment";
    my($fh2, $file2) = tmpnam();
    print $fh2 $args{'-pfm2'}->rawprint()|| die " Cannot save temporary files for alignment";
 
    #align
    my @pfm1_string;
    my @pfm2_string;

    foreach (`$args{'-binary'} $file1 $file2 $self->{'_open_penalty'} $self->{'_ext_penalty'}`){
    # my @pfm2_string;
    my $max_length=$self->{'_pfm1'}->length();
    $max_length=$self->{'_pfm2'}->length() if ( $self->{'_pfm2'}->length() > $self->{'_pfm1'}->length());
    
     if (/^PFM1/){
        s/PFM1//;
        s/\t0/\t-/g;
        @pfm1_string= split();
        next;
     }
    if (/^PFM2/){
         s/PFM2//;
         s/\t0/\t-/g;
         @pfm2_string= split();
        next;
    }
    if (/^INFO/){
        my @temp=split;
        ($self->{'_score'},  $self->{'_strand'},  $self->{'_aligned_positions'}, $self->{'_gaps'})= ($temp[3], $temp[6], $temp[7],$temp[8]);
         next; 
     }
    }
    
    my $string= ($self->{'_pfm1'}->name()||$self->{'_pfm1'}->ID()||'PFM1')."\t\t";
    my $string2=($self->{'_pfm2'}->name()||$self->{'_pfm2'}->ID()||'PFM2')."\t\t";;
     if ($pfm1_string[0]==1){
         $string.="-\t" x ($pfm2_string[0]-1);
         foreach (my $j=1; $j< $pfm2_string[0]; $j++){
            $string2.="$j\t";
         }
     }
    if ($pfm2_string[0]==1){
        $string2.="-\t" x ($pfm1_string[0]-1);
        for (my $j=1; $j< $pfm1_string[0]; $j++){
           $string.="$j\t";
        }     
     }
     $string.= join("\t", @pfm1_string);
     $string2.= join("\t", @pfm2_string);
     
     if ($pfm1_string[-1]==$self->{'_pfm1'}->length()){
         $string.="\t-" x ($self->{'_pfm2'}->length()-$pfm2_string[-1]);
       for (my $j=$pfm2_string[-1]+1; $j<= $self->{'_pfm2'}->length(); $j++){
            $string2.="\t$j";
         }  
     }
     if ($pfm2_string[-1]==$self->{'_pfm2'}->length()){
         $string2.="\t-" x ($self->{'_pfm1'}->length()-$pfm1_string[-1]);
        for (my $j=$pfm1_string[-1]+1; $j<= $self->{'_pfm1'}->length(); $j++){
            $string.="\t$j";
         }
     }
     $self->{'_align_string'}= $string ."\n". $string2;
   
  return $self; 
}

# access functions
=head2 score

 Title   : score
 Usage   : my $score = $alignmentobject->score();
 Function: access an alignment score (where each aligned position can contribute max 2)
 Returns : a floating point number
 Args    : none


=cut

=head2 score

 Title   : gaps
 Usage   : my $nr_of_gaps = $alignmentobject->gaps();
 Function: access the number of gaps in an alignment
 Returns : an integer
 Args    : none


=cut

=head2 length

 Title   : length
 Usage   : my $length = $alignmentobject->length();
 Function: access the length of an alignment (ie thenumber of aligned positions)
 Returns : an integer
 Args    : none


=cut

=head2 strand

 Title   : strand
 Usage   : my $strand = $alignmentobject->strand();
 Function: access the oriantation of the aligned patterns:
           ++= oriented as input
           +-= second pattern is reverse-complemented    
 Returns : a string
 Args    : none


=cut


=head2 alignment

 Title   : alignment
 Usage   : my $alignment_string = $alignmentobject->alignment();
 Function: access a string describing the alignment
 Returns : an string, where each number refers to a position in repective PFM.
 Position numbering is according to orientation: ie if the second profile is
 reversed, position 1 corresponds to the last position in the input profile.
 Gaps are denoted as - .

 RXR-VDR           -       1       2       3       -     4      5     -
 PPARgamma-RXRal   1       2       3       4       5     6      7     8


 Args    : none


=cut

sub gaps{ return $_[0]->{'_gaps'};}
sub score{ return $_[0]->{'_score'};}
sub length{ return $_[0]->{'_aligned_positions'};}
sub strand{ return $_[0]->{'_strand'};}
sub alignment{ return $_[0]->{'_align_string'};}

1

