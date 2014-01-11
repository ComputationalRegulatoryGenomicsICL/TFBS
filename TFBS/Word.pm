# TFBS module for TFBS::Word
#
# Copyright Boris Lenhard
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::Word - base class for word-based patterns

=head1 DESCRIPTION

TFBS::Word is a base class consisting of universal constructor called by
its subclasses (TFBS::Matrix::*), and word pattern manipulation methods that
are independent of the word type. It is not meant to be instantiated itself.

=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut



# The code begins HERE:

package TFBS::Word;
use vars '@ISA';

use TFBS::PatternI;

use strict;

@ISA = qw(TFBS::PatternI);

=head2 new

=cut

sub new  {
    my ($caller, @args) = @_;
    my $self = $caller->SUPER::new(@args);
    my ($id, $name, $class, $word, $tagref) = $self->_rearrange([qw(ID NAME CLASS
                                                            WORD TAGS)], @args);

    if   (defined $word) { $self->word($word); }
    else { $self->throw("Need a -word argument"); }
    $self->name($name);
    $self->ID($id);
    $self->{'tags'} = ($tagref or {});

    return $self;

}


=head2 word

=cut

sub word {
    my ($self, @args) = @_;
    if(scalar(@args) == 0)  {
        return $self->{'word'};
    }
    my ($word) = @args;

    if (defined $word and ! $self->validate_word($word)) {
        $self->throw("Trying to set the word to an invalid value: $word");

    }
    else {
        return $self->{'word'} = $word;
    }
}



=head2 validate_word

Required in all subclasses

=cut


sub validate_word {
    shift->throw("Error: method 'validate_word' not implemented");
}

=head2 length

=cut

sub length {
    # wird length does not have to be defined, but its subroutine does
    shift->throw("Error: method 'length' not implemented");

}


=head2 search_seq

=cut

sub search_seq  {
    shift->throw("Error: method search_seq not implemented");

}


=head2 search_aln

=cut

sub search_aln  {
    shift->throw("Error: method search_aln not implemented");
}


1;