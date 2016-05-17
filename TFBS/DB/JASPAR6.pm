# TFBS module for TFBS::DB::JASPAR6
# 
# Copyright Boris Lenhard
# Maintainer Xiaobei Zhao
# 
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::DB::JASPAR6 - interface to MySQL relational database of pattern matrices. Currently status: experimental.


=head1 SYNOPSIS

=over 4

=item * creating a database object by connecting to the existing JASPAR6-type database

    my $db = TFBS::DB::JASPAR6->connect("dbi:mysql:JASPAR6:myhost",
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
     @namelist = ('p50', 'p53', 'HNF-1'. 'GATA-1', 'GATA-2', 'GATA-3');
    my $matrixset = $db->get_MatrixSet(-names => \@namelist,
				       -matrixtype => "ICM");
 
    

=item * creating a new JASPAR6-type database named MYJASPAR6:
 
    my $db = TFBS::DB::JASPAR4->create("dbi:mysql:MYJASPAR6:myhost",
				       "myusername",
				       "mypassword");

=item * storing a matrix in the database (currently only PFMs):

    #let $pfm is a TFBS::Matrix::PFM object
    $db->store_Matrix($pfm);



=back

=head1 DESCRIPTION

TFBS::DB::JASPAR6 is a read/write database interface module that
retrieves and stores TFBS::Matrix::* and TFBS::MatrixSet
objects in a relational database. The interface is nearly identical
to the JASPAR2 and JASPAR4 interface, while the underlying data model is different


=head1 JASPAR6 DATA MODEL

JASPAR6 is working name for a relational database model used
for storing transcriptional factor pattern matrices in a MySQL database.
It was initially designed (JASPAR2) to store matrices for the JASPAR database of
high quality eukaryotic transcription factor specificity profiles by
Albin Sandelin and Wyeth W. Wasserman. Besides the profile matrix itself,
this data model stores profile ID (unique), name, structural class,
basic taxonomic and bibliographic information
as well as some additional, and custom, tags.

Here goes a moore thorough description on tables and IDs
    
    


-----------------------  ADVANCED  ---------------------------------

For the developers and the curious, here is the JASPAR6 data model:

  

MISSING TEXT HEER ON HOW IT WORKS


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



package TFBS::DB::JASPAR6;
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
	    TFBS::DB::JASPAR6->connect("dbi:mysql:DATABASENAME:HOSTNAME",
					"USERNAME",
					"PASSWORD");
 Function: connects to the existing JASPAR6-type database and
	   returns a database object that interfaces the database
 Returns : a TFBS::DB::JASPAR6 object
 Args    : a standard database connection triplet
	   ("dbi:mysql:DATABASENAME:HOSTNAME",  "USERNAME", "PASSWORD")
	   In place of DATABASENAME, HOSTNAME, USERNAME and PASSWORD,
	   use the actual values. PASSWORD and USERNAME might be
	   optional, depending on the user's acces permissions for
	   the database server.

=cut

sub connect  { #DONE
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

sub dbh  { #DONE
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
    # might have to give version and collection here
 Comment : this is an experimental method that is not 100% bulletproof;
	   use at your own risk

=cut


sub store_Matrix { #PROBABLY DONE
   # collection, version are taken from the corresponding tags. Warn if they are not there  
    ;
    my ($self, @PFMs) = @_;
    my $err;
    foreach my $pfm (@PFMs)  {
	eval {
	   
	    my $int_id=  $self->_store_matrix($pfm); # needs to have collection and version
	    $self->_store_matrix_data($pfm, $int_id);
	    $self->_store_matrix_annotation($pfm, $int_id);
	    $self->_store_matrix_species($pfm, $int_id);
	    $self->_store_matrix_acc($pfm, $int_id);

	};
    }
    return $@;
}


sub create { #done
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
	   Matrix_ID id is a string which refers to the stable 
           JASPAR ID (usually something like "MA0001") with 
           or without version numbers. "MA0001" will give the 
           latest version on MA0001, while "MA0001.2" will give
           the second version, if existing. Warnings will be 
           given for non-existing matrices.

=cut


sub get_Matrix_by_ID { #DONE. MAYBE :)

    my ($self, $q, $mt) = @_; # q is a stable ID with possible version number

# jsp6
    $mt = (uc($mt) or "PFM");
    unless (defined $q) {
	$self->throw("No ID passed to get_Matrix_by_ID");
    }
    
    my $ucmt = uc $mt;
    # separate stable ID and version number
    my ($base_ID, $version)= split (/\./,  $q);
    $version=$self->_get_latest_version($base_ID) unless $version; # latest version per default
    
    # get internal ID - also a check for validity
    my $int_id= $self->_get_internal_id($base_ID, $version);
    
    
    # get matrix using internal ID
   
    my $m= $self->_get_Matrix_by_int_id($int_id, $ucmt);
    warn ref ($m);
   
    return ($m);
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
	   
 Warning : According to the current JASPAR6 data model, name is
	   not necessarily a unique identifier. Also, names change 
           over time. 
           In the case where
	   there are several matrices with the same name in the
	   database, the function fetches the first one and prints
	   a warning on STDERR. You've been warned.
           Some matrices have multiple versions. The function will 
           return the latest version. For specific versions, use 
           get_Matrix_by_ID($ID.$version)

=cut



sub get_Matrix_by_name { #DONE
    my ($self, $name, $mt) = @_;
    unless(defined $name) { 
	$self->throw("No name passed to get_Matrix_by_name."); }
    # sanity check: are there many different stable IDs with same name?
   


    my $sth=$self->dbh->prepare(qq!SELECT distinct BASE_ID  FROM MATRIX
				    WHERE NAME="$name"!);
    $sth->execute();
    my (@stable_ids)=$sth->fetchrow_array();
    my $L =scalar @stable_ids;
    $self->warn("There are $L distinct stable IDs with name '$name'") if scalar $L>1;
 
    return $self->get_Matrix_by_ID($stable_ids[0], $mt);
}


=head2 get_MatrixSet

 Title   : get_MatrixSet
 Usage   : my $matrixset = $db->get_MatrixSet(%args);
 Function: fetches matrix data under for all matrices in the database
	   matching criteria defined by the named arguments
	   and returns a TFBS::MatrixSet object
 Returns : a TFBS::MatrixSet object
 Args    : This method accepts named arguments, corresponding to arbitrary tags, and also some utility functions
           Note that this is different from JASPAR2 and to some extent JASPAR4. As any tag is supported for
           database storage, any tag can be used for information retrieval.
           Additionally, arguments as 'name','class','collection' can be used (even though
           they are not tags.
           Per default, only the last version of the matrix is given. The only way to get older matrices out of this 
           to use an array of IDs with actual versions like MA0001.1, or set the argyment -all_versions=>1, in which  case you get all versions for each stable ID
									       

									       
           
	  Examples include:
 Fundamental matrix features
	-all # gives absolutely all matrix entry, regardless of versin and collection. Only useful for backup situations and sanity checks. Takes precedence over everything else
		
        -ID        # a reference to an array of stable IDs (strings), with or without version, as above. tyically something like "MA0001.2" . Takes precedence over everything salve -all		
 -name      # a reference to an array of
		       #  transcription factor names (string). Will only take latest version. NOT a preferred way to access since names change over time
	   -collection # a string corresponding to a JASPAR collection. Per default CORE      
	   -all_versions # gives all matrix versions that fit with rest of criteria, including obsolete ones.Is off per default. 
			 # Typical usage is in combiation with a stable IDs withou versions to get all versinos of a particular matrix		
          Typical tag queries:
	These can be either a string or a reference to an array of strings. If it is an arrau it will be interpreted as as an "or"s statement								       
	   -class    # a reference to an array of
		       #  structural class names (strings)
	   -species    # a reference to an array of
		       #   NCBI Taxonomy IDs (integers)
	   -taxgroup  # a reference to an array of
		       #  higher taxonomic categories (string)
	   								       
Computed features of the matrices	  
	   -min_ic     # float, minimum total information content
		       #   of the matrix. 
	-matrixtype    #string describing type of matrix to retrieve. If left out, the format
                        will revert to the database format, which is PFM.

The arguments that expect list references are used in database
query formulation: elements within lists are combined with 'OR'
operators, and the lists of different types with 'AND'. For example,

    my $matrixset = $db->(-class => ['TRP_CLUSTER', 'FORKHEAD'],
			  -species => ['Homo sapiens', 'Mus musculus'],
			  );

gives a set of TFBS::Matrix::PFM objects (given that the matrix models are stored as such)
 whose (structural clas is 'TRP_CLUSTER' OR'FORKHEAD') AND (the species they are derived
 from is 'Homo sapiens'OR 'Mus musculus').

As above, unless IDs with version numbers are used, only one matrix per stable ID wil be returned: the matrix with the highest version number 

The -min_ic filter is applied after the query in the sense that the
matrices profiles with total information content less than specified
are not included in the set.



=cut


# jsp6
sub get_MatrixSet  { # IC conetent and matrix stuff is not there yet, rest should work
    my ($self, %args) = @_;

    #jsp6
    $args{'-collection'}='CORE' unless $args{'-collection'};
       
    $args{'-all_versions'}=0 unless $args{'-all_versions'};

    
    my @IDlist = @{$self->_get_IDlist_by_query(%args)}; # the IDlist here are INTERNAL ids
    

    my $type;
    my $matrixset = TFBS::MatrixSet->new();
    
    
    
    foreach my $int_id(@IDlist)  {


	my $matrix=$self->_get_Matrix_by_int_id($int_id);


	if (defined $args{'-min_ic'} ){
	    # we assume the matrix IS a PFM, o something in normal space at least
	    # unless it explicitly says otherwise in tag=matrixtype
	    # if so warn and do not use IC content
	    # this is not foolproof in any way
      #
      # Fixed up logic to actually check $matrix->isa(TFBS::Matrix::ICM)
      # before checking the matrixtype tag. Also check that matrixtype
      # tag is defined before comparison to prevent annoying "Use of
      # uninitialized value in string eq" messages from perl.
      # DJA 2012/05/11
      if ($matrix->isa("TFBS::Matrix::ICM")
        || (   defined $matrix->{tags}{matrixtype}
          && $matrix->{tags}{matrixtype} eq "ICM")){
        next if ( $matrix->total_ic() < $args{'-min_ic'});
      } elsif ($matrix->isa("TFBS::Matrix::PFM")){
        next if ( $matrix->to_ICM->total_ic() < $args{'-min_ic'});
      }
	    else{	
		warn "Warning: you are assessning information content on matrices that are not in PFM or ICM format.Skipping this criteria";
		next;
	    }


	}
       
	# length
	if (defined $args{'-length'} ){
	    next if ( $matrix->length() < $args{'-length'});     
	}


	# number of sites within
	# since column sums MIGHT be slightly different we take the integer of the mean of the columns
	# or really int( sum of matrix/#columns)
	if (defined $args{'-sites'} ){
	    my $sum=0;
	    foreach ( 1..$matrix->length){
		$sum+=$matrix->column_sum();
	    }
	    $sum=int($sum /$matrix->length);
	    warn $matrix->ID, " $sum is $sum"; 
	    next if ( $sum < $args{'-sites'});     
	}
	


	
	#ugly code: think about this a bit. 

        if ($args{'-matrixtype'} && $matrix->isa("TFBS::Matrix::PFM")){
            if (      $args{'-matrixtype'} eq ('PWM')) {
              
                $matrix= $matrix->to_PWM();
        }
	if (      $args{'-matrixtype'} eq ('ICM')) {
               
                $matrix= $matrix->to_PWM();
        }
	}
	
	
        $matrixset->add_Matrix($matrix);
    }
    return $matrixset;
}



sub store_MatrixSet { #DONE a wrapper around store_Matrix (which also can take an array of matrices, so utility only
      my ($self, $matrixset) = @_;
      my $it=$matrixset->Iterator();
      while (my $matrix_object = $it->next) {
	  # do whatever you want with individual matrix objects
	  $self->store_Matrix($matrix_object)
      }
      

  }

=head2 delete_Matrix_having_ID

 Title   : delete_Matrix_having_ID
 Usage   : $db->delete_Matrix_with_ID('M00045.1');
 Function: Deletes the matrix having the given ID from the database
 Returns : 0 on success; $@ contents on failure
	   (this is too C-ike and may change in future versions)
 Args    : (ID)
	   A string. Has to be a matrix ID with version suffix in JASPAR6.
 Comment : Yeah, yeah, 'delete_Matrix_having_ID' is a stupid name
	   for a method, but at least it should be obviuos what it does.

=cut


sub delete_Matrix_having_ID  {
    my ($self, @IDs) = @_;
    # this has to be versioned IDs
    foreach my $ID (@IDs){
       	my ($base_id, $version)= split (/\./, $ID);
	unless ($version) {
	    warn "You have supplied a non-versioned matrix ID to delete. Skipping $ID ";
		return 0;
	}
	# get relevant internal ID
	my($int_id)= $self->_get_internal_id($base_id, $version);
	
	eval  {
	    my $q_ID = $self->dbh->quote($int_id);
	    foreach my $table (qw  (MATRIX_DATA
				    MATRIX
				    MATRIX_SPECIES 
				    MATRIX_PROTEIN
				    MATRIX_ANNOTATION
				    )
			       )
	    {
		$self->dbh->do("DELETE from $table where ID=$q_ID");
	    }
	};
    }
    return $@;
    
}



#########################################################################
# PRIVATE METHODS
#########################################################################


sub _new  { #PROBABLY OK
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


sub _store_matrix_data  {# DONE
    my ($self, $pfm, $int_id,$ACTION) = @_;
    my @base = qw(A C G T);
    my $matrix = $pfm->matrix();
    my $type;
    my $sth = $self->dbh->prepare 
	(q! INSERT INTO MATRIX_DATA VALUES(?,?,?,?) !);
				 
    for my $i (0..3)  {
	for my $j (0..($pfm->length-1)) {
	    $sth->execute( $int_id,
			   
			   $base[$i],
			   $j+1,
			   $matrix->[$i][$j]
	    )
	   or $self->throw("Error executing query.");
	}
    }
    
}


sub _store_matrix  { #DONE
   
    my ($self, $pfm, $ACTION) = @_;
    # creation of the matrix will also give an internal unique ID (incremental int)
    # which will be returned to use for the other tables

    # Get collection and versio from the matrix tags
    my $version= $pfm->{'tags'}{'version'};
    # will warn but not die if version is missing: will assume 1
    unless ($version) {
	warn "WARNING: Lacking  version number for ". $pfm->ID. ". Setting version=1";
	$version=1;
	
    }
   
    my $collection= $pfm->{'tags'}{'collection'};
    unless ($collection) {
	warn "WARNING: Lacking  collection name for ". $pfm->ID. ". Setting collection to an empty string. You probably do not want this";
	$collection='';
    }
    # sanity check: do we alsready have this cobination of base ID and version? If we do, die
    my $base_id= $pfm->ID ;
    my $sth = $self->dbh->prepare 
	(qq! select count(*) from MATRIX where VERSION=$version and BASE_ID= "$base_id"and collection="$collection"  !);
    $sth->execute;
    my ($sanity_count)= $sth->fetchrow_array;
   
    if ($sanity_count >0){
      warn "WARNING: Database input inconsistency: You have already have $sanity_count $base_id matrices of version $version in collection $collection. Terminating program";
	die;
    }
    
   



    # insert data
   
	
    $sth = $self->dbh->prepare 
	(q! INSERT INTO MATRIX
	 VALUES(?,?,?,?,?) !);

    # update next sth with actual version and collection: DO
    $sth->execute(0, $collection,$pfm->ID,$version,$pfm->name) 
	or $self->throw("Error executing query");
    
    # get the actual (new) iternal ID

    my $int_id = $self->dbh->{ q{mysql_insertid}}; 
   
    return $int_id;

}






sub _store_matrix_annotation  { # DONE
    #this is for tag-value items that are not one-to-many (so, not species and not acc)
  
    my ($self, $pfm, $int_id,$ACTION) = @_;
    my $sth = $self->dbh->prepare 
	(q! INSERT INTO MATRIX_ANNOTATION
	    (ID, tag, val) 
	    VALUES(?,?,?) !);
    
   
   
    
    # get all tags
    # but skip out collection or version as we already have those in the MATRIX table
	
    #special handling for class which mighht have a true slot
   

  
    my %tags= $pfm->all_tags();
     if (defined ($pfm->{class})){
	 $tags{class}=$pfm->{class} ;
    }

    foreach my $tag( keys %tags){
        next if $tag eq "collection";
        next if $tag eq "version";
        next if $tag eq "species";
#       next if $tag eq "acc";
#   	next if $tag eq "class";
        $sth->execute($int_id,
                      $tag, 
                      ($tags{$tag} or ""),
            )
    
            or $self->throw("Error executing query");
    }	
}


sub _store_matrix_species  { # DONE
    #these are for species IDs - can be several
    # these are taken from the tag "species"
    # if that tag is a reference to an array we walk over the array
    # if it is a comma-separated string we split the string
    
    my ($self, $pfm, $int_id,$ACTION) = @_;
    my $sth = $self->dbh->prepare 
	(q! INSERT INTO MATRIX_SPECIES
	 VALUES(?,?) !);
 
    #sanity check: are there any species? Its ok not to have it. 
    return() unless $pfm->{'tags'}{'species'};
    #is the species a string or an arrayref?
    if ( ref ($pfm->{'tags'}{'species'}) eq 'ARRAY'){
	# walkthru array
	foreach my $species ( @{$pfm->{'tags'}{'species'}}){
	    $sth->execute($int_id,$species);
	}
    }
    else{
	# split and walk thru
	foreach my $species ( split(/\,/, $pfm->{'tags'}{'species'})){
	     $species=~s/^\s//g; 
	     $sth->execute($int_id,$species);
	}
	
    }
   
}

sub _store_matrix_acc  { # DONE
    #these are for protein accession numbers - can be several
    # these are taken from the tag "acc"
    # if that tag is a reference to an array we walk over the array
    # if it is a comma-separated string we split the string
    
    my ($self, $pfm, $int_id,$ACTION) = @_;
    my $sth = $self->dbh->prepare 
	(q! INSERT INTO MATRIX_PROTEIN
	 VALUES(?,?) !);
    
    #sanity check: are there any accession numbers? Its ok not to have it. 
    return() unless $pfm->{'tags'}{'acc'};
    
    #is the species a string or an arrayref?
    if ( ref ($pfm->{'tags'}{'acc'}) eq 'ARRAY'){
	# walkthru array
	foreach my $acc ( @{$pfm->{'tags'}{'acc'}}){
	    $acc=~s/\s//g; 
	    $sth->execute($int_id,$acc);
	}
    }
    else{
	# split and walk thru
	foreach my $acc ( split(/\,/, $pfm->{'tags'}{'acc'})){
	    $acc=~s/\s//g; 
	    $sth->execute($int_id,$acc);
	}
	
    }
   
}



#when creating: try to support arbitrary tags

sub _create_tables { # DONE 
    # utility function

    # If you want to change the databse schema,
    # this is the right place to do it

    my $dbh = shift;

    my @queries = 
	(
       q!
       CREATE TABLE MATRIX(
	ID INT NOT NULL AUTO_INCREMENT,
	COLLECTION VARCHAR (16) DEFAULT '',
	BASE_ID VARCHAR (16)DEFAULT '' NOT NULL ,
	VERSION TINYINT DEFAULT 1  NOT NULL ,
	NAME VARCHAR (255) DEFAULT '' NOT NULL,	
	PRIMARY KEY (ID))
       !,
       q!
      
	CREATE TABLE MATRIX_DATA(
	ID INT NOT NULL,
	row VARCHAR(1) NOT NULL, 
	col TINYINT(3) UNSIGNED NOT NULL, 
	val float(10,3), 
	PRIMARY KEY (ID, row, col)
	)
       !,
       q!
       CREATE TABLE MATRIX_ANNOTATION(
        ID INT NOT NULL,
	TAG VARCHAR(255)DEFAULT '' NOT NULL,
	VAL varchar(255) DEFAULT '',
	PRIMARY KEY (ID, TAG)
	)
	 !,
       q!
	 CREATE TABLE MATRIX_SPECIES(
        ID INT NOT NULL,
	TAX_ID VARCHAR(255)DEFAULT '' NOT NULL
)
        !,
       q!
	 CREATE TABLE MATRIX_PROTEIN(
	ID INT NOT NULL,
	ACC VARCHAR(255)DEFAULT '' NOT NULL
	)
        !  
    );
    foreach my $query (@queries)  {
	$dbh->do($query) 
	    or die("Error executing the query: $query\n");
    }
}



sub _get_matrixstring  { #DONE
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

sub _get_latest_version  { #DONE
    my ($self, $base_ID) = @_;
    # SELECT VERSION FROM MATRIX WHERE BASE_ID=? ORDER BY VERSION DESC LIMIT 1
    my $sth=$self->dbh->prepare
	    (qq!SELECT VERSION FROM MATRIX 
	     WHERE BASE_ID="$base_ID" 
	     ORDER BY VERSION DESC LIMIT 1!);
    $sth->execute;
    my ($latest)=$sth->fetchrow_array();
    return($latest);

}
sub _get_internal_id  { #DONE
    # picks out the internal id for a a stable id+ version. Also checks if this cobo exists or not
    my ($self, $base_ID, $version) = @_;
    # SELECT ID FROM MATRIX WHERE BASE_ID=? and VERSION=?
my $sth=$self->dbh->prepare
	    (qq!SELECT ID FROM MATRIX 
	     WHERE BASE_ID="$base_ID" AND VERSION="$version"!);
    $sth->execute;
 my ($int_id)=$sth->fetchrow_array();
    return($int_id);


}

sub _get_Matrix_by_int_id
{ #done
    my ($self, $int_id, $mt)= @_; 
    my $matrixobj;
    $mt='PFM' unless $mt;
    # get the matrix as a string
    my $matrixstring = $self->_get_matrixstring($int_id) || return undef;
    
    #get remaining data in the matrix table: name, collection
    my $sth=$self->dbh->prepare(qq!SELECT BASE_ID,VERSION,  COLLECTION,NAME FROM MATRIX WHERE ID="$int_id"!);
    $sth->execute();
    my ($base_ID, $version,$collection,$name)=$sth->fetchrow_array(); 
    


# jsp6
    # get species
    ##$sth=$self->dbh->prepare(qq!SELECT TAX_ID FROM MATRIX_SPECIES WHERE ID="$int_id"!);
    $sth=$self->dbh->prepare(qq!SELECT GROUP_CONCAT(TAX_ID SEPARATOR ', ') as TAX_ID FROM MATRIX_SPECIES WHERE ID="$int_id"!);
    $sth->execute();
    my @tax_ids;
    while (my ($res)=$sth->fetchrow_array())
	{
        my @res_v=split(/,/,$res);
        my @res_v2=grep(s/^\s*(.*)\s*$/\1/g, @res_v);
		push(@tax_ids, @res_v2); 
    }

# jsp6
    # get acc
    ##$sth=$self->dbh->prepare(qq!SELECT ACC FROM MATRIX_PROTEIN WHERE ID="$int_id"!);
    $sth=$self->dbh->prepare(qq!SELECT GROUP_CONCAT(ACC SEPARATOR ', ') as ACC FROM MATRIX_PROTEIN WHERE ID="$int_id"!);
    $sth->execute();
    my @accs;
    while (my ($res)=$sth->fetchrow_array())
	{
        my @res_v=split(/,/,$res);
        my @res_v2=grep(s/^\s*(.*)\s*$/\1/g, @res_v);
		push(@accs, @res_v2); 
    } 


# jsp6
    # get remaining annotation as tags, form ANNOTATION table
    my %tags;
    $sth=$self->dbh->prepare(qq{SELECT TAG, VAL FROM MATRIX_ANNOTATION WHERE ID = "$int_id" });
    $sth->execute();
    ## my @key_to_split=("acc", "medline", "pazar_tf_id"); #if acc in MATRIX_ANNOTATION
    my @key_to_split=("medline", "pazar_tf_id", "tfbs_shape_id", "tfe_id");
    #my @key_to_split=("medline", "pazar_tf_id");
    foreach my $key(@key_to_split){
        $tags{$key}=['-'];
    }
    #my @key_to_split=("medline");
    my $vals;
    while ( my($tag, $val)= $sth->fetchrow_array())
	{
        $vals=[];
        if ($tag ~~ @key_to_split){
            my @val_v=split(/,/,$val);
            my @val_v2=grep(s/^\s*(.*)\s*$/\1/g, @val_v);
            push(@$vals, @val_v2); 
            $tags{$tag}=$vals;
        }
        else {
            $tags{$tag}=$val;
        }
#       $tags{$tag}=$val;
    }

# jsp6
    $tags{'collection'}= $collection;
    $tags{'species'}=\@tax_ids; # as array reference instead of strigifying
    $tags{'acc'}=\@accs; # same, if acc MATRIX_PROTEIN
	
# 
    my $class= $tags{'class'};  
    delete ($tags{'class'});
	#	
    eval("\$matrixobj= TFBS::Matrix::PFM->new".' 
	    ( -ID    => "$base_ID.$version",
            -name =>$name, 
	    -class => $class,
            -tags  => \%tags,
	    -matrixstring=> $matrixstring   # FIXME - temporary
            );'
		);
    if ($@)
	{
		$self->throw($@);
	}
	# warn $int_id, "\t", ref($matrixobj);
    return ($matrixobj->to_PWM) if $mt eq "PWM";
    return ($matrixobj->to_ICM) if $mt eq "ICM";
    return ($matrixobj); # default PFM    
}


##jsp6
sub _get_IDlist_by_query
{ #needs  cleanup. NOT for the faint-hearted. 
    my ($self, %args)=@_;
        
    warn '_get_IDlist_by_query | $self || ', $self;
    warn '_get_IDlist_by_query | %args || ', %args;


    # called by get_MatrixSet
   	#  warn $args{"-collection"};

    $args{'-collection'}='CORE' unless $args{'-collection'};
   
	# returns a set of internal IDs with whicj to get the actual matrices   
    # current idea: 
    # 1: first catch non-tag things like collection, name and version, species
    # makw one query for these if they are named and check the IDs for "latest" unless requested not to.
    # these are AND statements
    # 2:then do the rest on tag level: 
    # to be able to do this  with actual and tattemnet innthe tag table, we do an inner join query, which is kept separate just for convenice
    # we then intersect 1 and 2
    # 3: then do matrix-based features such as ic, with, number of sites etc, for the surviving matrices. This shold happen in the get_matrixset part

    my @int_ids_to_return;


    ## jsp6 - autosearch
    if ($args{'-auto'})
	{
        ##my $sth=$self->dbh->prepare (qq!SELECT ID FROM MATRIX WHERE BASE_ID=?!);
        my $sth=$self->dbh->prepare (qq!SELECT U.ID FROM (SELECT ID, BASE_ID as VAL FROM MATRIX UNION ALL SELECT ID, NAME as VAL FROM MATRIX UNION ALL SELECT ID, ACC as VAL FROM MATRIX_PROTEIN UNION ALL SELECT ID, TAX_ID as VAL FROM MATRIX_SPECIES UNION ALL SELECT ID, SPECIES as VAL FROM MATRIX_SPECIES,TAX WHERE MATRIX_SPECIES.TAX_ID=TAX.TAX_ID UNION ALL SELECT ID, NAME as VAL FROM MATRIX_SPECIES,TAX_EXT WHERE MATRIX_SPECIES.TAX_ID=TAX_EXT.TAX_ID AND MATRIX_SPECIES.TAX_ID=9606 UNION ALL SELECT ID, VAL as VAL FROM MATRIX_ANNOTATION) AS U WHERE LOWER(`VAL`) LIKE LOWER(?)!);

        warn '_get_IDlist_by_query | $sth || ', $sth;

        foreach my $stID(@{$args{'-auto'}})
        {
            warn '_get_IDlist_by_query | $stID || ', $stID;
            my ($stable_ID, $version)= split (/\./, $stID); # ignore vesion here, this is a stupidity filter
            #$sth->execute($stable_ID);
            $sth->execute("%" . $stable_ID . "%");
            while( my ($int_id)=$sth->fetchrow_array())
            {
                warn '_get_IDlist_by_query | $int_id || ', $int_id;
                push (@int_ids_to_return, $int_id);		   
            }
        }
		return \@int_ids_to_return;
    }


    # should redo so that matrix_annotation queries are separate, with an intersect in the end 
    #special case 1: get ALL matrices. Higher priority than all

    if ($args{'-all'})
	{
		my $sth=$self->dbh->prepare (qq!SELECT ID FROM MATRIX!);
		$sth->execute();
		my @a;
		while (  my ($i)=$sth->fetchrow_array())
		{
			push (@a, $i);
		}  
		return \@a;
    }

    # ids: special case2 which is has higher priority than any other except the above (ignore all others
    if ($args{'-ID'})
	{
		# these might be either stable IDs or stableid.version.	
		# if just stable ID and if all_versions==1, take all versions, otherwise the latest
		if ( $args{-all_versions})
		{
			my $sth=$self->dbh->prepare (qq!SELECT ID FROM MATRIX WHERE BASE_ID=?!);
			foreach my $stID(@{$args{'-ID'}})
			{
				my ($stable_ID, $version)= split (/\./, $stID); # ignore vesion here, this is a stupidity filter
				$sth->execute($stable_ID);
				while( my ($int_id)=$sth->fetchrow_array())
				{
					push (@int_ids_to_return, $int_id);		   
				}
			}
		}
		else
		{ # only the lastest version, or the requested version
			foreach my $stID(@{$args{'-ID'}})
			{
				#warn $stID;
				my ($stable_ID, $version)= split (/\./, $stID);
				$version=$self->_get_latest_version($stable_ID) unless $version;
				my $int_id= $self->_get_internal_id($stable_ID, $version);
				push (@int_ids_to_return, $int_id) if $int_id;
			}
		}
		return \@int_ids_to_return;
    }
 
    my @tables=("MATRIX M");
    my @and;
    
	# in matrix table: collection,
    if ( $args{-collection})
	{
		my $q=' (COLLECTION=';
		if (ref $args{-collection} eq "ARRAY")
		{ # so, possibly several
			my @a;
			foreach (@{$args{-collection}})
			{
				push (@a, "\"$_\"");
			}
			$q.= join ( " or COLLECTION=", @a);
		}
		else
		{# just one - typical usage
			$q.="\"$args{-collection}\"";
		}
		$q.=" )  ";	
		push (@and, $q);
    }
    
	# in matrix table: names. Is something that is basically only used from the web interface
    # typically used by the get_matrix_by_name function instead
    
	if ($args{-name})
	{
		my $q=' (NAME=';
		if (ref $args{-name} eq "ARRAY")
		{ # so, possibly several
		    my @a;
		    foreach (@{$args{-name}})
			{
				push (@a, "\"$_\"");
		    }
		    $q.= join ( " or NAME=", @a);
		}
		else
		{# just one - typical usage
			$q.="\"$args{-name}\"";
		}
		$q.=" )  ";
		push (@and, $q);
    }

    # in species table: tax.id: possibly many species with OR in between
    if ( $args{-species})
	{
		push (@tables , "MATRIX_SPECIES S");
		my $q=" M.ID=S.ID and (TAX_ID= ";;
		if (ref $args{-species} eq "ARRAY")
		{ # so, possibly several
		    my @a;
		    foreach (@{$args{-species}})
			{
				push (@a, "\"$_\"");
		    }
		    $q.= join ( " or TAX_ID=", @a);
		}
		else
		{# just one - typical usage
			$q.="=\"$args{-species}\"";
		}
		$q.=") ";
		push (@and, $q);
    }

    # TAG_BASED
    # an internal join query:should be able to handle up to 26 tags-value combos with ANDS in between
    # Very ugly code ahead:
    
    my (@inner_tables, @internal_ands1,@internal_ands2 );
    my $int_counter=0; # for keeping track of  names;
    my @alpha = ("a" .. "z");

    my %arrayref;
    foreach my $key(keys %args)
	{
		next if  $key eq "-min_ic";
		next if  $key eq "-matrixtype";
		next if  $key eq "-species";
		next if  $key eq "-collection";
		next if  $key eq "-all_versions";
		next if  $key eq "-all";
		next if  $key eq "-ID";
		next if  $key eq "-length";
		next if  $key eq "-name";
		my $oldkey=$key;
		$key=~s/-//;
		$arrayref{$key}= $args{$oldkey};
    }
    if (%arrayref)
	{
		# get an internal name for the table
		push (@internal_ands2 , " M.ID=a.ID " );
		my @a;
		foreach my $key (keys %arrayref)
		{
			my $tname= $alpha[$int_counter];
			push (@inner_tables , "MATRIX_ANNOTATION $tname");
			push (@internal_ands1 , $alpha[$int_counter].".ID=". $alpha[$int_counter-1].".ID") unless $int_counter==0;
			$int_counter++;
			# is the thing aupplied an array reference in inteslf: make an "or" query from that
			if ( ref $arrayref{$key} eq "ARRAY")
			{
				my @b;
				foreach( @{$arrayref{$key}})
				{
					push (@b, $self->dbh->quote($_));
				}
				my $orstring= join (" or $tname.VAL=" , @b);			
				push (@a, "($tname.TAG=\"$key\" AND ($tname.VAL=$orstring))");			
			}   
			#or not
			else
			{
				push (@a, "($tname.TAG=\"$key\" AND $tname.VAL=\"$arrayref{$key}\")");
			}
		}
		my $s= " ( ". join (" AND ", @a). ")"; 
		push (@internal_ands2 , $s);
    }

    my $qq= "SELECT distinct(M.ID) from ". join (",", (@tables,@inner_tables)) . " where" . join ( " AND ", (@and,@internal_ands1, @internal_ands2 ));
   
   # warn $qq;
    
    #do actual mammoth query,and check for latest matrix
    my $sth=$self->dbh->prepare ($qq);
    $sth->execute();
    my @r;
    
    while (my($int_id)= $sth->fetchrow_array)
	{
		if ($args{-all_versions})
		{
			push (@r,$int_id);
		}
		else
		{
			# is latest?
			push(@r,$int_id) if ( $self->_is_latest_version($int_id) ==1);
		}	
    }
    warn "Warning: Zero matrices returned with current critera" unless scalar @r;
    return \@r;


}
## jsp6 - checkpoint



sub _is_latest_version{
    # is a particular internal ID representingthe latest matrix (collapse on base ids)
     my ($self, $int_id)=@_;
     my $sth=$self->dbh->prepare( qq! select count(*) from MATRIX 
				  where BASE_ID= (SELECT BASE_ID from MATRIX where ID=$int_id) 
				  AND VERSION>(SELECT VERSION from MATRIX where ID=$int_id) !);
     $sth->execute();
     my ($count)=  $sth->fetchrow_array();
     return(1) if $count ==0;# no matrices with higher version ID and same base id
	 return(0);
}

sub DESTROY
{
	#OK
	$_[0]->dbh->disconnect() if $_[0]->dbh;
}



