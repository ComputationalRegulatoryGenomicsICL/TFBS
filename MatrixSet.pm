# TFBS module for TFBS::MatrixSet
#
# Copyright Boris Lenhard
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::Matrix::Set - an agregate class representing a set of matrix patterns, containing methods for manipulating the set as a whole

=head1 SYNOPSIS

    # creation of a TFBS::MatrixSet object
    # let @list_of_matrix_objects be a list of TFBS::Matrix::* objects

    ###################################
    # Create a TFBS::MatrixSet object:

    my $matrixset = TFBS::MatrixSet->new(); # creates an empty set
    $matrixset->add_Matrix(@list_of_matrix_objects); #add matrix objects to set
    $matrixset->add_Matrix($matrixobj); # adds a single matrix object to set

    # or, same as above:

    my $matrixset = TFBS::MatrixSet->new(@list_of_matrix_objects, $matrixobj);

    ###################################
    #


=head1 DESCRIPTION

TFBS::MatrixSet is an aggregate class storing a set of TFBS::Matrix::* subclass objects, and providing methods form manipulating those sets as a whole. TFBS::MatrixSet objects are created <I>de novo<I> or returned by some database (TFBS::DB::*) retrieval methods.

=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>
Modified by Eivind Valen eivind.valen@gmail.com

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut



# The code begins HERE:

package TFBS::MatrixSet;
use vars '@ISA';

use PDL;
use Bio::Seq;
use Bio::SeqIO;
use Bio::Root::Root;
use Bio::TreeIO;
use File::Temp qw/:POSIX/;

use TFBS::Matrix;
use TFBS::_Iterator::_MatrixSetIterator;
use TFBS::SiteSet;

use strict;

use constant TRUE => 1;
use constant FALSE => 0;

@ISA = qw(Bio::Root::Root);


# Hash of accepted options and their arguments for the program
# STAMP. Reference to empty list means the option take no arguments
# This test for legal arguments is maybe superflous and can
# potentially be removed.
my %stamp_opt = (
		 -tf => [],
		 -sd => [],
		 -cc => [ "PCC", "ALLR", "ALLR_LL", "CS", "KL", "SSD" ],
		 -align => [ "NW", "SW", "SWA", "SWU" ],
		 -go => [],
		 -ge => [],
		 -out => [],
		 -overlapalign => [],
		 -nooverlapalign => [],
		 -extendedoverlap => [],
		 -printpairwise => [],
		 -tree => [ "UPGMA", "SOTA" ],
		 -ch => [],
		 -ma => [ "PPA", "IR" ],
		 -match => [],
		 -matchtop => [],
		 -prot => [],
		 -genrand => [],
		 -genscores => [],
		 -stampdir => [],
		 -tempdir => [],
		 -noclean => []
		 );




=head2 new

=cut


sub new  {
    my ($caller, @matrices) = shift;
    my $self = bless {matrix_list =>[]}, ref($caller) || $caller;
    $self->add_matrix(@matrices) if @matrices;
    return $self;
}


=head2 new2

=cut


sub new2  {
    my $class = shift;
    my %args = @_;
    my $self = bless {}, ref($class) || $class;

    if (defined $args{'-matrices'}) {
	$self->add_matrix( @{$args{'-matrices'}} ) if @{$args{'-matrices'}};
    } 
    
    if (defined $args{'-matrixfile'}) {
	my @matrices;

	open (FILE,  $args{-matrixfile})
	    or $self->throw("Could not open $args{-matrixfile}");

	while (<FILE>) {
	    /^\s*$/ && next;
	    if (/^>/) {
		
	    }
	}
	close(FILE);

	
    }

    return $self;
}


=head2 add_matrix

 Title   : add_matrix
 Usage   : $matrixset->add_matrix(@list_of_matrix_objects);
 Function: Adds matrix objects to matrixset
 Returns : object reference (usually ignored)
 Args    : one or more TFBS::Matrix::* objects

=cut

sub add_matrix  {
    my ($self, @matrices) = @_;
    foreach my $matrix (@matrices) {
	$self->throw("Argument to add_matrix_set not a TFBS::Matrix object")
	    unless $matrix->isa("TFBS::Matrix");
    }
    push @{$self->{matrix_list}}, @matrices;
    return $self;
}


sub add_Matrix {
    my $self = shift;
    return $self->add_matrix(@_);
}


=head2 add_matrix_set

 Title   : add_matrix
 Usage   : $matrixset->add_matrix(@list_of_matrixset_objects);
 Function: Adds to the matrixset matrix objects contained in one or
           more other matrixsets
 Returns : object reference (usually ignored)
 Args    : one or more TFBS::MatrixSet objects

=cut


sub add_matrix_set  {
    my ($self, @sets) = @_;
    foreach my $matrixset (@sets)  {
	$self->throw("Argument to add_matrix_set not a TFBS::Matrixset object")
	    unless $matrixset->isa("TFBS::MatrixSet");
	push @{$self->{matrix_list}}, @{$matrixset->{matrix_list}};
    }
}

sub reset {
    my ($self) = @_;
    $self->warn("reset: Deprecated method use Iterator instead.");
    @{$self->{_iterator_list}} = @{$self->{matrix_list}};
}

sub sort_by_name  {
    my ($self) = @_;
    $self->warn("sort_by_name: Deprecated method use Iterator instead.");
    @{$self->{matrix_list}} = sort { uc($a->{name}) cmp uc ($b->{name}) }
                              @{$self->{matrix_list}};
    $self->reset();
}

sub next {
    my ($self) = @_;
    $self->warn("next: Deprecated method use Iterator instead.");
    if (my $next_matrix = shift (@{$self->{_iterator_list}})) {
	return $next_matrix;
    }
    else  {
	$self->reset;
	return undef;
    }
}


=head2 search_seq

 Title   : search_seq
 Usage   : my $siteset = $matrixset->search_seq(%args)
 Function: scans a nucleotide sequence with all patterns represented
           stored in $matrixset;

           It works only if all matrix objects in $matrixset understand
           search_seq method (currently only TFBS::Matrix::PWM objects do)
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

=cut


sub search_seq  {
    my ($self, %args) = @_;
    $self->_search(%args);
}


=head2 search_aln

 Title   : search_aln
 Usage   : my $site_pair_set = $matrixset->search_aln(%args)
 Function: Scans a pairwise alignment of nucleotide sequences
	   with the pattern represented by the PWM: it reports only
           those hits that are present in equivalent positions of both
	   sequences and exceed a specified threshold score in both, AND
	   are found in regions of the alignment above the specified
	   conservation cutoff value.
           It works only if all matrix object in $matrixset understand
           search_aln method (currently only TFBS::Matrix::PWM objects do)

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

sub search_aln {
    my ($self, %args) = @_;
    my $mxit = $self->Iterator();
    my $sitepairset = TFBS::SitePairSet->new;
    my $aln = TFBS::Matrix::_Alignment->new(%args);
    while (my $mx = $mxit->next) {
        my $singleset = $mx->search_aln(%args,
                                        -alignment_setup => $aln);
        $sitepairset->add_site_pair_set($singleset);
    }
    return $sitepairset;
}



=head2 size

 Title   : size
 Usage   : my $number_of_matrices = $matrixset->size;
 Function: gets the number of matrix objects in the $matrixset
           (i.e. the size of the set)
 Returns : a number
 Args    : none

=cut


sub size  {
    scalar @{ $_[0]->{matrix_list} };
}


=head2 Iterator

 Title   : Iterator
 Usage   : my $matrixset_iterator =
                   $matrixset->Iterator(-sort_by =>'total_ic');
           while (my $matrix_object = $matrix_iterator->next) {
	       # do whatever you want with individual matrix objects
	   }
 Function: Returns an iterator object that can be used to go through
           all members of the set
 Returns : an iterator object (currently undocumentened in TFBS -
			       but understands the 'next' method)
 Args    : -sort_by # optional - currently it accepts
                    #    'ID' (alphabetically)
                    #    'name' (alphabetically)
                    #    'class' (alphabetically)
                    #    'total_ic' (numerically, decreasing order)

           -reverse # optional - reverses the default sorting order if true

=cut

sub Iterator  {

    my ($self, %args) = @_;
    return TFBS::_Iterator::_MatrixSetIterator->new($self->{matrix_list},
				$args{'-sort_by'},
				$args{'-reverse'}
			       );
}



=head2 randomize_columns

 Title   : randomize_columns
 Usage   : $matrixset->randomize_columns();
 Function: Randomizes the columns between all the matrices in the set (in place).
 Returns : nothing
 Args    : none

=cut


sub randomize_columns {
    my $self = shift;
    my (@lengths, @concat);
    my ($length, $i) = (-1, 0);

    # Concatenate to one big matrix
    for my $matrix (@{$self->{matrix_list}}) {
	$length += $matrix->length();
	push @lengths, $matrix->length();
	push @{$concat[$_]}, @{${$matrix->matrix()}[$_]} for (0..3);
    }

    # Schwartzian transform to get random permutation
    map { ( undef, $concat[0][$i], $concat[1][$i], $concat[2][$i],  $concat[3][$i] ) = @$_; $i++; } 
    sort { $a->[0] <=> $b->[0] } 
    map { [ rand(), $concat[0][$_], $concat[1][$_], $concat[2][$_], $concat[3][$_] ] } ( 0 .. $length );

    # Split it up again
    my $start = 0;
    for my $matrix (@{$self->{matrix_list}}) {
	my $length = shift(@lengths);
	my $end = $start + $length - 1;

	$matrix->matrix( [
			  [ @{$concat[0]}[$start..$end] ],
			  [ @{$concat[1]}[$start..$end] ],
			  [ @{$concat[2]}[$start..$end] ],
			  [ @{$concat[3]}[$start..$end] ]
			  ] 
			 );
	$start += $length;
    }

}


sub _search  {

    my ($self, %args) = @_;

    # DIRTY - stick tmp file name to seq object

    my $seqobj = $self->_to_seqobj(%args);
    ($seqobj->{_fastaFH}, $seqobj->{_fastafile}) = tmpnam();
    # we need $fastafile below

    my $outstream = Bio::SeqIO->new(-file=>">".$seqobj->{_fastafile}, -format=>"Fasta");
    my $subseqobj;
    if(my $subpart = $args{-subpart}) {
	my $subseq_start = $subpart->{-start};
	my $subseq_end = $subpart->{-end};
	unless($subseq_start and $subseq_end) {
	    $self->throw("Option -subpart missing suboption -relative_to, -start or -end");
	}
	$subseqobj = Bio::Seq->new(-seq => $seqobj->subseq($subseq_start, $subseq_end),
				    -id => $seqobj->id);
    }
    $outstream->write_seq($subseqobj or $seqobj);
    $outstream->close;

    # iterate through pwms
    my @PWMs;
    my $mxit = $self->Iterator();

    while (my $pwm = $mxit->next() ) {
	push @PWMs,$pwm;
    }

    # do the analysis

    my $hitlist = TFBS::SiteSet->new();

    foreach my $pwm (@PWMs)  {
	my $threshold = ($args{-threshold} or $pwm->{minscore});
	$hitlist->add_siteset($pwm->search_seq(-seqobj=>$seqobj,
					    -threshold =>$threshold,
					      -subpart=>$args{-subpart}));
    }
    delete $seqobj->{_fastaFH};
    unlink $seqobj->{_fastafile};
    delete $seqobj->{_fastafile};
    return $hitlist;
}



sub _csearch  {

    my ($self, %args) = @_;
    my $PWM_SEARCH = '/home/httpd/cgi-bin/CONSITE/bin/pwm_searchPFF';

    # DIRTY - stick tmp file name to seq object

    my $seqobj = $self->_to_seqobj(%args);
    ($seqobj->{_fastaFH}, $seqobj->{_fastafile}) = tmpnam();
    # we need $fastafile below

    my $seqFH = Bio::SeqIO->newFh(-fh=>$seqobj->{_fastaFH}, -format=>"Fasta");
    print $seqFH $seqobj;


    # iterate through pwms
    my @PWMs;
    $self->reset();

    while (my $pwm = $self->next() ) {
	push @PWMs,$pwm;
    }

    # do the analysis

    my $hitlist = TFBS::SiteSet->new();

    foreach my $pwm (@PWMs)  {
	my $threshold = ($args{-threshold} or $pwm->{minscore});
	$hitlist->add_siteset($pwm->search_seq(-seqobj=>$seqobj,
					    -threshold =>$threshold ));
    }
    delete $seqobj->{_fastaFH};
    delete $seqobj->{_fastafile};
    return $hitlist;

}



sub _bsearch  {
    my ($self,%args) = @_; #the rest of @_ goes to _to_seqob;
    my @PWMs;

    # prepare the sequence

    my $seqobj = $self->_to_seqobj(%args);
    $seqobj->{_pdl_matrix} = _seq_to_pdlmatrix($seqobj);

    # prepare the PWMs

    $self->reset();

    while (my $pwm = $self->next() ) {
	push @PWMs,$pwm;
    }

    # do the analysis

    my $hitlist = TFBS::SiteSet->new();

    foreach my $pwm (@PWMs)  {
	my $threshold = ($args{-threshold} or $pwm->{minscore});
	$hitlist->add_siteset($pwm->bsearch(-seqobj=>$seqobj,
					    -threshold =>$threshold ));
    }
    delete $seqobj->{_pdl_matrix};
    return $hitlist;
}

sub _seq_to_pdlmatrix  {

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
    elsif ($args{'-seqobj'} and ref($args{'-seqobj'}) =~ /Bio\:\:Seq/) {
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


    # CONTINUE HERE TOMORROW

}




=head2 remove_Matrix_by_ID

 Title   : remove_Matrix_by_ID
 Usage   : $matrixset->remove_Matrix_by_ID($id);
 Function: Removes a matrix from the set
 Returns : Nothing
 Args    : None

=cut

sub remove_Matrix_by_ID {
    my ($self, $id) = @_;

    my @list = grep { $_->ID() ne $id } @{$self->{matrix_list}};
    $self->{matrix_list} = \@list;
}

my $error;


sub _check_opt {
    my ($self, $opt, $arg, $list) = @_;

    # Invalid argument
    if (not defined($list)) {
	$error = "Invalid argument: $opt\n";
	return FALSE;     
    }

    # Valid flag or switch.
    return TRUE if (not scalar(@$list)); 


    # Valid switch, check the argument
    for (@$list) {
	return TRUE if ($arg eq $_) ;
    }

    # Valid switch, invalid argument
    $error = "$arg is invalid argument to $opt";
    return FALSE;
}


sub _find_optimal {
    my ($self, $output) = @_;
    my ($optimal, $score_best, $in) = (undef, undef, 0);

    for (@$output) {
	if (/NumClust/) {
	    $in = 1;
	    next;
	}

	last if (/Tree Built/);

	if ($in) {
	    my (undef, $clusters, $score) = split(/\t/);

	    if ((not defined($score_best)) || $score < $score_best) {
		$score_best = $score;
		$optimal = $clusters;
	    }
	}
    }

    return $optimal;
}


sub _run_STAMP {
    my ($self, %args) = @_;
    my $fh;

    for (keys(%args)) {
	die $error unless ($self->_check_opt($_, $args{$_}, $stamp_opt{$_}));
    }

    # Write matrices to temporary file
    if (not exists($args{-tf})) {
	$fh = new File::Temp( TEMPLATE => 'STAMP-XXXXX',
				 DIR => $args{-tempdir} || '/tmp',
				 SUFFIX => '.set');
	
	print $fh $_->STAMPprint() for (@{$self->{matrix_list}});
	$args{-tf} = $fh->filename();
    }
    # Set some default options
    $args{-tree} ||= "UPGMA";
    $args{-ma} ||= "IR";
    $args{-cc} ||= "PCC";
    $args{-align} ||= "SWU";


    # Make sure we find all files
    my $path;
    if ($args{-stampdir}) {
	$path = $args{-stampdir};
	die "Could not find STAMP at $path\n" if (not -e "$path/STAMP");
    } else {
	$path = (grep {-e "$_/STAMP"} split(/:+/, $ENV{PATH}))[0];
	$path || die "Could not find STAMP in path\n";
    }

    $args{-sd} ||= $path."/ScoreDists/JaspRand_".$args{-cc}."_".$args{-align}.".scores"; 
    die "No score distribution file found or not readable at '$args{-sd}'.\n Use -sd.\n" unless (-r $args{-sd});

    # Execute STAMP
    my $args = "";
    $args .= "$_ $args{$_} " for (keys(%args));
    my @output = `$path/STAMP -ch $args -out $fh`;
    
    # Get tree
    my $treeio = new Bio::TreeIO(-format => 'newick', -file =>  $fh->filename().".tree");
    my $tree = $treeio->next_tree;

    # Get FBP
    my $fbp = TFBS::Matrix::PFM->new(-matrixfile => $fh->filename()."FBP.txt");
    $fbp->{'filename'} = $fh->filename()."FBP.txt";

    print STDERR "::: $fbp->{'filename'} \n";

    if (not $args{-noclean}) {
	my $deleted = unlink($fh->filename()."FBP.txt", $fh->filename().".tree");
	warn("Couldn't remove temporary files") if ($deleted != 2);
    }

    return ($fh, \@output, $tree, $fbp);
}



sub _build_cluster {
    my ($self, $cluster, $node) = @_;

    if ($node->is_Leaf()) {
	for (@{$self->{matrix_list}}) {
	    if ($_->ID() eq $node->id()) {
		$cluster->add_matrix($_);
		return;
	    }
	}
    } else {
	$self->_build_cluster($cluster, $_) for ($node->each_Descendent());
    }
}




=head2 cluster

 Title   : cluster
 Usage   : $matrixset->cluster(%args)
 Function: Clusters the matrices in the set
 Returns : The root node of the hierachical clustering tree. 
           An integer specifying the optimal number of clusters.
           An array of TFBS::MatrixSets, one for each cluster.
 Args    : Many:
            -stampdir   Directory where stamp is located. Not necessary if it is in the PATH.
            -tempdir    Directory to put temporary files. Defaults to "/tmp"
            -noclean    1 to clean up temporary files, 0 otherwise
            -tree       Method for constructing tree (UPGMA/SOTA). Def:UPGMA

=cut

sub cluster {
    my ($self, %args) = @_;

    if ($self->size() <= 1) {
	warn("Can't cluster MatrixSet of size less than 2");
	return;
    }

    my ($fh, $output, $tree, $fbp) = $self->_run_STAMP(%args);

    # Find optimal cluster number
    my $optimal = $args{-optimal} || $self->_find_optimal($output);
    my $root = $tree->get_root_node();

    my @nodes = ($root);
    my @leaves;

    # Descend the tree until the optimal cluster number is reached
    while (scalar(@nodes) && (scalar(@nodes) + scalar(@leaves)) < $optimal) {
	my $node = pop @nodes;

	if ($node->is_Leaf()) {
	    push @leaves, $node;
	} else {	    
	    @nodes = sort {$a->height() <=> $b->height()} (@nodes, $node->each_Descendent());
	}
    } 

    # Build the clusters
    my @clusters;
    for (@leaves, @nodes) {
	my $cluster = $self->new();	
	$self->_build_cluster($cluster, $_);
	push @clusters, $cluster;
    }


    return ($tree, $optimal, \@clusters);
}



=head2 fbp

 Title   : fbp 
 Usage   : $matrixset->fbp(%args);
 Function: Creates a familial binding profile (FBP) for the set
 Returns : A familial binding profile represented as a TFBS::Matrix::PFM
 Args    : Many
            -stampdir   Directory where stamp is located. Not necessary if it is in the PATH.
            -tempdir    Directory to put temporary files. Defaults to "/tmp"
            -noclean    1 to clean up temporary files, 0 otherwise
            -align      Alignment method
=cut

sub fbp {
    my ($self, %args) = @_;
    if ($self->size() == 0) {
	warn("Can't create FBP for MatrixSet of size 0");
	return;
    } elsif ($self->size() == 1) {
	return @{$self->{'matrix_list'}}[0];
    }

    my ($fh, $output, $tree, $fbp) = $self->_run_STAMP(%args);

    return $fbp;
}




1;



