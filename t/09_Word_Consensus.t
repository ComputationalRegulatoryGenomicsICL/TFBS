#!/usr/bin/env perl -w

use TFBS::Word::Consensus;
use Test;
plan(tests => 2);
# print STDERR join("\n", @INC);

my $word = "AGGTCMNNNNKGACCT";

my $word_obj = TFBS::Word::Consensus->new(-word=>$word,
                                          -name=>"MyConsensus");
print $word_obj->to_PWM->prettyprint;

my $siteset = $word_obj->search_seq(-file=>'t/test.fa',
                                    -threshold=>"70%",
                                    -max_mismatches => 4);

ok($siteset->size(), 6);
#print $siteset->GFF."\n\n";

my $sitepairset =
    $word_obj->search_aln(-file=>'t/test.aln',
			     -window=>50, -cutoff=>50,
			     -max_mismatches=>6);
#print $sitepairset->GFF;

my $It = $sitepairset->Iterator();
my $startsum = 0;

while (my $sitepair = $It->next)  {
    $startsum += $sitepair->feature1->start;
}

ok($sitepairset->size, 24);


