#!/usr/bin/env perl -w

use TFBS::Matrix::PFM;
use TFBS::Tools::SetOperations;
use strict;

use Test;
plan(tests=>2);

my $matrixstring =
    "0   0  0  0  0  0  0  0\n".
    "0  12 12  0 12  0 12 12\n".
    "0   0  0 12  0 12  0  0\n".
    "12  0  0  0  0  0  0  0";

my $pfm = TFBS::Matrix::PFM->new(-matrix=>$matrixstring,
				 -name=>"MyMatrix");

my $siteset = $pfm->to_PWM->search_seq(-file=>'t/test.fa',-threshold=>"70%");

ok($siteset->size(), 20);

my $siteset2 = $pfm->to_PWM->search_seq(-file => 't/test.fa',
					-threshold=>"60%");

ok ($siteset2->size>20, 1);

my $sop = TFBS::Tools::SetOperations->new;

my $i = $sop->intersection($siteset, $siteset2);

my $u = $sop->union($siteset, $siteset2);


exit(0);
