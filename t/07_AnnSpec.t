#!/usr/bin/env perl -w

use TFBS::PatternGen::AnnSpec;
use TFBS::PatternGen::SimplePFM;
use Test;
plan(tests => 7);
my $annspecpath;
eval {$annspecpath = `which ann-spec 2> /dev/null`;};
if (!$annspecpath or ($annspecpath =~ / /)) { # if space, then error message :)
    print "ok # Skipped: (no AnnSpec executable found)\n"x7;
	exit(0);
}

my $fastafile = "t/test_meme.fa";
#my $fastafile=$ARGV[0];

for (1..5) {
    my $patterngen=TFBS::PatternGen::AnnSpec->new(-seq_file=>$fastafile,
                                            #-binary=>'ann-spec',
                                            -additional_params=>'-P 5 -c'
                                             );
   
    my @pfms = $patterngen->all_patterns();
    
    my @motifs=$patterngen->all_motifs;
    if (@motifs>0){
	ok(1);
	my @sites=$motifs[0]->get_sites;
	ok(1,($sites[0]->seq->seq ne ''));
	my @seqs;
	
        foreach my $site(@sites){
            push @seqs,$site->seq->seq;
        }
        print $pfms[0]->rawprint;
        my $seq=$sites[0]->seq->seq;
        my $patt=TFBS::PatternGen::SimplePFM->new(-seq_list=>\@seqs);
	my $col_sum=$pfms[0]->matrix->[0]->[0];
	my $check_sum=$patt->pattern->matrix->[0]->[0];
	
	ok(1,$col_sum==$check_sum);
    }
    if (@pfms>0) {
	ok(1);
	ok(1,($pfms[0]->tag("score")>0));
	last;
    }
}

ok(1);

