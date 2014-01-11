use Test;
use TFBS::Ext::pwmsearch;
use TFBS::Matrix::PFM;
plan(tests=>2);


my $matrixstring =
    "0   0  0  0  0  0  0  0\n".
    "0  12 12  0 12  0 12 12\n".
    "0   0  0 12  0 12  0  0\n".
    "12  0  0  0  0  0  0  0";

my $pfm = TFBS::Matrix::PFM->new(-matrix=>$matrixstring,
				 -name=>"MyMatrix");

my $pwm = $pfm->to_PWM;
my $seq = Bio::SeqIO->new(-file=>"t/test.fa", -format=>"fasta")->next_seq();

my $siteset1 = TFBS::Ext::pwmsearch::pwmsearch($pwm, $seq, "60%");
my $siteset2 = TFBS::Ext::pwmsearch::pwmsearch($pwm, $seq, "60%");
ok($siteset1->size(), 194);

#print STDERR "SIZE::".$siteset1->size()."\n";


my $it = $siteset2->Iterator();
my $startsum = 0;
while (my $site = $it->next())  {
    	$startsum += $site->start;
}
#print STDERR "STARTSUM::".$startsum."\n";

ok($startsum, 457608);
