#!/usr/bin/env perl -w


use TFBS::PatternGen::Elph;
use TFBS::PatternGen::SimplePFM;

use Test;
plan(tests => 5);
my $gibbspath;
eval {$gibbspath = `which elph 2> /dev/null`;};
if (!$gibbspath or ($gibbspath =~ / /)) { # if space, then error message :)
         print "ok # Skipped: (no elph executable found)\n"x5;
	exit(0);
}

my $fastafile = "t/test_meme.fa";
#my $fastafile = $ARGV[0];

for (1..5) {
    my $elph = 
      TFBS::PatternGen::Elph->new
	  (-motif_length=>7,
	   
	   -seq_file=>$fastafile,
        -additional_params=>'-l -x -b -g -v'
	  
	  );
#	  print Dumper $elph;
    my $pfm_elph = $elph->pattern();
    my @pfms=$elph->all_patterns;
    my @motifs=$elph->all_motifs;
    if (@motifs>0){
	ok(1);
	my @sites=$motifs[0]->get_sites;
	ok(1,($sites[0]->seq->seq ne ''));
	my @matrix;
	foreach my  $site(@sites){
	    push @matrix,$site->seq->seq;
	    
	}
	my $patt=TFBS::PatternGen::SimplePFM->new(-seq_list=>\@matrix);
	my $col_sum=$elph->pattern->matrix->[0]->[0];
	my $check_sum=$patt->pattern->matrix->[0]->[0];
	
	ok(1,$col_sum==$check_sum);
    }
#    }
    if (@pfms>0) {
	ok(1);
#	ok(1,($pfms[0]->tag("MAP_score")>0));
	last;
    }
}

ok(1);

