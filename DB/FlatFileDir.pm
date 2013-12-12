# TFBS module for TFBS::DB::FlatFileDir
#
# Copyright Boris Lenhard
# 
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::DB::FlatFileDir - interface to a database of pattern matrices
stored as a collection of flat files in a dedicated directory


=head1 SYNOPSIS

=over 4

=item * creating a database object by connecting to the existing directory

    my $db = TFBS::DB::FlatFileDir->connect("/home/boris/MatrixDir");

=item * retrieving a TFBS::Matrix::* object from the database

    # retrieving a PFM by ID
    my $pfm = $db->get_Matrix_by_ID('M00079','PFM');
 
    #retrieving a PWM by name
    my $pwm = $db->get_Matrix_by_name('NF-kappaB', 'PWM');

=item * retrieving a set of matrices as a TFBS::MatrixSet object according to various criteria
    
    # retrieving a set of PWMs from a list of IDs:
    my @IDlist = ('M0019', 'M0045', 'M0073', 'M0101');
    my $matrixset = $db->get_MatrixSet(-IDs => \@IDlist,
				       -matrixtype => "PWM");
 
    # retrieving a set of ICMs from a list of names:
    my @namelist = ('p50', 'p53', 'HNF-1'. 'GATA-1', 'GATA-2', 'GATA-3');
    my $matrixset = $db->get_MatrixSet(-names => \@namelist,
				       -matrixtype => "ICM");
 
    # retrieving a set of all PFMs in the database
    my $matrixset = $db->get_MatrixSet(-matrixtype => "PFM");

=item * creating a new FlatFileDir database in a new directory:
 
    my $db = TFBS::DB::JASPAR2->create("/home/boris/NewMatrixDir");

=item * storing a matrix in the database:

    #let $pfm is a TFBS::Matrix::PFM object
    $db->store_Matrix($pfm);



=back

=head1 DESCRIPTION

TFBS::DB::FlatFileDir is a read/write database interface module that
retrieves and stores TFBS::Matrix::* and TFBS::MatrixSet
objects in a set of flat files in a dedicated directory. It has a
very simple structure and can be easily set up manually if desired.


=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut


# The code begins HERE:



package TFBS::DB::FlatFileDir;

use vars qw(@ISA);
use strict;
use Bio::Root::Root;
use TFBS::Matrix::PFM;
use TFBS::Matrix::ICM;
use TFBS::Matrix::PWM;
use TFBS::MatrixSet;

@ISA = qw(TFBS::DB Bio::Root::Root);

=head2 new

 Title   : new
 Usage   : my $db = TFBS::DB::FlatFileDir->new(%args);
 Function: the formal constructor for the TFBS::DB::FlatFileDir object;
	   most users will not use it - they will use specialized
	   I<connect> or I<create> constructors to create a
	   database object
 Returns : a TFBS::DB::FlatFileDir object
 Args    : -dir       # the directory containing flat files

=cut


sub new  {
    my $caller = shift;
    my $self = bless {_item => {}, 
		      _idlist_of_name=>{} , 
		      _idlist_of_class=>{}
		     }, 
                 ref ($caller) || $caller;
    if (-d $_[0])  {
	$self->{dir} = $_[0];
    }
    elsif ($_[0] eq '-dir' and -d $_[1])  {
	$self->{dir} = $_[1];
    }
    else  {
	$self->throw("Error initializing FlatFileDir database dir: ",
		     ($_[1] or $_[0] or "No directory parameter passed."));
    }
    $self->_load_db_index(); 
    return $self;
}


=head2 connect

 Title   : connect
 Usage   : my $db = TFBS::DB::FlatFileDir->connect($directory);
 Function: Creates a database object that retrieves TFBS::Matrix::*
	   object data from or stores it in an existing directory
 Returns : a TFBS::DB::FlatFileDir object
 Args    : ($directory)
	    The name of the directory (possibly with fully qualified
	    path).

=cut

sub connect  {
    my ($caller, $dir) = @_;
    $caller->new(-dir=>$dir);
}


=head2 create

 Title   : create
 Usage   : my $newdb = TFBS::DB::FlatFileDir->create($new_directory);
 Function: connects to the database server, creates a new directory,
	   sets up a FlatFileDir database and returns a database
	   object that interfaces the database
 Returns : a TFBS::DB::FlatFileDir object
 Args    : ($new_directory)
	    The name of the directory to create
	    (possibly with fully qualified path).

=cut

sub create  {
    my ($caller, $dir) = @_;
    if (-d $dir) { die ("Directory $dir exists") ; } 
    mkdir ($dir) or  die("Error creating directory $dir, stopped");
    open FILE, ">$dir/matrix_list.txt"
	or die ("Error creating matrix_list.txt");
    close FILE;
    $caller->new(-dir=>$dir);
}

=head2 get_Matrix_by_ID

 Title   : get_Matrix_by_ID
 Usage   : my $pfm = $db->get_Matrix_by_ID('M00034', 'PFM');
 Function: fetches matrix data under the given ID from the
           database and returns a TFBS::Matrix::* object
 Returns : a TFBS::Matrix::* object; the exact type of the
	   object depending on the second argument (allowed
	   values are 'PFM', 'ICM', and 'PWM'); returns undef if
	   matrix with the given ID is not found
 Args    : (Matrix_ID, Matrix_type)
	   Matrix_ID is a string; Matrix_type is one of the
	   following: 'PFM' (raw position frequency matrix),
	   'ICM' (information content matrix) or 'PWM' (position
	   weight matrix)
	   If Matrix_type is omitted, a PWM is retrieved by default.

=cut

sub get_Matrix_by_ID  {
    my ($self, $ID, $mt) = @_;
    $self->throw("No ID passed to get_Matrix_by_ID.") unless defined $ID;
    $mt = defined $mt ? $self->_check_matrixtype($mt) : "PWM"; 
    my $matrixobj;
    {
	no strict 'refs';
	my $working_mt = $mt = uc $mt;
	my $matrixstring = $self->_read_file($ID,$mt)
			    # if no desired $mt, is there a PFM?
			    || $self->_read_file($ID,$working_mt="PFM")
			    || return undef;

	eval("\$matrixobj= TFBS::Matrix::$working_mt->new".' 
	    ( -ID    => $ID,
	      -name  => $self->{_item}->{$ID}->{name} ||  "",
	      -class => $self->{_item}->{$ID}->{class}||  "",
	      -matrix=> $matrixstring, 
	      -tags=> $self->{_item}->{$ID}->{tags}
	      
	      );'.
	     "if (\$working_mt ne \$mt) {\$matrixobj = \$matrixobj->to_$mt;}");
	if ($@) {$self->throw($@); }
    }
    # print "MATRIXOBJ: $matrixobj\n";
    return $matrixobj;
    
}

=head2 get_Matrix_by_name

 Title   : get_Matrix_by_name
 Usage   : my $pfm = $db->get_Matrix_by_name('HNF-1', 'PWM');
 Function: fetches matrix data under the given name from the
	   database and returns a TFBS::Matrix::* object
 Returns : a TFBS::Matrix::* object; the exact type of the object
	   depending on the second argument (allowed values are
	   'PFM', 'ICM', and 'PWM')
 Args    : (Matrix_name, Matrix_type)
	   Matrix_name is a string; Matrix_type is one of the
	   following:
	   'PFM' (raw position frequency matrix),
	   'ICM' (information content matrix) or
	   'PWM' (position weight matrix)
	   If Matrix_type is omitted, a PWM is retrieved by default.
 Warning : According to the current JASPAR2 data model, name is
	   not necessarily a unique identifier. In the case where
	   there are several matrices with the same name in the
	   database, the function fetches the first one and prints
	   a warning on STDERR. You have been warned.

=cut

sub get_Matrix_by_name {  
    my ($self, $name, $mt) = @_;
    my $ID=$self->{_idlist_of_name}->{$name}->[0] 
	    or return undef;
    if ((my $L= scalar @{ $self->{_idlist_of_name}->{$name} }) > 1)  {
        $self->warn("There are $L matrices with name '$name'");
    }
    return $self->get_Matrix_by_ID($ID, $mt);
}

sub get_matrix {
    # an obsolete method - kept for the time being for backward compatibility

    my ($self, %args) = @_;
    my $DIR = $self->{dir};
    my $ID;
    # retrieval from .pwm files in a directory
    my $mt = ($self->_get_matrixtype_from_args(%args)
	or $self->throw("No -matrixtype provided."));
    
    if ($args{-ID}) { 
	$ID = $args{-ID}; 
    }
	elsif (my $name = $args{-name}) { 
	$ID=$self->{_idlist_of_name}->{$name}->[0] 
	    or $self->warn("No matrix with name $name found.");
	if ((my $L= scalar @{ $self->{_idlist_of_name}->{$name} }) > 1)  {
	    $self->warn("There are $L matrices with name '$name'");
	}
    }
    else  {
	$self->throw("No -ID or -name passed to ".ref($self));
    }
	
    my $matrixobj;
    {
	no strict 'refs';
	my $ucmt = uc $mt;
	my $matrixstring =`cat $DIR/$ID.$mt`;

	eval("\$matrixobj= TFBS::Matrix::$ucmt->new".' 
	    ( -ID    => $ID,
	      -name  => $self->{_item}->{$ID}->{name},
	      -class => $self->{_item}->{$ID}->{class},
	      -matrix=> $matrixstring   # FIXME - temporary
	      );');
	if ($@) {$self->throw($@); }
    }
    # print "MATRIXOBJ: $matrixobj\n";
    return $matrixobj;
}

=head2 store_Matrix

 Title   : store_Matrix
 Usage   : $db->store_Matrix($matrixobj);
 Function: Stores the contents of a TFBS::Matrix::DB object in the database
 Returns : 0 on success; $@ contents on failure
	   (this is too C-like and may change in future versions)
 Args    : ($matrixobj) # a TFBS::Matrix::* object

=cut


sub store_Matrix  {
    my ($self, $matrixobj) = @_;
    my ($mt) = ($matrixobj =~ /TFBS::Matrix::(\w+)/)
	or $self->throw("Wrong type of object passed to store_Matrix.");
    if (defined $self->{_item}->{$matrixobj->ID()})  {
	$self->throw("ID ".$matrixobj->ID()." exists in the database.");
    }
    else  {
	my $matrixfile = $self->{dir}."/".$matrixobj->ID().".".lc($mt);
	open FILE, ">$matrixfile"
	    or $self->throw("Could not write file $matrixfile.");
	print FILE $matrixobj->rawprint;
	close FILE;
	my $ic = ($mt eq "ICM") ? $matrixobj->total_ic :
		    ($mt eq "PFM") ? $matrixobj->to_ICM->total_ic : ""; 
	$self->{_item}->{$matrixobj->ID()} = { 'name' => $matrixobj->name || "",
					       'ic'   => $ic,
					       'class'=> $matrixobj->class || "" };
	
	my %tags= $matrixobj->all_tags();
	foreach my $named_tag (keys %tags){
	    if ( ref $tags{$named_tag} eq "ARRAY"){
		my $val= join (",",@{$tags{$named_tag}});
		$tags{$named_tag}=$val;
	    }
	    
	    $self->{_item}->{$matrixobj->ID()}{'tag'}{$named_tag}=$tags{$named_tag}; 
           # print $named_tag , " ", $self->{_item}->{$matrixobj->ID()}{'tag'}{$named_tag}, "\n";

	}
	
	$self->_update_db_index();
    }
    return 0;

}

=head2 delete_Matrix_having_ID

 Title   : delete_Matrix_having_ID
 Usage   : $db->delete_Matrix_with_ID('M00045');
 Function: Deletes the matrix having the given ID from the database
 Returns : 0 on success; $@ contents on failure
	   (this is too C-like and may change in future versions)
 Args    : (ID)
	   A string
 Comment : Yeah, yeah, 'delete_Matrix_having_ID' is a stupid name
	   for a method, but at least it should be obviuos what it does.

=cut


sub delete_Matrix_having_ID  {
    my ($self, $ID) = @_;
    my $DIR = $self->{dir};
    unlink <$DIR/$ID.*>;
    delete $self->{_item}->{$ID};
    $self->_update_db_index();
}


sub _update_db_index  {
    my $self = shift;
    rename $self->{dir}."/matrix_list.txt", $self->{dir}."/~matrix_list.txt";
    open FILE, ">".$self->{dir}."/matrix_list.txt";
    foreach my $ID ( keys %{$self->{_item}} ) {
	print FILE join("\t", 	$ID,
				$self->{_item}->{$ID}->{ic},
				$self->{_item}->{$ID}->{name},
				$self->{_item}->{$ID}->{class}
			)."\t";
#   add tagged annotation	
#  my %tag = $self->{_item}->{$ID}->{'all_tags'};
     foreach my $name(sort keys %{$self->{'_item'}->{$ID}{'tag'}}){
         
         print FILE "; ", $name, " \"", $self->{'_item'}->{$ID}{'tag'}{$name}, "\"\ ";
         
     }
     
    
     
     
     
print FILE "\n";


	
    }
    close FILE;
}

sub _load_db_index  {
    my ($self, $field, $value) = @_;
    my $DIR = $self->{dir};
    open (MATRIXLIST, "$DIR/matrix_list.txt")
	or $self->throw("Could not read matrix list $DIR/matrix_list.txt");
    while (my $line = <MATRIXLIST>)  {
	chomp $line;
	my ($ID, $ic, $name, $class) = split /\s+/, $line, 4;
	if ($ID =~ /(\w+)\.(\w+)$/) {
	    $ID = $1;
	}
	
	defined($self->{_item}->{$ID}) 
	    and $self->warn("Duplicate entries for ID $ID");
	$self->{_item}->{$ID} = {name=>$name, ic=>$ic, class=>$class};
	push @{ $self->{_idlist_of_name}->{$name} }, $ID;
	push @{ $self->{_idlist_of_class}->{$class} }, $ID;
	# annoatation
	
	my @anno= split(/\s?;\s?/, $line);
	my %tags;
        shift @anno;
	foreach (@anno){
            my ($name, $val)=split(/\s?\"/, $_);
	  #  print "$name $val\n";
	    $self->{_item}->{$ID}->{'tags'}->{$name}=$val;
	  
	}
	
	
	
    }
    close MATRIXLIST;
    return scalar keys %{ $self->{_item} };  # false if list empty
}


sub get_MatrixSet  {
    my ($self, %args) = @_;
    my $DIR = $self->{db};
    my $arrayref;
    my $mt = $self->_check_matrixtype($args{-matrixtype})
	|| $self->throw("No matrix type provided.");
    delete $args{'-matrixtype'};
    my ($field, $value) = %args;
    unless (defined $field)  {
	$field="-IDs";
	$arrayref = [ keys %{ $self->{_item}} ];
    }
    my @IDlist;
    if ($field eq "-IDs") {
	@IDlist = @$arrayref;
    }
    elsif ($field eq "-names")  {
	foreach (@$arrayref)  {
	    push @IDlist, @{ $self->{_idlist_of_name}->{$_} };
	}
    }
    elsif ($field eq "-classes")  {
	foreach (@$arrayref)  {
	    push @IDlist, @{ $self->{_idlist_of_class}->{$_} };
	}
    }
    else  {
	$self->throw("Unknown matrixset selector: $field.");
    }
    my $matrixset = TFBS::MatrixSet->new();
    foreach my $ID(@IDlist)  {
	$matrixset->add_matrix($self->get_Matrix_by_ID($ID, $mt));
    }
    close MATRIXLIST;
    return $matrixset;
}


sub _check_matrixtype  {
    my ($self, $mt) = @_;
    $mt = uc $mt;
    return undef unless $mt;
    unless ( $mt eq "PFM"
	    or $mt eq "ICM"
	    or $mt eq "PWM")  {
	    $self->throw("Unsupported matrix type: ".$mt);
    }
    
    return $mt;
}

sub _read_file  {
    my ($self, $id, $mt) = @_;
    local $/ = undef;
    open FILE, $self->{dir}."/$id.".lc($mt) or return undef;
    my $matrixstring = <FILE>; #slurp;
    close FILE;
    return $matrixstring;
}

1;
