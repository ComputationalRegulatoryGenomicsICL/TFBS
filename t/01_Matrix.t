#!/usr/bin/env perl -w

use TFBS::Matrix::PFM;
use Test;
plan(tests => 4);
# print STDERR join("\n", @INC);

my $matrixstring =
    "2 2 2 2 2 2 2 2\n0 0 0 0 0 0 0 0\n0 0 0 0 0 0 0 0\n0 0 0 0 0 0 0 0";

my $pfm = TFBS::Matrix::PFM->new(-matrix=>$matrixstring,
				 -name=>"MyMatrix");

my $pfmstring = $pfm->rawprint;

my $icmstring = $pfm->to_ICM(-add_pseudocounts=>0)->rawprint;

ok($pfmstring, $icmstring);

ok(1, defined $pfm->to_ICM);

my $pwmstring = $pfm->to_PWM->rawprint;

my @pwmlines = split "\n", $pwmstring;

ok ($pwmlines[1], $pwmlines[3]);
ok (1, ($pwmlines[0] ne $pwmlines[1]));





 
