#!/usr/bin/env perl -w

# list_matrices.pl
#   by Boris Lenhard
#
# See POD documentation for this script at the end of the file
#

use strict;
use Getopt::Long; # for parsing command line arguments
use Pod::Usage;
use TFBS::DB::FlatFileDir;

  # Get command line options - if you are curious how this 
  # works, check the Getopt::Long module documentation.

my ($database_dir, $id_only, $verbose, $help);

GetOptions('help'            => \$help,
	   'database=s'      => \$database_dir,
	   'id-only'   => \$id_only,
	   'verbose'   => \$verbose
	   );

if($help)  {
    pod2usage(-exitstatus=>0, -verbose=>2);
}
elsif (!$database_dir) {
    pod2usage(1);
}

  # connect to FlatFileDir matrix database
  # (there is a sample FlatFileDir matrix database directory 
  # examples/SAMPLE_FlatFileDir in the TFBS distribution package)
  # Change this line if you want to use a different type of database
  # (e.g. TFBS::DB::JASPAR2)


my $db = TFBS::DB::FlatFileDir->connect($database_dir);


  # get all matrices (TFBS::Matrix::PWM objects) into a TFBS::MatrixSet object

my $matrixset = $db->get_MatrixSet(-matrixtype=>"PFM");


  # print heading if normal output

unless ($id_only or $verbose)  {
    printf("\n %-10s%-15s%-20s%10s%10s\n",
	   'MatrixID', 'Name', 'Class','Length', 'Total IC');
}
  # print line if normal or verbose output

unless($id_only) {    print ("-"x70,"\n"); }


  # Iterate through the set and display ID and name
  # (aggregate classes in TFBS - TFBS::MatrixSet, TFBS::SiteSet, 
  #  TFBS::SitePairSet) are equipped with iterators that all follow 
  #  the same syntax:)

my $mx_iterator = $matrixset->Iterator(-sort_by=>'ID');


while (my $pfm = $mx_iterator->next())  { #for each matrix in the set
    if ($verbose)  {
	print ("\n","-"x65);
	print ("\nMatrix ID                     : ", $pfm->ID);
	print ("\nTransctiption factor name     : ", $pfm->name);
	print ("\nStructural class              : ", $pfm->class);
	print ("\nTotal information content     : ", 
	       sprintf("%2.2f",$pfm->to_ICM->total_ic));
	print ("\nMatrix:\n", $pfm->prettyprint);
	       
	print ("","-"x65,"\n\n");
    }
    elsif ($id_only) {
	print ($pfm->ID, "\t", $pfm->name, "\n");
    }
    else {
	printf(" %-10s%-15s%-20s%10s%10.2f\n",
	       $pfm->ID, $pfm->name, $pfm->class, 
	       $pfm->length, $pfm->to_ICM->total_ic);
    }
}

# print the line for normal and verbouse output

unless($id_only)  { 
    print ("-"x70, "\nTotal ", $matrixset->size, " matrices.\n\n"); 
}









# The rest is usage message if the user requests help 
# or fails to provide required parameters

__END__


=head1 NAME

list_matrices.pl - List info on matrix patterns stored in a flat file directory

=head1 SYNOPSIS

./list_matrices.pl -d <TFBS_matrix_dbase_dir> [other_options] 

=head1 OPTIONS

=over 8

=item B<-d  or  --database>  <directory name>

REQUIRED: Name of the FlatFileDir database directory to 
use for retrieving matrices. 
A sample database directory examples/SAMPLE_FlatFileDir 
is available in TFBS distribution. 

=item B<-i  or  --id-only>

OPTIONAL: Prints only a list of matrix IDs


=item B<-v  or  --verbose>

OPTIONAL: Prints full record (matrix and info). Overrides -i if set simultaneously.

=back

=head1 DESCRIPTION

This is an example script that displays information about matrix patterns stored 
in a flat file directory-type database. Its source code is 
meant to be studied by bioinformaticians who wish to learn how to 
use TFBS modules.


=cut
