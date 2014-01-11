# TFBS module for TFBS::PatternI
#
# Copyright Boris Lenhard
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::PatternI - interface definition for all pattern objects (currently
includes matrices and word (consensus and regular expressions )

=head1 DESCRIPTION

TFBS::PatternI is a draft class that should contain general interface for matrix and other (future) pattern objects. It is not defined and not used yet, as I need to ponder over certain unresolved issues in general pattern definition. User feedback is more than welcome.

=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut

# The code begins here:


# The code begins HERE:

package TFBS::PatternI;
use vars '@ISA';

use Bio::Root::Root;

use strict;

@ISA = qw(Bio::Root::Root);

#sub new  {

#}

=head2 ID

 Title   : ID
 Usage   : my $ID = $icm->ID()
           $pfm->ID('M00119');
 Function: Get/set on the ID of the pattern (unique in a DB or a set)
 Returns : pattern ID (a string)
 Args    : none for get, string for set

=cut

sub ID  {
    my ($self, $ID) = @_;
    $self->{'ID'} = $ID if $ID;
    return $self->{'ID'};
}


=head2 name

 Title   : name
 Usage   : my $name = $pwm->name()
           $pfm->name('PPARgamma');
 Function: Get/set on the name of the pattern
 Returns : pattern name (a string)
 Args    : none for get, string for set

=cut

sub name  {
    my ($self, $name) = @_;
    $self->{'name'} = $name if $name;
    return $self->{'name'};
}


=head2 class

 Title   : class
 Usage   : my $class = $pwm->class()
           $pfm->class('forkhead');
 Function: Get/set on the structural class of the pattern
 Returns : class name (a string)
 Args    : none for get, string for set

=cut


sub class  {
    my ($self, $class) = @_;
    $self->{'class'} = $class if $class;
    return $self->{'class'};
}

=head2 tag

 Title   : tag
 Usage   : my $acc = $pwm->tag('acc')
           $pfm->tag(source => "Gibbs");
 Function: Get/set on the structural class of the pattern
 Returns : tag value (a scalar/reference)
 Args    : tag name (string) for get,
	   tag name (string) and value (any scalar/reference) for set

=cut

sub tag {
    my $self = shift;
    my $tag = shift || return;
    if (scalar @_)  {
	$self->{'tags'}->{$tag} =shift;
    }
    return $self->{'tags'}->{$tag};
}


=head2 all_tags

 Title   : all_tags
 Usage   : my %tag = $pfm->all_tags();
 Function: get a hash of all tags for a matrix
 Returns : a hash of all tag values keyed by tag name
 Args    : none

=cut

sub all_tags {
    return %{$_[0]->{'tags'}};
}




=head2 delete_tag

 Title   : delete_tag
 Usage   : $pfm->delete_tag('score');
 Function: get a hash of all tags for a matrix
 Returns : nothing
 Args    : a string (tag name)

=cut


sub delete_tag {
    my ($self, $tag) = @_;
    delete $self->{'tags'}->{$tag};
}



1;
