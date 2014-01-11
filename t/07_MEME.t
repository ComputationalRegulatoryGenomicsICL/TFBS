#!/usr/bin/env perl -w

use TFBS::PatternGen::MEME;

use Test;
plan(tests => 5);
my $memepath;
eval {$memepath = `which meme 2> /dev/null`;};
if (!$memepath or ($memepath =~ / /)) { # if space, then error message :)
    print "ok # Skipped: (no meme executable found)\n"x5;
	exit(0);
}

my $fastafile = "t/test_meme.fa";

for (1..1) {
    my $patterngen=TFBS::PatternGen::MEME->new(-seq_file=>$fastafile,
                                               -additional_params=>' -revcomp -nmotifs 2 -w 10',
                                               );
   
    
    my @motifs=$patterngen->all_motifs;
    if (@motifs>0){
	ok(1);
	my @sites=$motifs[0]->get_sites;
#	my $seq=$sites[0]->seq->seq;
	ok(1,($sites[0]->seq->seq ne ''));
    }

    my @pfms = $patterngen->all_patterns();
    if (@pfms>0) {
	ok(1);
	ok(1,($pfms[0]->tag("score")>0));
	last;
    }
}

ok(1);

