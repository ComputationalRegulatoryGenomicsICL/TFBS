#!/usr/bin/env perl  -w 
use TFBS::DB::FlatFileDir; 
use TFBS::PatternGen::Gibbs; 
my $gibbs = TFBS::PatternGen::Gibbs->new (-seq_file=>'sequences.fa', 
					  -motif_length=>10); 
my $db = TFBS::DB::FlatFileDir->create('NewPatterns'); 
$db->store_Matrix($gibbs->all_patterns());
