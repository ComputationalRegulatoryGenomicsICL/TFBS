#!/usr/bin/env perl  -w

use strict;
use Bio::SeqIO;
use TFBS::DB::LocalTRANSFAC;

use Test;
plan(tests => 6);

my $seq = Bio::SeqIO->new(-file=>'t/test.fa')->next_seq;
my $db = TFBS::DB::LocalTRANSFAC->connect(-accept_conditions=>1,
					  -localdir=>'t/transfac_old');
ok(("TFBS::DB::LocalTRANSFAC" eq ref($db)),1);

my $pwm = $db->get_Matrix_by_ID('V$CEBPA_01','PWM');

ok($pwm->length,14);

my $siteset = $pwm->search_seq(-seqobj=>$seq, -threshold=>"80%");
#print $siteset->GFF(), 

ok($siteset->size,31);

$db = TFBS::DB::LocalTRANSFAC->connect(-accept_conditions=>1,
					  -localdir=>'t/transfac_new');

ok(("TFBS::DB::LocalTRANSFAC" eq ref($db)),1);


$pwm = $db->get_Matrix_by_ID('V$MYOD_01','PWM');

ok($pwm->length,12);

$siteset = $pwm->search_seq(-seqobj=>$seq, -threshold=>"80%");
print $siteset->GFF(), 

ok($siteset->size,22);

