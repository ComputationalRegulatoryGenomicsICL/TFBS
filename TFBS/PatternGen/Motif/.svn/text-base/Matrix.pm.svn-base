package TFBS::PatternGen::Motif::Matrix;
use vars qw(@ISA);
use strict;
 
use TFBS::Matrix;
use TFBS::Matrix::PFM;

@ISA = qw(TFBS::Matrix);

sub new  {
    my ($caller, %args) = @_;
    #my $matrix = TFBS::Matrix->new(%args, -matrixtype=>"PFM");
    #my $self = bless $matrix, ref($caller) || $caller;
    my $self = $caller->SUPER::new(%args, -matrixtype=>"PFM");
    $self->{'length'} = $args{'-length'} || scalar @{$self->{'matrix'}->[0]};
    $self->{'nr_hits'} = ($args{'-nr_hits'} || undef);
    #           || $self->throw("No -nr_hits provided.");
    # Why was nr_hits required ?? (Boris)
    $self->{'sites'}=$args{'-sites'};
    # $self->{'tags'} = ($args{'-tags'} || {});
    return $self;
}

sub PFM  {
    my ($self, %args) = @_;
    return TFBS::Matrix::PFM->new (-name => "unknown",
				   -ID   => "unknown",
				   -class=> "unknown",
				   -tags => { %{$self->{'tags'} } },
				   %args,
				   -matrix => $self->_calculate_PFM()
				   );
}

sub pattern {
    my ($self, %args ) = @_;
    $self->PFM(%args);
}


sub _calculate_PFM  { # simplest case: matrix already IS PFM
    my $self = shift;
    return [@{$self->{'matrix'}}];
}

sub get_sites{
    return @{$_[0]->{'sites'}};
}

1;
