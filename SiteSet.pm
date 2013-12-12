# TFBS module for TFBS::SiteSet
#
# Copyright Boris Lenhard
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::SiteSet - a set of TFBS::Site objects

=head1 SYNOPSIS

    my $site_set = TFBS::SiteSet->new(@list_of_site_objects);

    # add a TFBS::Site object to set:
    
    $site_set->add_site($site_obj);

    # append another TFBS::SiteSet contents: 

    $site_pair_set->add_site_set($site_obj);

    # create an iterator:

    my $it = $site_set->Iterator(-sort_by => 'start');



=head1 DESCRIPTION

TFBS::SiteSet is an aggregate class that contains a collection
of TFBS::Site objects. It can be created anew and filled with 
TFBS::Site object. It is also returned by search_seq() method call 
of some TFBS::PatternI subclasses (e.g. TFBS::Matrix::PWM).

=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut



# The code begins HERE:


package TFBS::SiteSet;

use vars qw(@ISA $AUTOLOAD);
use TFBS::Site;
use TFBS::_Iterator::_SiteSetIterator;
use strict;
@ISA = qw(Bio::Root::Root);

sub new  {
    my ($class, @data) = @_;
    my $self = bless {}, ref($class) || $class;
    $self->{_site_array_ref} = [];
    @data = @{$class->{site_list}} if !@data && ref($class);
    $self->add_site(@data);
    return $self;
}



=head2 add_site

 Title   : add_site
 Usage   : $siteset->add_site($site_object)
           $siteset->add_site(@list_of_site_objects)
 Function: adds TFBS::Site objects to an existing TFBS::SiteSet object
 Returns : $sitepair object (usually ignored)
 Args    : A list of TFBS::Site objects to add

=cut



sub add_site {
    my ($self, @site_list)  = @_;
    foreach my $site (@site_list)  {
	ref($site) =~ /TFBS::Site*/ 
	    or $self->throw("Attempted to add an element ".
			     "of a wrong type.");
	push @{$self->{_site_array_ref}},  $site;
    }
    return 1;
}


=head2 add_site_set

 Title   : add_site_set
 Usage   : $siteset->add_site_set($site_set_object)
           $siteset->add_site(@list_of_site_set_objects)
 Function: adds the contents of other TFBS::SiteSet objects 
           to an existing TFBS::SiteSet object
 Returns : $siteset object (usually ignored)
 Args    : A list of TFBS::SiteSet objects whose contents should be 
           added to $siteset

=cut


sub add_siteset {
    my ($self, @sitesets) = @_;
    foreach my $siteset (@sitesets)  {
	ref($siteset) =~ /TFBS::Site.*Set/ 
	    or $self->throw("Attempted to add an element ".
			    "that is not a TFBS::SiteSet object.");
	push @{$self->{_site_array_ref}},
	     @{ $siteset->{_site_array_ref} };
    }
    return $self;
}
	

=head2 size

 Title   : size
 Usage   : my $size = $siteset->size()
 Function: returns a number of TFBS::Site objects contained in the set
 Returns : a scalar (integer) 
 Args    : none

=cut



sub size  {
    scalar @{ $_[0]->{_site_array_ref} };
}



=head2 Iterator

 Title   : Iterator
 Usage   : my $siteset_iterator = 
                   $siteset->Iterator(-sort_by =>'start');
           while (my $site = $siteset_iterator->next) {
	       # do whatever you want with individual matrix objects
	   }
 Function: Returns an iterator object that can be used to go through
           all members of the set (TFBS::Site objects)
 Returns : an iterator object (currently undocumentened in TFBS -
			       but understands the 'next' method)
 Args    : -sort_by # optional - currently it accepts 
                    #   (default sort order in parenthetse)
                    #    'name' (pattern name, alphabetically)
                    #    'ID' (pattern/matrix ID, alphabetically)
                    #    'start' (site start in sequence, 
                    #             numerically,increasing order)
                    #    'end' (site end in sequence, 
                    #           numerically, increasing order)
                    #    'score' (numerically, decreasing order)
                    
           -reverse # optional - reverses the default sorting order if true

=cut



sub Iterator  {

    my ($self, %args) = @_;
    return TFBS::_Iterator::_SiteSetIterator->new($self->{_site_array_ref},
				$args{'-sort_by'},
				$args{'-reverse'}
			       );
}


sub all_sites  {
    my ($self,%args) = @_;
    return @{$self->{_site_array_ref}} if @{$self->{_site_array_ref}};

}


=head2 GFF

 Title   : GFF
 Usage   : print $siteset->GFF();
         : print $siteset->GFF($gff_formatter)
 Function: returns a "standard" multiline GFF string 
 Returns : a string (multiline, newline terminated)
 Args    : a $gff_formatter function reference (optional)

=cut


sub GFF  {
    my ($self, %args) = @_;
    my $site_iterator = $self->Iterator(-sort_by=>'start');
    my $gff_string = "";
    while (my $site = $site_iterator->next())  {
	$gff_string .= $site->GFF(%args)."\n";
    }
    
    return $gff_string;
}



########################################################
# OBSOLETE METHODS
########################################################

sub old_GFF  {
    eval "require GFF::GeneFeatureSet;";
    if ($@) { print STDERR "Failed to load GFF modules, stopped"; return; }
    my ($self) = @_;
    my $site_iterator = $self->Iterator(-sort_by=>'start');
        my $GFFset = GFF::GeneFeatureSet->new(2);
    while (my $site = $site_iterator->next())  {
	$GFFset->addGeneFeature($site->GFF());
    }
    return $GFFset;
}



##############################################################
# PRIVATE AND AUTOMATIC METHODS
##############################################################



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

