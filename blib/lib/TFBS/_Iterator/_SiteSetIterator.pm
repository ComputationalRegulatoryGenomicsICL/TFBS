package TFBS::_Iterator::_SiteSetIterator;

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
	(start => sub  { $a->start() <=> $b->start() 
			 || $a->pattern->name() cmp $b->pattern->name()
			 || $a->strand() <=> $b->strand()
		       },
	 end   => sub  { $a->end()   <=> $b->end()   
			 || $a->pattern->name() cmp $b->pattern->name()
			 || $a->strand() <=> $b->strand()
		       },
	 ID  => sub  { $a->pattern->ID() cmp $b->pattern->ID()
			 || $a->start() <=> $b->start() 
			 || $a->end()   <=> $b->end()   
			 || $a->strand() <=> $b->strand()
		       },
	 name  => sub  { $a->pattern->name() cmp $b->pattern->name()
			 || $a->start() <=> $b->start() 
			 || $a->end()   <=> $b->end()   
			 || $a->strand() <=> $b->strand()
		       },
	 score => sub {  $b->score()   <=> $a->score()
			 || $a->pattern->name() cmp $b->pattern->name()
			 || $a->strand() <=> $b->strand()
		      }
	);
			 
    if (defined (my $sort_function = $sort_fn{lc $sort_by})) {
	$self->{'_iterator_array_ref'} =
	    [ sort $sort_function @{$self->{'_orig_array_ref'}} ];
    }
    else  {
	$self->throw("Cannot sort ".ref($self)." object by '$sort_by'.");
    }
}
