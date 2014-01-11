#!/usr/bin/env perl -w 

use TFBS::Matrix::PFM;
use TFBS::DB::FlatFileDir;
use Test;
plan(tests => 2);

my @dbparams;


# set up a matrix

my $matrixstring =
        "12 3 0 0 4 0\n0 0 0 11 7 0\n0 9 12 0 0 0\n0 0 0 1 1 12";
my $pfm = TFBS::Matrix::PFM->new(-matrix=>$matrixstring, -ID=>"TEST001");
my $rawstring1 = $pfm->rawprint();

my $db;

# write/read test

$db = TFBS::DB::FlatFileDir->create ("t/FlatFileDir");
$db->store_Matrix($pfm);
my $pfm2= $db->get_Matrix_by_ID("TEST001", "PFM");
my $rawstring2 = $pfm2->rawprint;

ok ($rawstring1, $rawstring2);


# delete test

$db->delete_Matrix_having_ID('TEST001');
my $nopfm = $db->get_Matrix_by_ID("TEST001", "PFM");

ok(undef, $nopfm);



END {

    -d "t/FlatFileDir" && 
	unlink <t/FlatFileDir/*>;
    rmdir "t/FlatFileDir";
}



