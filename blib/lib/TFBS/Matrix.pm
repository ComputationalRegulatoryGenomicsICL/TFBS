# TFBS module for TFBS::Matrix
#
# Copyright Boris Lenhard
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::Matrix - base class for matrix patterns, containing methods common
to all

=head1 DESCRIPTION

TFBS::Matrix is a base class consisting of universal constructor called by
its subclasses (TFBS::Matrix::*), and matrix manipulation methods that are
independent of the matrix type. It is not meant to be instantiated itself.

=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut



# The code begins HERE:

package TFBS::Matrix;
use vars '@ISA';

use PDL; # this dependency has to be eliminated in the future versions
use TFBS::PatternI;

use strict;

@ISA = qw(TFBS::PatternI);

sub new  {
    my $class = shift;
    my %args = @_;
    my $self = bless {}, ref($class) || $class;

    # first figure out how it was called
    # we need (-dbh and (-ID or -name) for fetching it from a database
    #         or -matrix for direct matrix input

    if (defined $args{'-matrix'}) {
        $self->set_matrix($args{'-matrix'});
    }
    elsif (defined $args{'-matrixstring'}) {
        $self->set_matrix($args{'-matrixstring'});
    }
    elsif (defined $args{-matrixfile}) {
	my $matrixstring;
	open (FILE,  $args{-matrixfile})
	    or $self->throw("Could not open $args{-matrixfile}");
	{
	    local $/ = undef;
	    $matrixstring = <FILE>;
	}
	$self->set_matrix($matrixstring);
    }
    else  {
	$self->throw("No matrix or db object provided.");
    }

    # Set the object data.
    # Parameters specified in constructor call override those
    # fetched from the database.

    $self->{'ID'}       = ($args{-ID} or
			 $self->{ID} or
			 "Unknown");
    $self->{'name'}     = ($args{-name} or
			 $self->{name} or
			 "Unknown");
    $self->{'class'} = ($args{-class} or
			 $self->{class} or
			 "Unknown");
    $self->{'strand'} = ($args{-strand} or
			 $self->{strand} or
			 "+");
    $self->{'bg_probabilities'} =
	($args{'-bg_probabilities'} || {A => 0.25,
					C => 0.25,
					G => 0.25,
					T => 0.25});

    $self->{'tags'} = $args{-tags} ? ((ref($args{-tags}) eq "HASH") ? $args{-tags} : {} ) :{};
    return $self;
}



=head2 matrix

 Title   : matrix
 Usage   : my $matrix = $pwm->matrix();
	   $pwm->matrix( [ [12, 3, 0, 0, 4, 0],
			   [ 0, 0, 0,11, 7, 0],
			   [ 0, 9,12, 0, 0, 0],
			   [ 0, 0, 0, 1, 1,12]
			 ]);

 Function: get/set for the matrix data
 Returns : a reference to 2D array of integers(PFM) or floats (ICM, PWM)
 Args    : none for get;
	   a four line string, reference to 2D array, or a 2D piddle for set

=cut


sub matrix  {
    my ($self, $matrixdata) = @_;
    $self->set_matrix($matrixdata) if $matrixdata;
    return $self->{'matrix'};
}

=head2 pdl_matrix

 Title   : pdl_matrix
 Usage   : my $pdl = $pwm->pdl_matrix();
 Function: access the PDL matrix used to store the actual
	   matrix data directly
 Returns : a PDL object, aka a piddle
 Args    : none

=cut

sub pdl_matrix  {
    pdl $_[0]->{'matrix'};
}

sub set_matrix  {
    my ($self, $matrixdata) = @_;

    # The input matrix (specified as -array=> in the constructir call
    # can either be
    #      * a 2D regular perl array with 4 rows,
    #      * a piddle (FIXME - check for 4 rows), or
    #      * a four-line string of numbers

    # print STDERR "MATRIX>>>".$matrixdata;
    if (ref($matrixdata) eq "ARRAY"
	and ref($matrixdata->[0]) eq "ARRAY"
	and scalar(@{$matrixdata}) == 4)
    {
        # it is a perl array
	$self->{'matrix'} = $matrixdata;
    }
    elsif (ref($matrixdata) eq "PDL")
    {
        # it's a piddle
	$self->{matrix} = _pdl_to_matrixref($matrixdata);
    }
    elsif (!ref($matrixdata))
	   #and (scalar split "\n",$matrixdata) == 4)
    {
	# it's a string then
	$self->{matrix} = $self->_matrix_from_string($matrixdata);
    }
    else  {
	$self->throw("Wrong data type/format for -matrix.\n".
		      "Acceptable formats are Array of Arrays (4 rows),\n".
		      "PDL Array, (4 rows),\n".
		      "or plain string (4 lines).");
    }
    # $self->_set_min_max_score();
    return 1;

}

sub _matrix_from_string  {
    my ($self, $matrixstring) = @_;
    my @array = ();
    foreach ((split "\n", $matrixstring)[0..3])  {
	s/^\s+//;
	s/\s+$//;
	push @array, [split];
    }
    return  \@array;
}

sub _set_min_max_score  {
    my ($self) = @_;
    my $transpose = $self->pdl_matrix->xchg(0,1);
    $self->{min_score} = sum(minimum $transpose);
    $self->{max_score} = sum(maximum $transpose);
}

sub _load {
    my ($self, $field, $value) = @_;
    if (substr(ref($self->{db}),0,5) eq "DBI::")  {
	# database retrieval
    }
    elsif (-d $self->{dbh})  {
	# retrieval from .pwm files in a directory
	$self->_lookup_in_matrixlist($field, $value)
	    or do {
		warn ("Matrix with $field=>$value not found.");
		return undef;
	    };
	my $ID = $self->{ID};
	my $DIR = $self->{dbh};
	$self->set_matrix(scalar `cat $DIR/$ID.pwm`); # FIXME - temporary

    }
    else  {
	$self->throw("-dbh is not a valid database handle or a directory.");
    }
}


=head2 revcom

 Title   : revcom
 Usage   : my $revcom_pfm = $pfm->revcom();
 Function: create a matrix pattern object which is reverse complement
	    of the current one
 Returns : a TFBS::Matrix::* object of the same type as the one
	    the method acted upon
 Args    : none

=cut

sub revcom  {
    my ($self) = @_;
    my $revcom_matrix =
	$self->new(-matrix => $self->pdl_matrix->slice('-1:0,-1:0'),
		   # the above line rotates the original matrix 180 deg,
		   -ID       => ($self->{ID} or ""),
		   -name     => ($self->{name} or ""),
		   -class => ($self->{class} or ""),
		   -strand   => ($self->{strand} and $self->{strand} eq "-") ? "+" : "-",
		   -tags     => ($self->{tags} or {})  );
    return $revcom_matrix;
}


=head2 rawprint

 Title   : rawprint
 Usage   : my $rawstring = $pfm->rawprint);
 Function: convert matrix data to a simple tab-separated format
 Returns : a four-line string of tab-separated integers or floats
 Args    : none

=cut


sub rawprint  {
    my $self = shift;
    my $pwmstring = sprintf ( $self->pdl_matrix );
    $pwmstring =~ s/\[|\]//g;                # lose []
    $pwmstring =~ s/\n /\n/g;                # lose leading spaces
    my @pwmlines = split("\n", $pwmstring); # f
    $pwmstring = join ("\n", @pwmlines[2..5])."\n";
    return $pwmstring;
}

=head2 prettyprint

 Title   : prettyprint
 Usage   : my $prettystring = $pfm->prettyprint();
 Function: convert matrix data to a human-readable string format
 Returns : a four-line string with nucleotides and aligned numbers
 Args    : none

=cut

sub prettyprint  {
    my $self = shift;
    my $pwmstring = sprintf ( $self->pdl_matrix );
    $pwmstring =~ s/\[|\]//g;                # lose []
    $pwmstring =~ s/\n /\n/g;                # lose leading spaces
    my @pwmlines = split("\n", $pwmstring); #
    @pwmlines = ("A  [$pwmlines[2] ]",
		 "C  [$pwmlines[3] ]",
		 "G  [$pwmlines[4] ]",
		 "T  [$pwmlines[5] ]");
    $pwmstring = join ("\n", @pwmlines)."\n";
    return $pwmstring;
}

=head2 length

 Title   : length
 Usage   : my $pattern_length = $pfm->length;
 Function: gets the pattern length in nucleotides
	    (i.e. number of columns in the matrix)
 Returns : an integer
 Args    : none

=cut

sub length  {
    my $self = shift;
    return $self->pdl_matrix->getdim(0);
}

sub _pdl_to_matrixref {
    my ($matrixdata) = @_;
    unless ($matrixdata->isa("PDL")) {
	die "A non-PDL object passed to _pdl_to_matrixref";
    }
    my @list = list $matrixdata;
    my @array;
    my $matrix_width = scalar(@list) / 4;
    for (0..3)  {
	push @array, [splice(@list, 0, $matrix_width)];
    }
    return \@array;
}


sub DESTROY  {
    # nothing
}



1;




