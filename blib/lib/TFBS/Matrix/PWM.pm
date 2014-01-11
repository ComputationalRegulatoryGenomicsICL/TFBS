# TFBS module for TFBS::Matrix::PWM
#
# Copyright Boris Lenhard
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::Matrix::PWM - class for position weight matrices of nucleotide
patterns

=head1 SYNOPSIS

=over 4

=item * creating a TFBS::Matrix::PWM object manually:

    my $matrixref = [ [ 0.61, -3.16,  1.83, -3.16,  1.21, -0.06],
                      [-0.15, -2.57, -3.16, -3.16, -2.57, -1.83],
		      [-1.57,  1.85, -2.57, -1.34, -1.57,  1.14],
		      [ 0.31, -3.16, -2.57,  1.76,  0.24, -0.83]
		    ];
    my $pwm = TFBS::Matrix::PWM->new(-matrix => $matrixref,
				     -name   => "MyProfile",
				     -ID     => "M0001"
				    );
    # or

    my $matrixstring = <<ENDMATRIX
     0.61 -3.16  1.83 -3.16  1.21 -0.06
    -0.15 -2.57 -3.16 -3.16 -2.57 -1.83
    -1.57  1.85 -2.57 -1.34 -1.57  1.14
     0.31 -3.16 -2.57  1.76  0.24 -0.83
    ENDMATRIX
    ;
    my $pwm = TFBS::Matrix::PWM->new(-matrixstring => $matrixstring,
				     -name   	   => "MyProfile",
				     -ID           => "M0001"
				    );


=item * retrieving a TFBS::Matix::PWM object from a database:

(See documentation of individual TFBS::DB::* modules to learn
how to connect to different types of pattern databases and retrieve
TFBS::Matrix::* objects from them.)

    my $db_obj = TFBS::DB::JASPAR2->new
		    (-connect => ["dbi:mysql:JASPAR2:myhost",
				  "myusername", "mypassword"]);
    my $pwm = $db_obj->get_Matrix_by_ID("M0001", "PWM");
    # or
    my $pwm = $db_obj->get_Matrix_by_name("MyProfile", "PWM");


=item * retrieving list of individual TFBS::Matrix::PWM objects
from a TFBS::MatrixSet object

(see decumentation of TFBS::MatrixSet to learn how to create
objects for storage and manipulation of multiple matrices)

    my @pwm_list = $matrixset->all_patterns(-sort_by=>"name");

=item * scanning a nucleotide sequence with a matrix

    my $siteset = $pwm->search_seq(-file      =>"myseq.fa",
				   -threshold => "80%");

=item * scanning a pairwise alignment with a matrix

    my $site_pair_set = $pwm->search_aln(-file      =>"myalign.aln",
				         -threshold => "80%",
				         -cutoff    => "70%",
					 -window    => 50);


=back

=head1 DESCRIPTION

TFBS::Matrix::PWM is a class whose instances are objects representing
position weight matrices (PWMs). A PWM is normally calculated from a
raw position frequency matrix (see L<TFBS::Matrix::PFM>
for the explanation of position frequency matrices). For example, given
the following position frequency matrix:

    A:[ 12     3     0     0     4     0  ]
    C:[  0     0     0    11     7     0  ]
    G:[  0     9    12     0     0     0  ]
    T:[  0     0     0     1     1    12  ]

The standard computational procedure is applied to convert it into the
following position weight matrix:

    A:[ 0.61 -3.16  1.83 -3.16  1.21 -0.06]
    C:[-0.15 -2.57 -3.16 -3.16 -2.57 -1.83]
    G:[-1.57  1.85 -2.57 -1.34 -1.57  1.14]
    T:[ 0.31 -3.16 -2.57  1.76  0.24 -0.83]

which contains the "weights" associated with the occurence of each
nucleotide at the given position in a pattern.

A TFBS::Matrix::PWM object is equipped with methods to search nucleotide
sequences and pairwise alignments of nucleotide sequences with the
pattern they represent, and return a set of sites in nucleotide
sequence (a TFBS::SiteSet object for single sequence search, and a
TFBS::SitePairSet for the alignment search).

=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut


# The code begins HERE:

package TFBS::Matrix::PWM;

use vars '@ISA';
use PDL;
use strict;
use Bio::Root::Root;
use Bio::Seq;
use Bio::SeqIO;
use TFBS::Matrix;
use TFBS::SiteSet;
use TFBS::Matrix::_Alignment;
use TFBS::Ext::pwmsearch;
use File::Temp qw/:POSIX/;
@ISA = qw(TFBS::Matrix Bio::Root::Root);


#################################################################
# PUBLIC METHODS
#################################################################

=head2 new

 Title   : new
 Usage   : my $pwm = TFBS::Matrix::PWM->new(%args)
 Function: constructor for the TFBS::Matrix::PWM object
 Returns : a new TFBS::Matrix::PWM object
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

=cut

sub new  {
    my ($class, %args) = @_;
    my $matrix = TFBS::Matrix->new(%args, -matrixtype=>"PWM");
    my $self = bless $matrix, ref($class) || $class;
    $self->_set_min_max_score();
    return $self;
}


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

	   -threshold,  # minimum score for the hit, either absolute
			# (e.g. 11.2) or relative (e.g. "75%")
			# OPTIONAL: default "80%"

	   -subpart	# subpart of the sequence to search, given as
			# -subpart => { start => 140,
			#		end   => 180 }
			# where start and end are coordinates in the
			# sequence; the coordinate range is interpreted
			# in the BioPerl tradition (1-based, inclusive)
			# OPTIONAL: by default searches entire alignment

=cut

sub search_seq  {
    my ($self, %args) = @_;
    $self->_search(%args);
}


=head2 search_aln

 Title   : search_aln
 Usage   : my $site_pair_set = $pwm->search_aln(%args)
 Function: Scans a pairwise alignment of nucleotide sequences
	   with the pattern represented by the PWM: it reports only
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

	   -threshold,  # minimum score for the hit, either absolute
			# (e.g. 11.2) or relative (e.g. "75%")
			# OPTIONAL: default "80%"

	   -window,     # size of the sliding window (inn nucleotides)
			# for calculating local conservation in the
			# alignment
			# OPTIONAL: default 50

	   -cutoff      # conservation cutoff (%) for including the
			# region in the results of the pattern search
			# OPTIONAL: default "70%"

	   -subpart	# subpart of the alignment to search, given as e.g.
			# -subpart => { relative_to => 1,
			#		start       => 140,
			#		end	    => 180 }
			# where start and end are coordinates in the
			# sequence indicated by relative_to (1 for the
			# 1st sequence in the alignment, 2 for the 2nd)
			# OPTIONAL: by default searches entire alignment

	   -conservation
			# conservation profile, a TFBS::ConservationProfile
			# OPTIONAL: by default the conservation profile is
			# computed internally on the fly (less efficient)

=cut


sub search_aln  {
    my ($self, %args) = @_;
    unless ($args{-alignstring} or $args{-alignobj} or $args{-file}) {
	$self->throw
	    ("No alignment file, string or object passed to search_aln.");
    }
    $args{-pattern_set} = $self;
    my $aln = ($args{-alignment_setup} or TFBS::Matrix::_Alignment->new(%args));
    $aln->do_sitesearch(%args);
    return $aln->site_pair_set;

}

sub max_score {
    $_[0]->{max_score};
}

sub min_score {
    $_[0]->{min_score};
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

#################################################################
# PRIVATE METHODS
#################################################################


sub _set_min_max_score  {
    my ($self) = @_;
    my $transpose = $self->pdl_matrix->xchg(0,1);
    $self->{min_score} = sum(minimum $transpose);
    $self->{max_score} = sum(maximum $transpose);
}

sub _search {
    # this method runs the pwmsearch C extension and parses the data
    # similarly to _csearch, which will eventually be discontinued
    my ($self, %args)  = @_;
    my $seqobj = $self->_to_seqobj(%args);
    my ($subseq_start, $subseq_end) = (1,$seqobj->length);
    if(my $subpart = $args{-subpart}) {
	$subseq_start = $subpart->{-start};
	$subseq_end = $subpart->{-end};
	unless($subseq_start and $subseq_end) {
	    $self->throw("Option -subpart missing suboption -start or -end");
	}
    }
    return TFBS::Ext::pwmsearch::pwmsearch($self, $seqobj,
					   ($args{-threshold} or 0),
					   $subseq_start, $subseq_end);
}


sub _csearch  {

    # this is a wrapper around Wyeth Wasserman's's pwm_searchPFF program
    # until we do a proper extension

    my ($self) = shift; #the rest of @_ goes to _to_seqob;
    my %args = @_;
    my $PWM_SEARCH = $args{'-binary'}
                     || "pwm_searchPFF";

    # dump the sequence into a tempfile

    my $seqobj = $self->_to_seqobj(@_);
    my ($fastaFH, $fastafile);
    if (defined $seqobj->{_fastaFH} and defined $seqobj->{_fastafile})  {
	($fastaFH, $fastafile) = ($seqobj->{_fastaFH}, $seqobj->{_fastafile});
    }
    else {
	($fastaFH, $fastafile) = tmpnam();
	my $seqFH = Bio::SeqIO->newFh(-fh =>$fastaFH, -format=>"Fasta");
	print $seqFH $seqobj;
     }
    # we need $fastafile below


    # calculate threshold

    my $threshold;
    if ($args{-threshold})  {
	if ($args{-threshold} =~ /(.+)%/)  {
	    # percentage
	    $threshold = $self->{min_score} +
		($self->{max_score} - $self->{min_score})* $1/100;
	}
	else  {
	    # absolute value
	    $threshold = $args{-threshold};
	}
    }
    else {
	# no threshold given
	$threshold = $self->{min_score} -1;
    }


    # convert piddle to text (there MUST be a better way)

    my $pwmstring = sprintf ( $self->pdl_matrix );
    $pwmstring =~ s/\[|\]//g;                # lose []
    $pwmstring =~ s/\n /\n/g;                # lose leading spaces
    my @pwmlines = split("\n", $pwmstring); # f
    $pwmstring = join ("\n", @pwmlines[2..5])."\n";

    # dump pwm into a tempfile

    my ($pwmFH, $pwmfile) = tmpnam();  # we need $pwmfile below
    print $pwmFH $pwmstring;
    close $pwmFH;

    # run pwmsearch
    my $hitlist = TFBS::SiteSet->new();
    my ($TFname, $TFclass) = ($self->{name}, $self->{class});

    my @search_result_lines =
	`$PWM_SEARCH $pwmfile $fastafile $threshold -n $TFname -c $TFclass`;
    foreach (@search_result_lines)  {
	chomp;
	my ($seq_id, $factor, $class, $strand, $score, $pos, $siteseq) =
	    (split)[0, 2, 3, 4, 5, 7, 9];
	my $correct_strand = ($strand eq "+")? "-1" : "1";
	my $site = TFBS::Site->new ( -seq_id => $seqobj->display_id()."",
				     -seqobj  => $seqobj,
				     -strand  => $correct_strand."",
				     -pattern => $self,
				     -siteseq => $siteseq."",
				     -score   => $score."",
				     -start   => $pos,
				     -end     => $pos + length($siteseq) -1
				     );
	$hitlist->add_site($site);
    }


    # cleanup
    unlink $fastafile unless $seqobj->{_fastafile};
    unlink $pwmfile;
    return $hitlist;
}



sub _bsearch  {

    # this is Perl/PDL only search routine. For experimental purposes only

    my ($self,%args) = @_; #the rest of @_ goes to _to_seqob;
    my @PWMs;

    # prepare the sequence

    my $seqobj = $self->_to_seqobj(%args);
    my $seqmatrix = (defined $seqobj->{_pdl_matrix})
	              ? $seqobj->{_pdl_matrix}
                      : _seq_to_pdlmatrix($seqobj);

    # calculate threshold

    my $threshold;
    if ($args{-threshold})  {
	if ($args{-threshold} =~ /(.+)%/)  {
	    # percentage
	    $threshold = $self->{min_score} +
		($self->{max_score} - $self->{min_score})* $1/100;
	}
	else  {
	    # absolute value
	    $threshold = $args{-threshold};
	}
    }
    else {
	# no threshold given
	$threshold = $self->{min_score} -1;
    }

    # do the analysis

    my $hitlist = TFBS::SiteSet->new();
    foreach my $pwm ($self, $self->revcom())  {
	my $TFlength = $pwm->pdl_matrix->getdim(0);
	my $position_score_pdl = zeroes($seqmatrix->getdim(0) - $TFlength + 1);
	my $position_index_pdl = sequence($seqmatrix->getdim(0) - $TFlength + 1)+1;

	foreach my $i (0..($TFlength-1)) {
	    my $columnproduct = $seqmatrix * $pwm->pdl_matrix->slice("$i,:");
	    $position_score_pdl +=
	      $columnproduct->xchg(0,1)->sumover->slice($i.":".($i-$TFlength));
	}
	my @hitpositions =
	    list $position_index_pdl->where($position_score_pdl >= $threshold);
	my @hitscores    =
	    list $position_score_pdl->where($position_score_pdl >= $threshold);

	for my $i(0..$#hitpositions) {
	    my($pos,$score) = ($hitpositions[$i], $hitscores[$i]);
	    my $siteseq = scalar($seqobj->subseq($pos, $pos+$TFlength-1));
	    my $site = TFBS::Site->new ( -seq_id => $seqobj->display_id(),
					 -seqobj  => $seqobj,
					 -strand  => $pwm->{strand},
					 -Matrix  => $pwm,
					 -siteseq => $siteseq,
					 -score   => $score,
					 -start   => $pos);
	    $hitlist->add_site($site);
	}
    }
    return $hitlist;
}


sub _to_seqobj {
    my ($self, %args) = @_;

    my $seq;
    if ($args{-file})  {    # not a Bio::Seq
	return Bio::SeqIO->new(-file => $args{-file},
			     -format => 'fasta',
			     -moltype => 'dna')->next_seq();
    }
    elsif ($args{-seqstring}
	   or $args{-seq})
    {   # I guess it's a string then
	return Bio::Seq->new(-seq  => ($args{-seqstring} or $args{-seq}),
			     -id => ($args{-seq_id} or "undefined"),
			     -moltype => 'dna');
    }
    elsif ($args{'-seqobj'} and ref($args{'-seqobj'}) and $args{'-seqobj'}->can("seq")) {
	# do nothing (maybe check later)
	return $args{'-seqobj'};
    }
    #elsif (ref($format) =~ /Bio\:\:Seq/ and !defined $seq)  {
	# if only one parameter passed and it's a Bio::Seq
	#return $format;
    #}
    else  {
	$self->throw ("Wrong parametes passed to search method: ".%args);
    }

}

sub _seq_to_pdlmatrix  {
    # called from ?search

    # not OO - help function for search

    my $seqobj = shift;
    my $seqstring = uc($seqobj->seq());

    my @perlarray;
    foreach (qw(A C G T))  {
	my $seqtobits = $seqstring;
	eval "\$seqtobits =~ tr/$_/1/";  # curr. letter $_ to 1
	eval "\$seqtobits =~ tr/1/0/c";  # non-1s to 0
	push @perlarray, [split("", $seqtobits)];
    }
    return byte (\@perlarray);
}


sub DESTROY  {
    # nothing
}


1;
