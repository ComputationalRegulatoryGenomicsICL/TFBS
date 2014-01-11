#!/usr/bin/env perl -w 

use TFBS::Matrix::PFM;
use TFBS::DB::JASPAR2;
use Test;
plan(tests => 2);

my @dbparams;


if (-e 't/MYSQLCONNECT') {
    open FILE, 't/MYSQLCONNECT';
	my $line = <FILE>;
	@dbparams = split "::", $line;
    close FILE;
    $skip = 0;
}
else {
    print "ok # Skip (MySQL server not set up)\n"x2;
    exit(0);
}

# set up a matrix

my $matrixstring =
        "12 3 0 0 4 0\n0 0 0 11 7 0\n0 9 12 0 0 0\n0 0 0 1 1 12";
my $pfm = TFBS::Matrix::PFM->new(-matrix=>$matrixstring, -ID=>"TEST001");
my $rawstring1 = $pfm->rawprint();

my $db;

# write/read test

$db = TFBS::DB::JASPAR2->create
    ("dbi:mysql:JASPAR2TEST:$dbparams[0]",$dbparams[1], $dbparams[2]);
$db->store_Matrix($pfm);
my $pfm2= $db->get_Matrix_by_ID("TEST001", "PFM");
my $rawstring2 = $pfm2->rawprint;

ok ($rawstring1, $rawstring2);


# delete test

$db->delete_Matrix_having_ID('TEST001');
my $nopfm = $db->get_Matrix_by_ID("TEST001", "PFM");

ok(undef, $nopfm);



END {
    $db &&  
    $db->dbh && 
    $db->dbh->do("drop database if exists JASPAR2TEST");
}



