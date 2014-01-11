package TFBS::PatternGen::Motif::Word;

use vars qw(@ISA);
use strict;
use  TFBS::Word::Consensus;

@ISA = qw(TFBS::Word::Consensus);

sub new  {
    my ($caller, %args) = @_;
    
       
    my $word = TFBS::Word::Consensus->new(%args);
    my $self = bless $word, ref($caller) || $caller;
    return $self;
}
sub pattern {
    return $_;
}

1;
