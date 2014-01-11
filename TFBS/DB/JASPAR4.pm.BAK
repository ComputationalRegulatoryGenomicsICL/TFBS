# TFBS module for TFBS::DB::JASPAR4
#
# Copyright Boris Lenhard
# 
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::DB::JASPAR4 - interface to MySQL relational database of pattern matrices


=head1 SYNOPSIS

=over 4

=item * creating a database object by connecting to the existing JASPAR2-type database

    my $db = TFBS::DB::JASPAR4->connect("dbi:mysql:JASPAR4:myhost",
					"myusername",
					"mypassword");

=item * retrieving a TFBS::Matrix::* object from the database

    # retrieving a PFM by ID
    my $pfm = $db->get_Matrix_by_ID('M0079','PFM');
 
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
    # derived from human genes:
    my $matrixset = $db->get_MatrixSet(-species => ['Homo sapiens'],
				       -matrixtype => "PFM");

=item * creating a new JASPAR4-type database named MYJASPAR4:
 
    my $db = TFBS::DB::JASPAR4->create("dbi:mysql:MYJASPAR4:myhost",
				       "myusername",
				       "mypassword");

=item * storing a matrix in the database (currently only PFMs):

    #let $pfm is a TFBS::Matrix::PFM object
    $db->store_Matrix($pfm);



=back

=head1 DESCRIPTION

TFBS::DB::JASPAR4 is a read/write database interface module that
retrieves and stores TFBS::Matrix::* and TFBS::MatrixSet
objects in a relational database. The interface is nearly identical
to the JASPAR2interface, while the underlying data model is different


=head1 JASPAR2 DATA MODEL

JASPAR4 is working name for a relational database model used
for storing transcriptional factor pattern matrices in a MySQL database.
It was initially designed (JASPAR2) to store matrices for the JASPAR database of
high quality eukaryotic transcription factor specificity profiles by
Albin Sandelin and Wyeth W. Wasserman. Besides the profile matrix itself,
this data model stores profile ID (unique), name, structural class,
basic taxonomic and bibliographic information
as well as some additional opseqdbtional tags.


Tags that are commonly used in the actual JASPAR database include
    'medline'  # PubMed ID
    'species'  # Species name
    'superclass' #Species supergroup, eg 'vertebrate', 'plant' etc
    'total_ic' # total information content - redundant, present 
               # for historical
    'type'    #experimental nethod
    'acc'    #accession number for TF protein sequence
    'seqdb'    #corresponding database name
    
but any tag is storable and searchable.
    
    


-----------------------  ADVANCED  ---------------------------------

For the developers and the curious, here is the JASPAR4 data model:

  

It is our best intention to hide the details of this data model, which we 
are using on a daily basis in our work, from most TFBS users.
Most users should only know the methods to store the data and 
which tags are supported.

-------------------------------------------------------------------------


=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut


# The code begins HERE:



package TFBS::DB::JASPAR4;
use vars qw(@ISA $AUTOLOAD);

# we need all three matrices due to the redundancy in JASPAR2 data model
# which will hopefully be removed in JASPAR3

use TFBS::Matrix::PWM;
use TFBS::Matrix::PFM;
use TFBS::Matrix::ICM;

use TFBS::MatrixSet;
use Bio::Root::Root;
use DBI;
# use TFBS::DB; # eventually
use strict;

@ISA = qw(TFBS::DB Bio::Root::Root);

#########################################################################
# CONSTANTS
#########################################################################

use constant DEFAULT_CONNECTSTRING => "dbi:mysql:JASPAR_DEMO"; # on localhost
use constant DEFAULT_USER          => "";
use constant DEFAULT_PASSWORD      => "";

#########################################################################
# PUBLIC METHODS
#########################################################################

=head2 new

 Title   : new
 Usage   : DEPRECATED - for backward compatibility only
           Use connect() or create() instead

=cut

sub new  {
  _new (@_);
}


=head2 connect

 Title   : connect
 Usage   : my $db =
	    TFBS::DB::JASPAR4->connect("dbi:mysql:DATABASENAME:HOSTNAME",
					"USERNAME",
					"PASSWORD");
 Function: connects to the existing JASPAR4-type database and
	   returns a database object that interfaces the database
 Returns : a TFBS::DB::JASPAR4 object
 Args    : a standard database connection triplet
	   ("dbi:mysql:DATABASENAME:HOSTNAME",  "USERNAME", "PASSWORD")
	   In place of DATABASENAME, HOSTNAME, USERNAME and PASSWORD,
	   use the actual values. PASSWORD and USERNAME might be
	   optional, depending on the user's acces permissions for
	   the database server.

=cut

sub connect  {
    # a more intuitive syntax for the constructor
    my ($caller, @connection_args) = @_;
    $caller->new(-connect => \@connection_args);
}


=head2 dbh

 Title   : dbh
 Usage   : my $dbh = $db->dbh();
	   $dbh->do("UPDATE matrix_data SET name='ADD1' WHERE NAME='SREBP2'");
 Function: returns the DBI database handle of the MySQL database
	   interfaced by $db; THIS IS USED FOR WRITING NEW METHODS
	   FOR DIRECT RELATIONAL DATABASE MANIPULATION - if you
	   have write access AND do not know what you are doing,
	   you can severely  corrupt the data
	   For documentation about database handle methods, see L<DBI>
 Returns : the database (DBI) handle of the MySQL JASPAR2-type
	   relational database associated with the TFBS::DB::JASPAR2
	   object
 Args    : none

=cut

sub dbh  {
    my ($self, $dbh) = @_;
    $self->{'dbh'} = $dbh if $dbh;
    return $self->{'dbh'};
}






=head2 store_Matrix

 Title   : store_Matrix
 Usage   : $db->store_Matrix($matrixobject);
 Function: Stores the contents of a TFBS::Matrix::DB object in the database
 Returns : 0 on success; $@ contents on failure
	   (this is too C-like and may change in future versions)
 Args    : (PFM_object)
	   A TFBS::Matrix::PFM, FBS::Matrix::PWM or FBS::Matrix::ICM object.
	   PFM object are recommended to use, as they are eaily converted to
	   other formats
 Comment : this is an experimental method that is not 100% bulletproof;
	   use at your own risk

=cut


sub store_Matrix {
    my ($self, @PFMs) = @_;
    my $err;
    foreach my $pfm (@PFMs)  {
	eval {
	    $self->_store_matrix_data($pfm);
	    $self->_store_matrix_info($pfm);
	    $self->_store_matrix_annotation($pfm);
	    #$self->_store_matrix_species($pfm);
	};
    }
    return $@;
}


sub create {
    my ($caller, $connectstring, $user, $password) = @_;
    if ($connectstring 
	and $connectstring =~ /dbi:mysql:(\w+)(.*)/)  
    {
	# connect to the server;
	my $dbh=DBI->connect("dbi:mysql:mysql".$2,
			     $user,$password)
	    or die("Error connecting to the database"); 

	# create database and open it
	$dbh->do("create database $1") 
	    or die("Error creating database.");
	$dbh->do("use $1"); 
	
	# create tables
	_create_tables($dbh);

	$dbh->disconnect;

	# run "new" with new database

	return $caller->new(-connect=>[$connectstring, $user, $password]);
    }
    else  {
	die("Missing or malformed connect string for ".
		     "TFBS::DB::JASPAR2 connection."); 
    }
}


=head2 get_Matrix_by_ID

 Title   : get_Matrix_by_ID
 Usage   : my $pfm = $db->get_Matrix_by_ID('M00034', 'PFM');
 Function: fetches matrix data under the given ID from the
           database and returns a TFBS::Matrix::* object
 Returns : a TFBS::Matrix::* object; the exact type of the
	   object depending on what form the matrix is stored
	   in the database (PFM is default)
 Args    : (Matrix_ID)
	   Matrix_ID is a string; 

=cut


sub get_Matrix_by_ID {

    my ($self, $ID, $mt) = @_;
    $mt = (uc($mt) or "PWM");

    unless (defined $ID) {
	$self->throw("No ID passed to get_Matrix_by_ID");
    }
    my $matrixobj;
    {
	no strict 'refs';
	my $ucmt = uc $mt;
	my $matrixstring = $self->_get_matrixstring($ID) || return undef;
        # get type of matrix
        my $sth=$self->dbh->prepare(qq{SELECT type FROM MATRIX_INFO WHERE ID = '$ID'});
        $sth->execute();
        my $type=$sth->fetchrow_array(); 
	
	
	# get reast of annotation as tags
        $sth=$self->dbh->prepare(qq{SELECT tag, val FROM MATRIX_ANNOTATION WHERE ID = '$ID' });
        $sth->execute();
        my %tags;
        while ( my($tag, $val)= $sth->fetchrow_array()){
            $tags{$tag}=$val;
        }
	my $name= $tags{'name'};
        my $class= $tags{'class'};                    
	delete   ($tags{'name'});
	delete ($tags{'class'});
	
    	eval ("\$matrixobj= TFBS::Matrix::$type->new".' 
	    ( -ID    => $ID."",
            -name =>$name, 
	    -class => $class,
              -tags  => \%tags,
	     -matrixstring=> $matrixstring   # FIXME - temporary
            );');
	#if ($@) {$self->throw($@); }
	
    
    #print "ref:",ref ($matrixobj);



    }

   # print $matrixobj->ID();
  #  print "here\n";print $matrixobj->prettyprint();
    return ($matrixobj);
}


=head2 get_Matrix_by_name

 Title   : get_Matrix_by_name
 Usage   : my $pfm = $db->get_Matrix_by_name('HNF-1');
 Function: fetches matrix data under the given name from the
	   database and returns a TFBS::Matrix::* object
 Returns : a TFBS::Matrix::* object; the exact type of the object
	   depending on what form the matrix object was stored in
	   the database (default PFM))
 Args    : (Matrix_name)
	   
 Warning : According to the current JASPAR4 data model, name is
	   not necessarily a unique identifier. In the case where
	   there are several matrices with the same name in the
	   database, the function fetches the first one and prints
	   a warning on STDERR. You've been warned.

=cut



sub get_Matrix_by_name {
    my ($self, $name, $mt) = @_;
    unless(defined $name) { 
	$self->throw("No name passed to get_Matrix_by_name."); }

    my @IDlist = $self->_get_IDlist_by_query(-name=>[$name]);
    my $ID= ($IDlist[0] 
	    or $self->warn("No matrix with name $name found."));
    if ((my $L= scalar @IDlist) > 1)  {
	$self->warn("There are $L matrices with name '$name'");
    }
    return $self->get_Matrix_by_ID($ID);
}


=head2 get_MatrixSet

 Title   : get_MatrixSet
 Usage   : my $matrixset = $db->get_MatrixSet(%args);
 Function: fetches matrix data under for all matrices in the database
	   matching criteria defined by the named arguments
	   and returns a TFBS::MatrixSet object
 Returns : a TFBS::MatrixSet object
 Args    : This method accepts named arguments, corresponding to arbitrary tags.
           Note that this is different from JASPAR2. As any tag is supported for
           database storage, any tag can be used for information retrieval.
           Additionally, arguments as 'name' and 'class' can be used (even though
           they are not tags.
           As with get_Matrix methods, it is important to realize taht any matrix
           format can be stored in the database: the TFBS::MatrixSet might therefore
           consist of PFMs, ICMs and PWMS, depending on how matrices are stored,
           
           Examples include
	   -ID        # a reference to an array of IDs (strings)
	   -name      # a reference to an array of
		       #  transcription factor names (string)
	   -class    # a reference to an array of
		       #  structural class names (strings)
	   -species    # a reference to an array of
		       #   Latin species names (strings)
	   -sysgroup  # a reference to an array of
		       #  higher taxonomic categories (strings)

	  
	   -min_ic     # float, minimum total information content
		       #   of the matrix. IMPORTANT:if retrieved matrices are in PWM
		       format there is no way to measureinformation content.
	-matrixtype    #string describing type of matrix to retrieve. If left out, the format
                        will revert to the database format. Note that this option only works
                      if the database format is pfm

The arguments that expect list references are used in database
query formulation: elements within lists are combined with 'OR'
operators, and the lists of different types with 'AND'. For example,

    my $matrixset = $db->(-class => ['TRP_CLUSTER', 'FORKHEAD'],
			  -species => ['Homo sapiens', 'Mus musculus'],
			  );

gives a set of TFBS::Matrix::PFM objects (given that the matrix models are stored as such)
 whose (structural clas is 'TRP_CLUSTER' OR'FORKHEAD') AND (the species they are derived
 from is 'Homo sapiens'OR 'Mus musculus').

The -min_ic filter is applied after the query in the sense that the
matrices profiles with total infromation content less than specified
are not included in the set.

=cut


sub get_MatrixSet  {
    my ($self, %args) = @_;
    
    
    
    my @IDlist = $self->_get_IDlist_by_query(%args);
    my $type;
    my $matrixset = TFBS::MatrixSet->new();
    
    foreach (@IDlist)  {
       # print "$_\n";
    }
    
    foreach (@IDlist)  {
	#next if (defined $args{'-min_ic'} 
	#	 and $_->_get_total_ic($_) < $args{'-min_ic'});
            #evaluate total information content: ivolves actually retrieving matrix
            # is actually a problem if matrix is stored PWM: thro an error if so
	
	my $matrix=$self->get_Matrix_by_ID($_);
	#evaluate
	#ugly code:
	if (defined $args{'-min_ic'} ){
            if ($matrix->isa("TFBS::Matrix::PFM")){
                next if ( $matrix->to_ICM->total_ic() < $args{'-min_ic'});     
            }
            if ($matrix->isa("TFBS::Matrix::ICM")){
                next if ($matrix->total_ic() < $args{'-min_ic'});     
            }
            if ($matrix->isa("TFBS::Matrix::PWM")){
                $self->throw("Cannot evaluate information constent from PWM matrices");
            }
	
	
        
        
	}
	#ugly code:

        if ($args{'-matrixtype'} && $matrix->isa("TFBS::Matrix::PFM")){
            if (      $args{'-matrixtype'} eq ('PWM')) {
               # warn "change";
                $matrix= $matrix->to_PWM();
        }
	if (      $args{'-matrixtype'} eq ('ICM')) {
                #warn "change";
                $matrix= $matrix->to_PWM();
        }
    }
	
	
        $matrixset->add_Matrix($matrix);
    }
    return $matrixset;
}



sub store_MatrixSet {
    $_[0]->throw ("Method store_MtrixSet not yet implemented.");
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
    my ($self, @IDs) = @_;
    eval  {
	foreach my $ID (@IDs) {
	    my $q_ID = $self->dbh->quote($ID);
	    foreach my $table (qw  (MATRIX_DATA
				    MATRIX_INFO
				    MATRIX_ANNOTATION
				    )
				)
	    {
		$self->dbh->do("DELETE from $table where ID=$q_ID");
	    }
	}
    };
    return $@;
    
}



#########################################################################
# PRIVATE METHODS
#########################################################################


sub _new  {
    my ($caller, %args)  = @_;
    my $class = ref $caller || $caller;
    my $self = bless {}, $class;

    my ($connectstring, $user, $password);
 
    if ($args{'-connect'} and (ref($args{'-connect'}) eq "ARRAY"))  {
	($connectstring, $user, $password) = @{$args{'-connect'}};
    }
    elsif ($args{'-create'} and (ref($args{'-create'}) eq "ARRAY"))  {
	return $caller->create(@{-args{'create'}});
    }
    else  {
	($connectstring, $user, $password) = 
	    (DEFAULT_CONNECTSTRING, DEFAULT_USER, DEFAULT_PASSWORD);
    }

    $self->dbh( DBI->connect($connectstring, $user, $password) );
    
    return $self;
}


sub _store_matrix_data  {
    my ($self, $pfm, $ACTION) = @_;
    my @base = qw(A C G T);
    my $matrix = $pfm->matrix();
    my $type;
    my $sth = $self->dbh->prepare 
	(q! INSERT INTO MATRIX_DATA VALUES(?,?,?,?) !);
				 
    for my $i (0..3)  {
	for my $j (0..($pfm->length-1)) {
	    $sth->execute( $pfm->ID,
			   
			   $base[$i],
			   $j+1,
			   $matrix->[$i][$j]
	    )
	   or $self->throw("Error executing query.");
	}
    }
    
}


sub _store_matrix_info  {

    my ($self, $pfm, $ACTION) = @_;

    my $type;
    $type= 'PFM' if $pfm->isa("TFBS::Matrix::PFM");
    $type= 'PWM' if $pfm->isa("TFBS::Matrix::PWM");
    $type= 'ICM' if $pfm->isa("TFBS::Matrix::ICM");


    my $sth = $self->dbh->prepare 
	(q! INSERT INTO MATRIX_INFO
	    (ID, type) 
	    VALUES(?,?) !);
    $sth->execute($pfm->ID,
		  $type, 
		  )
	or $self->throw("Error executing query");
}






sub _store_matrix_annotation  {
    my ($self, $pfm, $ACTION) = @_;
    my $sth = $self->dbh->prepare 
	(q! INSERT INTO MATRIX_ANNOTATION
	    (ID, tag, val) 
	    VALUES(?,?,?) !);
    
    $sth->execute($pfm->ID,
                    'name',
                    ($pfm->name() or ""),
    );
    $sth->execute($pfm->ID,
                    'class',
                    ($pfm->class() or ""),
    );
    
    # get all tags	
	
    my %tags= $pfm->all_tags();
    foreach my $tag( keys %tags){
    $sth->execute($pfm->ID,
                    $tag, 
                   ($tags{$tag} or ""),
                 )
    
	or $self->throw("Error executing query");
    }	
}







#when creating: try to support arbitrary tags

sub _create_tables {
    # utility function

    # If you want to change the databse schema,
    # this is the right place to do it

    my $dbh = shift;

    my @queries = 
	(
       q!
        CREATE TABLE MATRIX_DATA(
	ID VARCHAR (16) DEFAULT '' NOT NULL,
	row VARCHAR(1) NOT NULL, 
	col TINYINT(3) UNSIGNED NOT NULL, 
	val FLOAT, 
	PRIMARY KEY (ID, row, col)
	)
       !,
       q!
       CREATE TABLE MATRIX_INFO( 
	ID VARCHAR (16) DEFAULT '' NOT NULL PRIMARY KEY , 
 	type ENUM ('PFM', 'ICM','PWM') DEFAULT 'PFM' NOT NULL 
	)
       !,
       
       q!
        CREATE TABLE MATRIX_ANNOTATION(
        ID VARCHAR (16) DEFAULT '' NOT NULL,
	tag VARCHAR(255) DEFAULT '' NOT NULL,
	val TEXT,
	PRIMARY KEY (ID, tag)
	)
        !,
        
    );
    foreach my $query (@queries)  {
	$dbh->do($query) 
	    or die("Error executing the query: $query\n");
    }
}



sub _get_matrixstring  {
    my ($self, $ID) = @_;
    #my %dbname = (PWM => 'pwm', PFM => 'raw', ICM => 'info');
    #unless (defined $dbname{$mt})  {
	#$self->throw("Unsupported matrix type: ".$mt);
    #}
    my $sth;
    my $qID = $self->dbh->quote($ID);
    my $matrixstring = "";
    foreach my $base (qw(A C G T)) {
	$sth=$self->dbh->prepare
	    ("SELECT val FROM MATRIX_DATA 
              WHERE ID=$qID AND row='$base' ORDER BY col");
	$sth->execute;
	$matrixstring .=
	    join (" ", (map {$_->[0]} @{$sth->fetchall_arrayref()}))."\n";
    }
    $sth->finish;
    return undef if $matrixstring eq "\n"x4;

    return $matrixstring;
}





sub _get_IDlist_by_query  {

    # called by get_MatrixSet
    # should be able to search for arbitrary tags...hmmm
    my ($self, %args) = @_;
    my ($TABLES, %arrayref);
    my (%intersected_set);
    

    foreach my $key(keys %args){
       
        unless ( $key eq "-min_ic" or $key eq  "-matrixtype"){
                my $oldkey=$key;
                $key=~s/-//;
                $arrayref{$key}= $args{$oldkey};
        }
    }
    my @andconditions;
    
      
    $TABLES = 'MATRIX_ANNOTATION ';
    
    #special case: get all matrices
    unless (keys %arrayref){
       
            
        
     my $query = "SELECT DISTINCT ID FROM $TABLES ";
        
     my $sth = $self->dbh->prepare($query);
     $sth->execute() or $self->throw("Query failed:\n$query\n");
     my @ary;
     
     while (my ($id) = $sth->fetchrow_array())  {
           push (@ary, $id);
            
        }   
    
        return(@ary);
    
    }
    
    
    
    
    
    foreach my $key (keys %arrayref)  {
        #print "key: $key\n";
        if ($key eq 'ID'){
         push @andconditions,
	"(".
	join(" OR ",
	     (map {"MATRIX_ANNOTATION.ID=".
		       $self->dbh->quote($_)
		  } 
	      @{$arrayref{$key}}
	     )).
	")";   
            
            
            
        }
        else{
        push @andconditions,
	"(".
	join(" OR ",
	     (map {"MATRIX_ANNOTATION.tag=". $self->dbh->quote($key)." AND val=".
		       $self->dbh->quote($_)
		  } 
	      @{$arrayref{$key}}
	     )).
	")";
        }
        push (@andconditions, 1) unless(@andconditions);
        my $WHERE = ((scalar @andconditions) == 0) ? "" : " WHERE ";

     
      
    my $query = 
	    "SELECT DISTINCT ID FROM $TABLES $WHERE".
	    join(" AND ", @andconditions);
   
       # warn  $query; 
        undef @andconditions;
        my $sth = $self->dbh->prepare($query);
        $sth->execute() or $self->throw("Query failed:\n$query\n");
    
        # collect IDs and return

        my %current_query;
        while (my ($id) = $sth->fetchrow_array())  {
           $current_query{$id}=1;
            
        }
        unless (%intersected_set){
            %intersected_set= %current_query;
            next;
        }
        # do intersect
        foreach my $key (keys %intersected_set){
              delete $intersected_set{ $key}  unless $current_query{$key};
            
        }
    } 
    
    my @ary;
    foreach my $key (keys %intersected_set){
        push (@ary, $key);
       # warn "$key\n";
    }
    return (@ary);
    
    
}

sub DESTROY  {
    $_[0]->dbh->disconnect() if $_[0]->dbh;
}



