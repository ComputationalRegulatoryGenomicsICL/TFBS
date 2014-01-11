package TFBS::Tools::SetOperations;
use strict;

use Bio::Root::Root;
use vars qw'@ISA';
@ISA = qw'Bio::Root::Root';


sub new  {
    my ($caller, @args) = @_;
    my $self = bless {}, ref $caller || $caller;
    my ($index_by, $strict, $output_type, $pairs) =
        $self->_rearrange([qw'INDEX_BY STRICT OUTPUT_TYPE PAIRS'], @args);
    $self->index_by($index_by);
    $self->strict($strict);
    $self->output_type($output_type);
    $self->pairs($pairs);
    return $self;
}


sub union {
    my ($self, @sets) = @_;
    my %union_index =
        map {$self->_index($_)} $self->_sets_to_arrayrefs(@sets);
    $self->_output(\%union_index);
}


sub intersection  {
    my ($self, @sets) = @_;

    my @set_arrayrefs = $self->_sets_to_arrayrefs(@sets);
    #this would be faster, but we might want to retain the exact objects
    # that were present in
    #my @set_arrayrefs = sort {@$a <=> @$b} $self->_sets_to_arrayrefs(@sets);

    my %intersection_index = $self->_index(shift @set_arrayrefs);
    foreach my $set_arrayref (@set_arrayrefs) {
        my %curr_set_index = $self->_index($set_arrayref);
        my @help_array = %curr_set_index;
        
        foreach my $key (keys %intersection_index) {

            if (!exists $curr_set_index{$key}) {
            	delete $intersection_index{$key} ;
            }
        }
    }
    $self->_output(\%intersection_index);
}


sub difference  {
    # pairs only for now
    my ($self, @sets) = @_;
    my ($set1, $set2) = $self->_sets_to_arrayrefs(@sets);
    if (!defined $set2) {
        $self->throw ("'difference' needs exactly two sets as arguments");
    }
    my %diff_index1 = $self->_index($set1);
    my %diff_index2 = $self->_index($set2);
    foreach my $key (keys %diff_index1) {
        if (exists $diff_index2{$key})  {
            delete $diff_index1{$key};
            delete $diff_index2{$key};
        }
    }
    wantarray ? ($self->_output(\%diff_index1), $self->_output(\%diff_index2))
              : $self->_output(\%diff_index1);
}


sub index_by {
    my $self = shift;

    # By default, we are dealing with Bio::SeqFeatureI objects
    my @DEFAULTS = qw(primary_tag source_tag start end score strand);
    if (@_) {
        if(!defined $_[0]) {
            $self->{_index_by} = \@DEFAULTS;
        }
        elsif (ref($_[0]) eq "ARRAY") {
            $self->{_index_by} = $_[0];
        }
        else {
            $self->{_index_by} = [@_];
        }
    }
    return @{$self->{_index_by}};
}


sub strict  {
    my $self = shift;
    if (@_)  {
        if ($self->{_strict} = shift) {
            $self->{_index_fn} = \&_index_strict;
        }
        else {
            $self->{_index_fn} = \&_index_by_annotation;
        }
    }
    return $self->{_strict};
}


sub output_type  {
    my $self = shift;
    if (@_)  {
        unless ($self->{_output_type} = shift) {
            $self->{_output_type} = "arrayref"
        }
    }
    return $self->{_output_type};
}

sub pairs  {
    my $self = shift;
    if (@_)  {
        if ($self->{_pairs} = shift and !$self->strict) {
            $self->{_index_fn} = \&_index_by_pair_annotation;
        }
    }
    return $self->{_pairs};
}

sub _index {
    my ($self) = @_;
    $self->{_index_fn}->(@_);
}


sub _index_strict  {
    my ($self, $set_arrayref) = @_;
    my %index_hash = (map {$_, $_} @$set_arrayref);
    return %index_hash;
}


sub _index_by_pair_annotation {
    my ($self, $set_arrayref) = @_;
    my %index_hash;
    foreach my $member (@$set_arrayref)  {
        my @index_elements = ($self->_get_index_elements($member->feature1),
                              $self->_get_index_elements($member->feature2));
        $index_hash{join("::", @index_elements)} = $member;
    }
    return %index_hash;
}


sub _index_by_annotation  {
    my ($self, $set_arrayref) = @_;
    my %index_hash;
    foreach my $member (@$set_arrayref)  {
        my @index_elements = $self->_get_index_elements($member);
        $index_hash{join("::", @index_elements)} = $member;
    }
    return %index_hash;
}

sub _get_index_elements {
    my ($self, $set_member) = @_;
    my @index_elements;
    foreach my $method ($self->index_by)  {
        if (ref($method) eq 'CODE') {
            push @index_elements, $method->($set_member);
        }
        else  {
            eval { push @index_elements, $set_member->$method; };
            if ($@) {
                $self->throw(sprintf("Could not use '%s' for indexing a %s object. The original error was:\n",
                                     $method, ref($set_member)).$@)
            }
       }
    }
    return @index_elements;
}


sub _sets_to_arrayrefs  {
    my ($self, @sets) = @_;
    my @set_arrayrefs;
    foreach my $set (@sets) {
        if (ref($set) eq "ARRAY") {
            push @set_arrayrefs, $set;
        }
        elsif(ref($set) and $set->can("Iterator")) {
            my @set_elements;
            my $it = $set->Iterator;
            while (my $set_el = $it->next) { push @set_elements, $set_el }
            push @set_arrayrefs, \@set_elements;
        }
        else  {
            $self->throw("Set must be an aray reference or have an ".
                         "Iterator method. Got ".(ref($set or $set)). "instead.");
        }
    }
    return @set_arrayrefs;
}

sub _output {
    my ($self, $hashref) = @_;
    if ($self->output_type eq "arrayref")  {
        return [values %$hashref];
    }
    elsif ($self->output_type eq "array") {
        return %$hashref;
    }
    elsif ($self->output_type eq "matrix_set")  {
        my $setobj = TFBS::MatrixSet->new;
        $setobj->add_Matrix(values %$hashref);
        return $setobj;
    }
    elsif ($self->output_type eq "site_set")  {
        my $setobj = TFBS::SiteSet->new;
        $setobj->add_site(values %$hashref);
        return $setobj;
    }
    else {
        $self->throw($self->output_type." is not a supported output type");
    }

}
1;
