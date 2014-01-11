#!/usr/bin/env perl -w

use TFBS::Matrix::PFM;
use strict;

use Test;
plan(tests => 2);

my $matrixstring =
    "0   0  0  0  0  0  0  0\n".
    "0  12 12  0 12  0 12 12\n".
    "0   0  0 12  0 12  0  0\n".
    "12  0  0  0  0  0  0  0";

my $pfm = TFBS::Matrix::PFM->new(-matrix=>$matrixstring,
				 -name=>"MyMatrix");

my $siteset = $pfm->to_PWM->search_seq(-file=>'t/test.fa',-threshold=>"70%");

ok($siteset->size(), 20);
print $siteset->GFF();

my $sitepairset = 
    $pfm->to_PWM->search_aln(-file=>'t/test.aln', 
			     -window=>50, -cutoff=>50, 
			     -threshold=>"70%");

my $It = $sitepairset->Iterator();
my $startsum = 0;
while (my $sitepair = $It->next)  {
    $startsum += $sitepair->feature1->start;
}

ok($startsum, 3013);
