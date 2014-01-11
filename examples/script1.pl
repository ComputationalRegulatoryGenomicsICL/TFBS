#!/usr/bin/env perl  -w 
use Bio::DB::GenBank; 
use TFBS::DB::TRANSFAC; 
my $seq = Bio::DB::GenBank->new()->get_Seq_by_acc('AF100993'); 
my $db = TFBS::DB::TRANSFAC->connect(); 
my $pwm = $db->get_Matrix_by_ID('V$CEBPA_01','PWM'); 
my $siteset = $pwm->search_seq(-seqobj=>$seq, -threshold=>"80%"); 
print $siteset->GFF();
