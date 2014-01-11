# TFBS module for TFBS::SitePairSet
#
# Copyright Boris Lenhard
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::SitePairSet - a set of TFBS::SitePair objects

=head1 SYNOPSIS

    my $site_pair_set = TFBS::SitePairSet->new(@list_of_site_pair_objects);

    # add a TFBS::SitePair object to set:
    
    $site_pair_set->add_site_pair($site_pair_obj);

    # append another TFBS::SitePairSet contents: 

    $site_pair_set->add_site_pair_set($site_pair_obj);

    # create an iterator:

    my $it = $site_pair_set->Iterator(-sort_by => 'start');



=head1 DESCRIPTION

TFBS::SitePairSet is an aggregate class that contains a collection
of TFBS::SitePair objects. It can be created anew and filled with 
TFBS::Site::Pair object. It is also returned by search_aln() method call 
of TFBS::PatternI subclasses (e.g. TFBS::Matrix::PWM).

=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut


# The code begins HERE:


package TFBS::SitePairSet;
use vars qw(@ISA $AUTOLOAD);
use strict;

use TFBS::SitePair;
use TFBS::_Iterator::_SiteSetIterator;
@ISA = qw(Bio::Root::Root);



sub new  {


    my ($class, @data) = @_;
    my $self = bless {}, ref($class) || $class;
    $self->{_site_array_ref} = [];
    @data = @{$class->{_site_array_ref}} if !@data && ref($class);
    $self->add_site_pair(@data);
    return $self;
}

=head2 size

 Title   : size
 Usage   : my $size = $sitepairset->size()
 Function: returns a number of TFBS::SitePair objects contained in the set
 Returns : a scalar (integer) 
 Args    : none

=cut

sub size  {
    scalar @{ $_[0]->{_site_array_ref} };
}


=head2 add_site_pair

 Title   : add_site_pair
 Usage   : $sitepairset->add_site_pair($site_pair_object)
           $sitepairset->add_site_pair(@list_of_site_pair_objects)
 Function: adds TFBS::SitePair objects to an existing TFBS::SitePairSet object
 Returns : $sitepairset object (usually ignored)
 Args    : A list of TFBS::SitePair objects to add

=cut


sub add_site_pair {
    my ($self, @site_list)  = @_;
    foreach my $site (@site_list)  {
	$site->isa("TFBS::SitePair") 
	    or $self->throw("Attempted to add an element ".
			     "of a wrong type.");
	push @{$self->{_site_array_ref}},  $site;
    }
    return 1;
}



=head2 add_site_pair_set

 Title   : add_site_pair_set
 Usage   : $sitepairset->add_site_pair_set($site_pair_set_object)
           $sitepairset->add_site_pair(@list_of_site_pair_set_objects)
 Function: adds the contents of other TFBS::SitePairSet objects 
           to an existing TFBS::SitePairSet object
 Returns : $sitepairset object (usually ignored)
 Args    : A list of TFBS::SitePairSet objects whose contents should be 
           added to $sitepairset

=cut


sub add_site_pair_set {
    my ($self, @sitesets) = @_;
    foreach my $siteset (@sitesets)  {
	$siteset->isa("TFBS::SitePairSet") 
	    or $self->throw("Attempted to add an element ".
			    "that is not a TFBS::SiteSet object.");
	push @{$self->{_site_array_ref}},
	     @{ $siteset->{_site_array_ref} };
    }
    return $self;
}
	

=head2 Iterator

  Title   : Iterator
  Usage   : my $it = $sitepairset->Iterator(-sort_by=>'start');
            while (my $site_pair = $it->next()) { #... 
  Function: Returns an iterator object, used to iterate thorugh elements 
            (TFBS::SitePair objects)
  Returns : a TFBS::_Iterator object
  Args    : -sort_by # optional - currently it accepts 
                    #   (default sort order in parenthetse)
                    #    'name' (pattern name, alphabetically)
                    #    'ID' (pattern/matrix ID, alphabetically)
                    #    'start' (site start in sequence, 
                    #             numerically,increasing order)
                    #    'end' (site end in sequence, 
                    #           numerically, increasing order)
                    #    'score' (1st site in pair,
                    #             numerically, decreasing order)
            -reverse # optional - reverses the default sorting order if true

=cut


sub Iterator  {
    my ($self, %args) = @_;
    return TFBS::_Iterator::_SiteSetIterator->new($self->{_site_array_ref},
				$args{'-sort_by'},
				$args{'-reverse'}
			       );
}



=head2 set1

=head2 set2

  Title   : set1
            set2
  Usage   : my $siteset1 = $sitepairset->set1();
          : my $siteset2 = $sitepairset->set2()
  Function: Returns individual TFBS::SiteSet objects, from the site set pair
  Returns : A TFBS::SiteSet object
  Args    : none

=cut


sub set1  {
    $_[0]->_get_set(1);
}

sub set2  {
    $_[0]->_get_set(2);
}


=head2 GFF

 Title   : GFF
 Usage   : print $site->GFF();
         : print $site->GFF($gff_formatter)
 Function: returns a "standard" multiline GFF string 
 Returns : a string (multiline, newline terminated)
 Args    : a $gff_formatter function reference (optional)

=cut


sub GFF  {
    my ($self, %args) = @_;
    my $iterator = $self->Iterator(-sort_by=>'start');
    my $gff_string = "";
    while (my $sitepair = $iterator->next())  {
	$gff_string .= $sitepair->GFF(%args)."\n";
    }
    
    return $gff_string;
}

##############################################################
# PRIVATE AND AUTOMATIC METHODS
##############################################################

sub _get_set  {
    my ($self, $set_nr) = @_;
    my $feature = "feature$set_nr";
    my $it = $self->Iterator();
    my $siteset = TFBS::SiteSet->new();
    no strict 'refs';
    while (my $site_pair = $it->next())  {
	eval "$siteset->add_site(\$site_pair->$feature())";
    }
    return $siteset;
}


sub AUTOLOAD  {
    my ($self) = @_;
    my %discontinued = (sort => 1,
			sort_by_name => 1,
			sort_reversed => 1,
			reverse => 1,
			next_site => 1,
			reset => 1
			);
    $AUTOLOAD =~ /.+::(\w+)/;
    if ($discontinued{$1})  {
	$self->_no_more($1);
    }
    else  {
	$self->throw("$1: no such method");
    }
}

sub _no_more  {
    $_[0]->throw("Method '$_[1]' is no longer available in ". 
		 ref($_[0]).". Use the 'Iterator' method instead.");
}

1;




