# TFBS module for TFBS::DB::JASPAR2
#
# Copyright Boris Lenhard
# 
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::DB::JASPAR2 - interface to MySQL relational database of pattern matrices


=head1 SYNOPSIS

=over 4

=item * creating a database object by connecting to the existing JASPAR2-type database

    my $db = TFBS::DB::JASPAR2->connect("dbi:mysql:JASPAR2:myhost",
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

=item * creating a new JASPAR2-type database named MYJASPAR2:
 
    my $db = TFBS::DB::JASPAR2->create("dbi:mysql:MYJASPAR2:myhost",
				       "myusername",
				       "mypassword");

=item * storing a matrix in the database (currently only PFMs):

    #let $pfm is a TFBS::Matrix::PFM object
    $db->store_Matrix($pfm);



=back

=head1 DESCRIPTION

TFBS::DB::JASPAR2 is a read/write database interface module that
retrieves and stores TFBS::Matrix::* and TFBS::MatrixSet
objects in a relational database.


=head1 JASPAR2 DATA MODEL

JASPAR2 is working name for a relational database model used
for storing transcriptional factor pattern matrices in a MySQL database.
It was initially designed to store matrices for the JASPAR database of
high quality eukaryotic transcription factor specificity profiles by
Albin Sandelin and Wyeth W. Wasserman. Besides the profile matrix itself,
this data model stores profile ID (unique), name, structural class,
basic taxonomic and bibliographic information
as well as some additional optional tags.

Due to its data model, which precedeed the design of the 
module, TFBS::DB::JASPAR2 cannot store arbitrary tags for a matrix.

The supported tags are
    'acc'      # (accession number; 
	       # originally for transcription factor protein seq)
    'seqdb'    # sequence database where 'acc' comes from
    'medline'  # PubMed ID
    'species'  # Species name
    'sysgroup'
    'total_ic' # total information content - redundant, present 
               # for historical
"medline" => ($self->_get_medline($ID) or  ""),
		          "species" => ($self->_get_species($ID) or ""),
		          "sysgroup"=> ($self->_get_sysgroup($ID) or ""),
		          "type"    => ($self->_get_type($ID) or ""),
		          "seqdb"   => ($self->_get_seqdb($ID) or ""),
		          "acc"     => ($self->_get_acc($ID) or ""),
		          "total_ic"=


-----------------------  ADVANCED  ---------------------------------

For the developers and the curious, here is the JASPAR2 data model:

       CREATE TABLE matrix_data (
         ID varchar(16) DEFAULT '' NOT NULL,
         pos_ID varchar(24) DEFAULT '' NOT NULL,
         base enum('A','C','G','T'),
         position tinyint(3) unsigned,
         raw int(3) unsigned,
         info float(7,5) unsigned, -- calculated
         pwm float(7,5) unsigned,  -- calculated
         normalized float(7,5) unsigned,
         PRIMARY KEY (pos_ID),
         KEY id_index (ID)
       );


       CREATE TABLE matrix_info (
         ID varchar(16) DEFAULT '' NOT NULL,
         name varchar(15) DEFAULT '' NOT NULL,
         type varchar(8) DEFAULT '' NOT NULL,
         class varchar(20),
         phylum varchar (32),          -- maps to 'sysgroup' tag
         litt varchar(40),             -- not used by this module
         medline int(12),
         information varchar(20),      -- not used by this module
         iterations varchar(6),
         width int(2),                 -- calculated
         consensus varchar(25),        -- calculated
         IC float(6,4),                -- maps to 'total_ic' tag
         sites int(3) unsigned,        -- not used by this module
         PRIMARY KEY (ID)
       )


       CREATE TABLE matrix_seqs (
         ID varchar(16) DEFAULT '' NOT NULL,
         internal varchar(8) DEFAULT '' NOT NULL,
         seq_db varchar(15) NOT NULL,
         seq varchar(10) NOT NULL,
         PRIMARY KEY (ID, seq_db, seq)
       )


       CREATE TABLE matrix_species (
         ID varchar(16) DEFAULT '' NOT NULL,
         internal varchar(8) DEFAULT '' NOT NULL,
         species varchar(24) NOT NULL,
         PRIMARY KEY (ID, species)
       )

It is our best intention to hide the details of this data model, which we 
are using on a daily basis in our work, from most TFBS users, simply 
because for historical reasons some table column names are confusing 
at best. Most users should only know the methods to store the data and 
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

package TFBS::DB::JASPAR2;
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
	    TFBS::DB::JASPAR2->connect("dbi:mysql:DATABASENAME:HOSTNAME",
					"USERNAME",
					"PASSWORD");
 Function: connects to the existing JASPAR2-type database and
	   returns a database object that interfaces the database
 Returns : a TFBS::DB::JASPAR2 object
 Args    : a standard database connection triplet
	   ("dbi:mysql:DATABASENAME:HOSTNAME",  "USERNAME", "PASSWORD")
	   In place of DATABASENAME, HOSTNAME, USERNAME and PASSWORD,
	   use the actual values. PASSWORD and USERNAME might be
	   optional, depending on the user acces permissions for
	   the database server.

=cut

sub connect  {
    # a more intuitive syntax for the constructor
    my ($caller, @connection_args) = @_;
    $caller->new(-connect => \@connection_args);
}


=head2 create

 Title   : create
 Usage   : my $newdb =
	    TFBS::DB::JASPAR2->create("dbi:mysql:NEWDATABASENAME:HOSTNAME",
				      "USERNAME",
				      "PASSWORD");
 Function: connects to the database server, creates a new JASPAR2-type database and returns a database
	   object that interfaces the database
 Returns : a TFBS::DB::JASPAR2 object
 Args    : a standard database connection triplet
	    ("dbi:mysql:NEWDATABASENAME:HOSTNAME",  "USERNAME", "PASSWORD")
	   In place of NEWDATABASENAME, HOSTNAME, USERNAME and
	   PASSWORD use the actual values. PASSWORD and USERNAME
           might be optional, depending on the users acces permissions
           for the database server.

=cut

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
	my $matrixstring = $self->_get_matrixstring($ID, $mt) || return undef;
	
	eval("\$matrixobj= TFBS::Matrix::$ucmt->new".' 
	    ( -ID    => $ID,
	      -name  => $self->_get_name($ID)."",
	      -class => $self->_get_class($ID)."",
              -tags  => { "medline" => ($self->_get_medline($ID) or  ""),
		          "species" => ($self->_get_species($ID) or ""),
		          "sysgroup"=> ($self->_get_sysgroup($ID) or ""),
		          "type"    => ($self->_get_type($ID) or ""),
		          "seqdb"   => ($self->_get_seqdb($ID) or ""),
		          "acc"     => ($self->_get_acc($ID) or ""),
		          "total_ic"=> ($self->_get_total_ic($ID) or "")
                        },
	      -matrix=> $matrixstring   # FIXME - temporary
	      );');
	if ($@) {$self->throw($@); }
    }

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
    unless(defined $name) { 
	$self->throw("No name passed to get_Matrix_by_name."); }

    my @IDlist = $self->_get_IDlist_by_query(-names=>[$name]);
    my $ID= ($IDlist[0] 
	    or $self->warn("No matrix with name $name found."));
    if ((my $L= scalar @IDlist) > 1)  {
	$self->warn("There are $L matrices with name '$name'");
    }
    return $self->get_Matrix_by_ID($ID, $mt);
}



=head2 get_MatrixSet

 Title   : get_MatrixSet
 Usage   : my $matrixset = $db->get_MatrixSet(%args);
 Function: fetches matrix data under for all matrices in the database
	   matching criteria defined by the named arguments
	   and returns a TFBS::MatrixSet object
 Returns : a TFBS::MatrixSet object
 Args    : This method accepts named arguments:
	   -IDs        # a reference to an array of IDs (strings)
	   -names      # a reference to an array of
		       #  transcription factor names (string)
	   -classes    # a reference to an array of
		       #  structural class names (strings)
	   -species    # a reference to an array of
		       #   Latin species names (strings)
	   -sysgroups  # a reference to an array of
		       #  higher taxonomic categories (strings)

	   -matrixtype # a string, 'PFM', 'ICM' or 'PWM'
	   -min_ic     # float, minimum total information content
		       #   of the matrix

The five arguments that expect list references are used in database
query formulation: elements within lists are combined with 'OR'
operators, and the lists of different types with 'AND'. For example,

    my $matrixset = $db->(-classes => ['TRP_CLUSTER', 'FORKHEAD'],
			  -species => ['Homo sapiens', 'Mus musculus'],
			  -matrixtype => 'PWM');

gives a set of PWMs whose (structural clas is 'TRP_CLUSTER' OR
'FORKHEAD') AND (the species they are derived from is 'Homo sapiens'
OR 'Mus musculus').

The -min_ic filter is applied after the query in the sense that the
matrices profiles with total infromation content less than specified
are not included in the set.

=cut


sub get_MatrixSet  {
    my ($self, %args) = @_;
    my @IDlist = $self->_get_IDlist_by_query(%args);
    my $mt = ($args{'-matrixtype'} or "PWM");
    my $matrixset = TFBS::MatrixSet->new();
    foreach (@IDlist)  {
	next if (defined $args{'-min_ic'} 
		 and $self->_get_total_ic($_) < $args{'-min_ic'});
	$matrixset->add_Matrix($self->get_Matrix_by_ID($_, $mt));
    }
    return $matrixset;
}




=head2 store_Matrix

 Title   : store_Matrix
 Usage   : $db->store_Matrix($pfm);
 Function: Stores the contents of a TFBS::Matrix::DB object in the database
 Returns : 0 on success; $@ contents on failure
	   (this is too C-like and may change in future versions)
 Args    : (PFM_object)
	   A TFBS::Matrix::PFM object
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
	    $self->_store_matrix_seqs($pfm);
	    $self->_store_matrix_species($pfm);
	};
    }
    return $@;
}

=head2 store_MatrixSet

 Title   : store_MatrixSet
 Usage   : $db->store_Matrix($matrixset);
 Function: Stores the TFBS::DB::PFM object that are part of a
           TFBS::MatrixSet object into the database
 Returns : 0 on success; $@ contents on failure
	   (this is too C-like and may change in future versions)
 Args    : (MatrixSet_object)
	   A TFBS::MatrixSet object
 Comment : THIS METHOD IS NOT YET IMPLEMENTED

=cut


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
	    foreach my $table (qw  (matrix_data
				    matrix_info
				    matrix_seqs
				    matrix_species)
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



sub _get_IDlist_by_query  {

    # called by get_MatrixSet

    my ($self, %args) = @_;
    my ($TABLES, %arrayref);
    $args{-names}     and  $arrayref{name}   = $args{-names}    ;
    $args{-classes}   and  $arrayref{class}  = $args{-classes}  ;
    $args{-sysgroups} and  $arrayref{phylum} = $args{-sysgroups};
    $args{-IDs}       and  $arrayref{ID}     = $args{-IDs};
    my @andconditions;
    if ($args{-species})  {
	$TABLES = ' matrix_info, matrix_species ';
	push @andconditions, 
	'matrix_info.ID = matrix_species.ID',
	" (".
	    join(" OR ", 
	         (map {"matrix_species.species=".
			   $self->dbh->quote($_)
			   } 
		  @{$args{-species}}
		  )).
		      ") ";
    }
    else  {
	$TABLES = 'matrix_info ';
    }
    
    foreach my $key (keys %arrayref)  {
      if (scalar @{$arrayref{$key}})  {
	push @andconditions,
	"(".
	join(" OR ",
	     (map {"matrix_info.$key=".
		       $self->dbh->quote($_)
		  } 
	      @{$arrayref{$key}}
	     )).
	")";
      }
      else  {
	push @andconditions, "(1=0)";
      }
    }

    my $WHERE = ((scalar @andconditions) == 0) ? "" : " WHERE ";


    my $query = 
	    "SELECT DISTINCTROW matrix_info.id FROM $TABLES $WHERE".
	    join(" AND ", @andconditions);

    my $sth = $self->dbh->prepare($query);
    $sth->execute() or $self->throw("Query failed:\n$query\n");
    
    # collect IDs and return

    my @IDlist = ();
    while (my ($id) = $sth->fetchrow_array())  {
	push @IDlist, $id;
    }

    $sth->finish;
    return @IDlist;
}


sub _get_matrixstring  {
    my ($self, $ID, $mt) = @_;
    my %dbname = (PWM => 'pwm', PFM => 'raw', ICM => 'info');
    unless (defined $dbname{$mt})  {
	$self->throw("Unsupported matrix type: ".$mt);
    }
    my $sth;
    my $qID = $self->dbh->quote($ID);
    my $matrixstring = "";
    foreach my $base (qw(A C G T)) {
	$sth=$self->dbh->prepare
	    ("SELECT $dbname{$mt} FROM matrix_data 
              WHERE ID=$qID AND base='$base' ORDER BY position");
	$sth->execute;
	$matrixstring .=
	    join (" ", (map {$_->[0]} @{$sth->fetchall_arrayref()}))."\n";
    }
    $sth->finish;
    return undef if $matrixstring eq "\n"x4;

    return $matrixstring;
}


sub _simple_query  {
    my ($self, $table, $retr_field, $search_field, $search_value) = @_;
    my $q_value = $self->dbh->quote($search_value);
    my $sth = $self->dbh->prepare
	("SELECT DISTINCT $retr_field from $table WHERE $search_field = $q_value and $retr_field <> \"\" ORDER BY $retr_field");
    $sth->execute;
    return (map {$_->[0]} @{$sth->fetchall_arrayref});
}


sub _store_matrix_data  {
    my ($self, $pfm, $ACTION) = @_;
    my @base = qw(A C G T);
    my $pfmatrix = $pfm->matrix();
    my $icmatrix = $pfm->to_ICM()->matrix();
    my $pwmatrix = $pfm->to_PWM->matrix();
    my $sth = $self->dbh->prepare 
	(q! INSERT INTO matrix_data VALUES(?,?,?,?,?,?,?,?) !);
				 
    for my $i (0..3)  {
	for my $j (0..($pfm->length-1)) {
	    $sth->execute( $pfm->ID,
			   $pfm->ID.".".$base[$i].".".($j+1),
			   $base[$i],
			   $j+1,
			   $pfmatrix->[$i][$j],
			   $icmatrix->[$i][$j],
			   $pwmatrix->[$i][$j],
			   $pfmatrix->[$i][$j] / $pfm->column_sum())
		or $self->throw("Error executing query.");
	}
    }
    
}

sub _store_matrix_info  {
    my ($self, $pfm, $ACTION) = @_;
    my $sth = $self->dbh->prepare 
	(q! INSERT INTO matrix_info
	    (ID, name, type, class, phylum, width, IC, sites) 
	    VALUES(?,?,?,?,?,?,?,?) !);
    $sth->execute($pfm->ID,
		  ($pfm->name or $pfm->ID),
		  ($pfm->{'tags'}->{'type'} or ""),
		  ($pfm->class() or undef),
		  ($pfm->{'tags'}->{'sysgroup'} or undef),
		  $pfm->length(),
		  $pfm->to_ICM->total_ic(),
		  $pfm->column_sum()
		  )
	or $self->throw("Error executing query");
}

sub _store_matrix_seqs  {
    my ($self, $pfm, $ACTION) = @_;
    return unless ($pfm->{'tags'}->{'seqdb'} or $pfm->{'tags'}->{'acc'});
    my $sth = $self->dbh->prepare
	(q! INSERT INTO matrix_seqs
	    (ID, seq_db, seq) 
	    VALUES(?,?,?) !);
    $sth->execute($pfm->ID,
		  ($pfm->{'tags'}->{'seqdb'} or ""),
		  ($pfm->{'tags'}->{'acc'} or "")
		 )
	or $self->throw("Error executing query");
    
}

sub _store_matrix_species  {
    my ($self, $pfm, $ACTION) = @_;
    return unless $pfm->{'tags'}->{'species'};
    my $sp = $pfm->{'tags'}->{'species'};
    my @splist = (ref($sp) ? @$sp : $sp);
    foreach my $species (@splist)  {
	my $sth = $self->dbh->prepare
	    (q! INSERT INTO matrix_species
	     (ID, species) 
	     VALUES(?,?) !);
	$sth->execute($pfm->ID,
		      $species
		      )
	    or $self->throw("Error executing query");
    }
}

sub _create_tables {
    # utility function

    # If you want to change the databse schema,
    # this is the right place to do it

    my $dbh = shift;

    my @queries = 
	(
       q!
       CREATE TABLE matrix_data (
         ID varchar(16) DEFAULT '' NOT NULL,
         pos_ID varchar(24) DEFAULT '' NOT NULL,
         base enum('A','C','G','T'),
         position tinyint(3) unsigned,
         raw int(3) unsigned,
         info float(7,5) unsigned,
         pwm float(7,5),
         normalized float(7,5) unsigned,
         PRIMARY KEY (pos_ID),
         KEY id_index (ID)
       )
       !,

       q!
       CREATE TABLE matrix_info (
         ID varchar(16) DEFAULT '' NOT NULL,
         name varchar(15) DEFAULT '' NOT NULL,
         type varchar(8) DEFAULT '' NOT NULL,
         class varchar(20),
         phylum varchar(32),
         litt varchar(40),
         medline int(12),
         information varchar(20),
         iterations varchar(6),
         width int(2),
         consensus varchar(25),
         IC float(6,4),
         sites int(3) unsigned,
         PRIMARY KEY (ID)
       )
       !,

       q!
       CREATE TABLE matrix_seqs (
         ID varchar(16) DEFAULT '' NOT NULL,
         internal varchar(8) DEFAULT '' NOT NULL,
         seq_db varchar(15) NOT NULL,
         seq varchar(10) NOT NULL,
         PRIMARY KEY (ID, seq_db, seq)
       )
       !,

       q!
       CREATE TABLE matrix_species (
         ID varchar(16) DEFAULT '' NOT NULL,
         internal varchar(8) DEFAULT '' NOT NULL,
         species varchar(24) NOT NULL,
         PRIMARY KEY (ID, species)
       )
	 !);
    foreach my $query (@queries)  {
	$dbh->do($query) 
	    or die("Error executing the query: $query\n");
    }
}



sub AUTOLOAD  {
    my ($self, $ID) = @_;
    no strict 'refs';
    my $TABLE;
    my %dbname_of = (ID       => 'ID',
		     name     => 'name',
		     class    => 'class', 
		     species  => 'species', 
		     sysgroup => 'phylum',
		     type     => 'type',
		     seqdb    => 'seq_db',
		     acc      => 'seq',
		     total_ic => 'IC',
		     medline  => 'medline'
		     ); 
    my ($where_column, $where_value);
    if ($AUTOLOAD =~ /.*::_{0,1}get_(\w+)_list/) {
	defined $dbname_of{$1} or $self->throw("$AUTOLOAD: no such method!");
	($where_column, $where_value) = (1,1);
    }
    elsif ($AUTOLOAD =~ /.*::_get_(\w+)/) {
	defined $dbname_of{$1} or $self->throw("$AUTOLOAD: no such method!");
	defined $ID or $self->throw("No ID provided for $AUTOLOAD");
	($where_column, $where_value) = ('ID', $ID);
    }
    else  {
	$self->throw("$AUTOLOAD: no such method!");
    }
    defined $dbname_of{$1} or $self->throw("$AUTOLOAD: no such method!");
    if    ($1 eq 'species')  { $TABLE = 'matrix_species'; }
    elsif ($1 eq 'seqdb' or $1 eq 'acc') { $TABLE = 'matrix_seqs', }
    else  { $TABLE = 'matrix_info' ; }
    my @results = $self->_simple_query ($TABLE, $dbname_of{$1}, 
					$where_column => $where_value);
    wantarray ? return @results : return $results[0];
}


sub DESTROY  {
    $_[0]->dbh->disconnect() if $_[0]->dbh;
}





1;
