package TFBS::PatternGenI;
use vars qw(@ISA);
use strict;

# Object preamble - inherits from Bio::RootI;
use Bio::Root::Root;
use Carp;

@ISA = qw(Bio::Root::Root);

sub pattern  {
    my $self = shift;
    $self->_abstractDeath;
}

sub _abstractDeath {
    # borrowed from BioPerl; with compliments :)
    my $self = shift;
    my $package = ref $self;
    my $caller = (caller())[1];
  
    confess "Abstract method '$caller' defined in interface TFBS::PatternGenI not implemented by pacakge $package";
}


