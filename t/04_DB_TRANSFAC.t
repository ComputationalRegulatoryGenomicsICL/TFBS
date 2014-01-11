#!/usr/bin/env perl -w 

use TFBS::DB::TRANSFAC;
use Test;
plan(tests => 4);

my $db = TFBS::DB::TRANSFAC->new(-accept_conditions=>1);
# get a pfm by acc

my $pfm1 = $db->get_Matrix_by_acc('M00039');
my $icm1 = $db->get_Matrix_by_acc('M00039',"icm");

my $pfm2 = $db->get_Matrix_by_ID('V$CREB_01', "PFM");
my $icm2 = $db->get_Matrix_by_ID('V$CREB_01', "ICM");

print STDERR $icm1->name()."######".$icm1->tag('acc');

ok($pfm1->ID,'V$CREB_01');
ok($pfm1->rawprint, $pfm2->rawprint);
ok($icm1->rawprint, $icm2->rawprint);
ok($icm1->tag('acc'), "M00039");
