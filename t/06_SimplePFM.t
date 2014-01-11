#!/usr/bin/env perl -w

use TFBS::PatternGen::SimplePFM;
use Test;
plan(tests => 1);
my $matrixstring = <<ENDMATRIX 
11  3  0  0  4 0 
0  0  0 10  6  0 
0  8 11  0  0  0 
0  0  0  1  1 11
ENDMATRIX
    ;
my $manpfm = TFBS::Matrix::PFM->new(-matrixstring=>$matrixstring);



my @sequences = qw( AAGCCT AGGCAT AAGCCT
		    AAGCCT AGGCAT AGGCCT
		    AGGCAT AGGTTT AGGCAT
		    AGGCCT AGGCCT );
my $patterngen =
  TFBS::PatternGen::SimplePFM->new(-seq_list=>\@sequences);
  
my $pfm = $patterngen->pattern(); # $pfm is now a TFBS::Matrix::PFM object

ok($manpfm->rawprint, $pfm->rawprint);

