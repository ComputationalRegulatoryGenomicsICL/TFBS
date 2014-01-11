package TFBS::_Iterator;

use vars '@ISA';
use strict;
use Carp;
@ISA = qw(Bio::Root::Root);

#############################################################
# PUBLIC METHODS
#############################################################

sub new  {
    my ($caller, $arrayref, $sort_by, $reverse) = @_;
    my $class = ref $caller || $caller;
    my $self;
    if ($arrayref)  {
	$self = bless { _orig_array_ref     => [ @$arrayref ],
			_iterator_array_ref => [ @$arrayref ],
			_sort_by            => ($sort_by || undef),
			_reverse            => ($reverse || 0)
			},
		$class;
    }
    else  {
	croak("No valid array ref for Iterator of ".
	      (ref($class)  || $class)." provided:");
    }
    
    $self->_sort()    if $sort_by;
    $self->_reverse() if $reverse;

    return $self;
}
				       


sub current {

}

sub reset  {
    my ($self) = @_;
    @{$self->{_iterator_array_ref}} = @{$self->{_orig_array_ref}};
    $self->_sort()    if $self->{'_sort_by'};
    $self->_reverse() if $self->{'reverse'};
    return $self;
}

sub next {
    my $self = shift;
    return shift @{$self->{_iterator_array_ref}};
}
#################################################################
# PRIVATE METHODS
#################################################################

sub _sort  {
    my ($self, $sort_by) = @_;
    $self->throw("Generic iterator cannot sort ".ref($self).
		 " object by '$sort_by'.");
}

sub _reverse {
    my $self = shift;
    $self->{'_iterator_array_ref'} = 
	[ reverse @{ $self->{'_iterator_array_ref'} } ];
}




