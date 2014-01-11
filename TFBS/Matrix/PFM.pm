# TFBS module for TFBS::Matrix::PFM
#
# Copyright Boris Lenhard
# 
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::Matrix::PFM - class for raw position frequency matrix patterns


=head1 SYNOPSIS

=over 4

=item * creating a TFBS::Matrix::PFM object manually:


    my $matrixref = [ [ 12,  3,  0,  0,  4,  0 ],
		      [  0,  0,  0, 11,  7,  0 ],
		      [  0,  9, 12,  0,  0,  0 ],
		      [  0,  0,  0,  1,  1, 12 ]
		    ];	
    my $pfm = TFBS::Matrix::PFM->new(-matrix => $matrixref,
				     -name   => "MyProfile",
				     -ID     => "M0001"
				    );
    # or
 
    my $matrixstring =
        "12 3 0 0 4 0\n0 0 0 11 7 0\n0 9 12 0 0 0\n0 0 0 1 1 12";
 
    my $pfm = TFBS::Matrix::PFM->new(-matrixstring => $matrixstring,
				     -name   	   => "MyProfile",
				     -ID           => "M0001"
				    );
 
 
=item * retrieving a TFBS::Matix::PFM object from a database:

(See documentation of individual TFBS::DB::* modules to learn
how to connect to different types of pattern databases and 
retrieve TFBS::Matrix::* objects from them.)
    
    my $db_obj = TFBS::DB::JASPAR2->new
		    (-connect => ["dbi:mysql:JASPAR2:myhost",
				  "myusername", "mypassword"]);
    my $pfm = $db_obj->get_Matrix_by_ID("M0001", "PFM");
    # or
    my $pfm = $db_obj->get_Matrix_by_name("MyProfile", "PFM");


=item * retrieving list of individual TFBS::Matrix::PFM objects
from a TFBS::MatrixSet object

(See the L<TFBS::MatrixSet> to learn how to create 
objects for storage and manipulation of multiple matrices.)

    my @pfm_list = $matrixset->all_patterns(-sort_by=>"name");


=item * convert a raw frequency matrix to other matrix types:

    my $pwm = $pfm->to_PWM(); # convert to position weight matrix
    my $icm = $icm->to_ICM(); # convert to information con

=back        

=head1 DESCRIPTION

TFBS::Matrix::PFM is a class whose instances are objects representing
raw position frequency matrices (PFMs). A PFM is derived from N
nucleotide patterns of fixed size, e.g. the set of sequences

    AGGCCT
    AAGCCT
    AGGCAT
    AAGCCT
    AAGCCT
    AGGCAT
    AGGCCT
    AGGCAT
    AGGTTT
    AGGCAT
    AGGCCT
    AGGCCT


will give the matrix:

    A:[ 12  3  0  0  4  0 ]
    C:[  0  0  0 11  7  0 ]
    G:[  0  9 12  0  0  0 ]
    T:[  0  0  0  1  1 12 ]

which contains the count of each nucleotide at each position in the
sequence. (If you have a set of sequences as above and want to
create a TFBS::Matrix::PFM object out of them, have a look at
TFBS::PatternGen::SimplePFM module.)

PFMs are easily converted to other types of matrices, namely
information content matrices and position weight matrices. A
TFBS::Matrix::PFM object has the methods to_ICM and to_PWM which
do just that, returning a TFBS::Matrix::ICM and TFBS::Matrix::PWM
objects, respectively. 

=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut


# The code begins HERE:

package TFBS::Matrix::PFM;

use vars '@ISA';
use PDL;
use strict;
use Bio::Root::Root;
use Bio::SeqIO;
use TFBS::Matrix;
use TFBS::Matrix::ICM;
use TFBS::Matrix::PWM;
use File::Temp qw/:POSIX/;
@ISA = qw(TFBS::Matrix Bio::Root::Root);

use constant EXACT_SCHNEIDER_MAX => 30;


#######################################################
# PUBLIC METHODS
#######################################################

=head2 new

 Title   : new
 Usage   : my $pfm = TFBS::Matrix::PFM->new(%args)
 Function: constructor for the TFBS::Matrix::PFM object
 Returns : a new TFBS::Matrix::PFM object
 Args    : # you must specify either one of the following three:
 
	   -matrix,      # reference to an array of arrays of integers
	      #or
	   -matrixstring,# a string containing four lines
	                 # of tab- or space-delimited integers
	      #or
	   -matrixfile,  # the name of a file containing four lines
	                 # of tab- or space-delimited integers
	   #######
 
           -name,        # string, OPTIONAL
           -ID,          # string, OPTIONAL
           -class,       # string, OPTIONAL
           -tags         # an array reference, OPTIONAL
Warnings  : Warns if the matrix provided has columns with different
            sums. Columns with different sums contradict the usual
	    origin of matrix data and, unless you are absolutely sure
	    that column sums _should_ be different, it would be wise to
	    check your matrices.

=cut

sub new  {
    my ($class, %args) = @_;
    my $matrix = TFBS::Matrix->new(%args, -matrixtype=>"PFM");
    my $self = bless $matrix, ref($class) || $class;
    $self->_check_column_sums();
    return $self;
}

=head2 column_sum

 Title   : column_sum
 Usage   : my $nr_sequences = $pfm->column_sum()
 Function: calculates the sum of elements of one column
	   (the first one by default) which normally equals the
           number of sequences used to derive the PFM. 
 Returns : the sum of elements of one column (an integer)
 Args    : columnn number (starting from 1), OPTIONAL - you DO NOT
           need to specify it unless you are dealing with a matrix

=cut

sub column_sum {
    my ($self, $column) = (@_,1);
    return $self->pdl_matrix->slice($column-1)->sum;
    
}

=head2 to_PWM

 Title   : to_PWM
 Usage   : my $pwm = $pfm->to_PWM()
 Function: converts a raw frequency matrix (a TFBS::Matrix::PFM object)
	   to position weight matrix. At present it assumes uniform
	   background distribution of nucleotide frequencies.
 Returns : a new TFBS::Matrix::PWM object
 Args    : none; in the future releases, it should be able to accept
	   a user defined background probability of the four
	   nucleotides

=cut

sub to_PWM  {
    my ($self, %args) = @_;
    my $bg = ($args{'-bg_probabilities' } || $self->{'bg_probabilities'});
    my $bg_pdl = 
	transpose pdl ($bg->{'A'}, $bg->{'C'}, $bg->{'G'}, $bg->{'T'});
    my $nseqs = $self->pdl_matrix->sum / $self->length;
    my $q_pdl = ($self->pdl_matrix +$bg_pdl*sqrt($nseqs))
		 / 
		($nseqs + sqrt($nseqs));
    my $pwm_pdl = log2(4*$q_pdl);

    my $PWM = TFBS::Matrix::PWM->new
	( (map {("-$_", $self->{$_}) } keys %$self),
          # do not want tags to point to the same arrayref as in $self:
	  -tags => \%{ $self->{'tags'}}, 
	  -bg_probabilities => \%{ $self->{'bg_probabilities'}}, 
	  -matrix    => $pwm_pdl
	);
    return $PWM;
    
}


=head2 to_ICM

 Title   : to_ICM
 Usage   : my $icm = $pfm->to_ICM()
 Function: converts a raw frequency matrix (a TFBS::Matrix::PFM object)
	   to information content matrix. At present it assumes uniform
	   background distribution of nucleotide frequencies.
 Returns : a new TFBS::Matrix::ICM object
 Args    : -small_sample_correction # undef (default), 'schneider' or 'pseudocounts'

How a PFM is converted to ICM:
 
For a PFM element PFM[i,k], the probability without
pseudocounts is estimated to be simply

  p[i,k] = PFM[i,k] / Z

where 
- Z equals the column sum of the matrix i.e. the number of motifs used
to construct the PFM. 
- i is the column index (position in the motif)
- k is the row index (a letter in the alphacer, here k is one of
(A,C,G,T)

Here is how one normally calculates the pseudocount-corrected positional
probability p'[i,j]:

  p'[i,k] = (PFM[i,k] + 0.25*sqrt(Z)) / (Z + sqrt(Z))

0.25 is for the flat distribution of nucleotides, and sqrt(Z) is the
recommended pseudocount weight. In the general case,

  p'[i,k] = (PFM[i,k] + q[k]*B) / (Z + B)

where q[k] is the background distribution of the letter (nucleotide) k,
and B an arbitrary pseudocount value or expression (for no pseudocounts
B=0).

For a given position i, the deviation from random distribution in bits
is calculated as (Baldi and Brunak eq. 1.9 (2ed) or 1.8 (1ed)):

- for an arbitrary alphabet of A letters:

  D[i] = log2(A) + sum_for_all_k(p[i,k]*log2(p[i,k])) 

- special case for nucleotides (A=4)

  D[i] = 2 + sum_for_all_k(p[i,k]*log2(p[i,k]))  

D[i] equals the information content of the position i in the motif. To
calculate the entire ICM, you have to calculate the contrubution of each
nucleotide at a position i to D[i], i.e.

ICM[i,k] = p'[i,k] * D[i]


=cut

sub to_ICM  {
    my ($self, %args) = @_;
    my $bg = ($args{'-bg_probabilities' } || $self->{'bg_probabilities'});



    # compute ICM
    
    my $bg_pdl = 
	transpose pdl ($bg->{'A'}, $bg->{'C'}, $bg->{'G'}, $bg->{'T'});
    my $Z_pdl = $self->pdl_matrix->xchg(0,1)->sumover;

    # pseudocount calculation 

    my $B = 0; 
    if (lc($args{'-small_sample_correction'} or "") eq "pseudocounts") {

	$B = sqrt($Z_pdl);
    }
    else {
	$B = 0;   	# do not add pseudocounts
    }

    
    my $p_pdl = ($self->pdl_matrix +$bg_pdl*$B)/ ($Z_pdl + $B);
    my $plog_pdl = $p_pdl*log2($p_pdl);
    $plog_pdl = $plog_pdl->badmask(0);
    my $D_pdl = 2 + $plog_pdl->xchg(0,1)->sumover;
    my $ic_pdl = $p_pdl * $D_pdl;


    # apply Schneider correction if requested

    if (lc($args{'-small_sample_correction'} or "") eq "schneider")  {
	my $columnsum_pdl = $ic_pdl->transpose->sumover;
	my $corrected_columnsum_pdl = 
	    $columnsum_pdl 
	    + _schneider_correction ($self->pdl_matrix, $bg_pdl);
	$ic_pdl *= $corrected_columnsum_pdl/$columnsum_pdl;
    }
 
    # construct and return an ICM object

    my $ICM = TFBS::Matrix::ICM->new
	( (map {("-$_" => $self->{$_})} keys %$self),
	  -tags => \%{ $self->{'tags'}}, 
	  -bg_probabilities => \%{ $self->{'bg_probabilities'}}, 
	  -matrix    => $ic_pdl
	);
    return $ICM;

}


=head2 draw_logo

 Title   : draw_logo
 Usage   : my $gd_image = $pfm->draw_logo()
 Function: draws a sequence logo; similar to the 
           method in TFBS::Matrix::ICM, but can automatically calculate
           error bars for drawing
 Returns : a GD image object (see documentation of GD module)
 Args    : many; PFM-specific options are:
           -small_sample_correction # One of 
                                    # "Schneider" (uses correction 
                                    #   described by Schneider et al.
                                    #   (Schneider t et al. (1986) J.Biol.Chem.
                                    # "pseudocounts" - standard pseudocount 
                                    #   correction,  more suitable for 
                                    #   PFMs with large r column sums
                                    # If the parameter is ommited, small
                                    # sample correction is not applied

           -draw_error_bars         # if true, adds error bars to each position
                                    # in the logo. To calculate the error bars,
                                    # it uses the -small_sample_connection
                                    # argument if explicitly set,  
                                    # or "Schneider" by default
For other args, see draw_logo entry in TFBS::Matrix::ICM documentation

=cut

sub draw_logo {
    my ($self, %args) = @_;
    if ($args{'-draw_error_bars'})  {
	$args{'-small_sample_correction'} ||= "Schneider"; # default Schneider

	my $pdl_no_correction = 
	    $self->to_ICM()
	    ->pdl_matrix->transpose->sumover;
	my $pdl_with_correction = 
	    $self->to_ICM(-small_sample_correction 
			  => $args{'-small_sample_correction'})
	    ->pdl_matrix->transpose->sumover;

	$args{'-error_bars'} = 
	    [list ($pdl_no_correction - $pdl_with_correction)];
	    
    }
    $self->to_ICM(%args)->draw_logo(%args);
}


=head2 add_PFM

 Title   : add_PFM
 Usage   : $pfm->add_PFM($another_pfm)
 Function: adds the values of $pnother_pfm matrix to $pfm
 Returns : reference to the updated $pfm object
 Args    : a TFBS::Matrix::PFM object

=cut


sub add_PFM  {
    my ($self, $pfm) = @_;
    $pfm->isa("TFBS::Matrix::PFM") 
	or $self->throw("Wrong or no argument passed to add_PFM");
    my $sum = $self->pdl_matrix + $pfm->pdl_matrix;
    $self->set_matrix($sum);
    return $self;
}



=head2 name

=head2 ID

=head2 class

=head2 matrix

=head2 length

=head2 revcom

=head2 rawprint

=head2 prettyprint

The above methods are common to all matrix objects. Please consult
L<TFBS::Matrix> to find out how to use them.

=cut

###############################################
# PRIVATE METHODS
###############################################

sub _check_column_sums  {
    my ($self) = @_;
    my $pdl = $self->pdl_matrix->sever();
    my $rowsums = $pdl->xchg(0,1)->sumover();
    if ($rowsums->where($rowsums != $rowsums->slice(0))->getdim(0) > 0)  {
	$self->warn("PFM for ".$self->{ID}." has unequal column sums");
    }
}

sub DESTROY  {
    # does nothing
}

###############################################
# UTILITY FUNCTIONS
###############################################

sub log2 { log($_[0]) / log(2); }


sub _schneider_correction {
    my ($pdl, $bg_pdl) = @_;
    my $Hg = -sum ($bg_pdl*log2($bg_pdl));
    my (@Hnbs, %saved_Hnb);
    my $is_flat = _is_bg_flat(list $bg_pdl);
    
    my @factorials = (1);
    if (min($pdl->transpose->sumover) <= EXACT_SCHNEIDER_MAX) {
	foreach my $i (1..max($pdl->transpose->sumover)) {
	    $factorials[$i] =$factorials[$i-1] * $i;
	}
    }
    my @column_sums = list $pdl->transpose->sumover;
    foreach my $colsum (@column_sums)  {
	if (defined($saved_Hnb{$colsum})) {
	    push @Hnbs, $saved_Hnb{$colsum};
	}
	else  {
	    my $Hnb;
	    if ($colsum <= EXACT_SCHNEIDER_MAX)  {
		if ($is_flat)  {
		    $Hnb = _schneider_Hnb_precomputed($colsum);
		}
		else {
		    $Hnb = _schneider_Hnb_exact($colsum, $bg_pdl, 
						\@factorials);
		}
	    }
	    else {
		$Hnb = _schneider_Hnb_approx($colsum, $Hg);

	    }
	    $saved_Hnb{$colsum} = $Hnb;
	    push @Hnbs, $Hnb;
	}
    }
    return -$Hg + pdl(@Hnbs);
    
}


sub _schneider_Hnb_exact {
    my ($n, $bg_pdl, $rFactorial) = @_;
    
    my $is_flat = _is_bg_flat(list $bg_pdl);
    return 0 if $n==1;
#    my @fctrl = (1);
#    foreach my $i (1..max($pdl->transpose->sumover)) {
#	$rFactorial->[$i] =$rFactorial->[$i-1] * $i;
#    }
#    my @colsum = list $pdl->transpose->sumover;
    my ($na, $nc, $ng, $nt) = ($n, 0,0,0);
#    my $n = $colsum[0];
    my $E_Hnb=0;
    while (1) {
	my $ns_pdl = pdl [$na, $nc, $ng, $nt];
	my $Pnb = ($rFactorial->[$n]
		   /
		   ($rFactorial->[$na]
		    *$rFactorial->[$nc]
		    *$rFactorial->[$ng]
		    *$rFactorial->[$nt])
		   )*prod($bg_pdl->transpose**pdl($na, $nc, $ng, $nt));
	my $Hnb = -1 * sum(($ns_pdl/$n)*log2($ns_pdl/$n)->badmask(0));
	$E_Hnb += $Pnb*$Hnb;
	

	if ($nt) {
	    if    ($ng) { $ng--; $nt++, }
	    elsif ($nc) { $nc--; $ng = $nt+1; $nt = 0; }
	    elsif ($na) { $na--; $nc = $nt+1; $nt = 0; }
	    else        { last; }
	}
	else {
	    if    ($ng) { $ng--; $nt++, }
	    elsif ($nc) { $nc--; $ng++; }
	    else        { $na--; $nc++; $nt = 0; }
	}
    }
    return $E_Hnb;
}



sub _schneider_Hnb_approx  {
    my ($colsum,  $Hg) = @_;
    return $Hg -3/(2*log(2)*$colsum);
    
}



sub _schneider_Hnb_precomputed {
    my $i = shift;
    if ($i<1 or $i>30)  { 
	die "Precomputed params only available for colsums 1 to 30)";
    }
    my @precomputed = 
	(
	 0, # 1
	 0.75, # 2
	 1.11090234442608, # 3
	 1.32398964833609, # 4
	 1.46290503577084, # 5
	 1.55922640783176, # 6
	 1.62900374746751, # 7
	 1.68128673969433, # 8
	 1.7215504663901, # 9
	 1.75328193031842, # 10
	 1.77879136615189, # 11
	 1.79965855531179, # 12
	 1.81699248819687, # 13
	 1.8315892710679, # 14
	 1.84403166371213, # 15
	 1.85475371994775, # 16
	 1.86408383599326, # 17
	 1.87227404728809, # 18
	 1.87952034817826, # 19
	 1.88597702438913, # 20
	 1.89176691659196, # 21
	 1.89698887214968, # 22
	 1.90172322434865, # 23
	 1.90603586889234, # 24
	 1.90998133028897, # 25
	 1.91360509239859, # 26
	 1.91694538711761, # 27
	 1.92003457997914, # 28
	 1.92290025302018, # 29
	 1.92556605820924, # 30
	 );
    return $precomputed[$i-1];
}


sub _is_bg_flat {
    my @bg = @_;
    my $ref = shift;
    foreach my $other (@bg) {
	return 0 unless $ref==$other;
    }
    return 1;
}


1;
