package TFBS::_Iterator::_MatrixSetIterator;

use vars '@ISA';
use strict;
use Carp;
use TFBS::_Iterator;

@ISA = qw(TFBS::_Iterator);


sub _sort  {
    my ($self, $sort_by) = @_;
    $sort_by or $sort_by = $self->{_sort_by} or  $sort_by = 'name';

    # we can sort by name, start, end, score
    
    my %sort_fn = 
	(class => sub  { $a->class() cmp $b->class() 
			     ||
			 $a->name()  cmp $b->name()
			     ||
			 $a->ID()    cmp $b->ID()   
		       },

	 id   => sub  { $a->ID() cmp $b->ID()   
		       },
	 ID   => sub  { $a->ID() cmp $b->ID()   
		       },

	 name  => sub  { $a->name() cmp $b->name() ||
			 $a->class() cmp $b->class()     ||
			 $a->ID()    cmp $b->ID()   
		       },

        species  => sub  { $a->tag('species') cmp $b->tag('species') ||
			 $a->class() cmp $b->class()     ||
			 $a->ID()    cmp $b->ID()   
		       },

        
	 total_ic => sub {  $b->total_ic()   <=> $a->total_ic()
			     ||
			  $a->name() cmp $b->name()
		      }
	);
			 
    if (defined (my $sort_function = $sort_fn{lc $sort_by})) {
	$self->{'_iterator_array_ref'} =
	    [ sort $sort_function @{$self->{'_orig_array_ref'}} ];
    }
    else  {
            #order by tag derived value
                $self->{'_iterator_array_ref'}=   [ sort { $a->tag($self->{_sort_by}) cmp $b->tag( $self->{_sort_by}) ||
			 $a->class() cmp $b->class()     ||
			 $a->ID()    cmp $b->ID()   
		       } @{$self->{'_orig_array_ref'}} ] || $self->throw("Cannot sort ".ref($self)." object by '$sort_by'.");
    }
}
