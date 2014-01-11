#!/usr/bin/env perl -w


use TFBS::PatternGen::Gibbs;

use Test;
plan(tests => 5);
my $gibbspath;
eval {$gibbspath = `which Gibbs 2> /dev/null`;};
if (!$gibbspath or ($gibbspath =~ / /)) { # if space, then error message :)
    print "ok # Skipped: (no Gibbs executable found)\n"x5;
	exit(0);
}

my $fastafile = "t/test.gibbin";

for (1..5) {
    my $gibbs = 
      TFBS::PatternGen::Gibbs->new
	  (-nr_hits=>10,
	   -motif_length=>[10..12],
	   -seq_file=>$fastafile);
    

    my @pfms = $gibbs->all_patterns();
    my @motifs=$gibbs->all_motifs;
    if (@motifs>0){
	ok(1);
	my @sites=$motifs[0]->get_sites;
#	my $seq=$sites[0]->seq->seq;
	ok(1,($sites[0]->seq->seq ne ''));
    }
    if (@pfms>0) {
	ok(1);
	ok(1,($pfms[0]->tag("MAP_score")>0));
	last;
    }
}

ok(1);

