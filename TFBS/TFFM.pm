# TFBS module for TFBS::TFFM
#
# You may distribute this module under the same terms as perl itself
#
# Date:   2015/10/06
#

# POD

=head1 NAME

TFBS::TFFM - class for Transcription Factor Flexible Models (TFFMs)

=head1 DESCRIPTION

TFBS::TFFM is a class to hold basic information about a TFFM. It was
mainly designed to store the information about a TFFM stored in the
TFFM table of the JASPAR DB newly introduced in the JASPAR 2016 version.
It does NOT (currently) store the actual XML describing the the model but
this would be simple to add. At the time of this writing the relationship 
between JASPAR matrices as stored in the MATRIX table and TFFMs was not
completely clear and the matrix IDs related to a TFFM are stored in the
TFFM table. The relationship could be 1:n, m:1 or m:n in the future so
this may well be changed and a joining table created to facilitate this.

=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - David Arenillas

David Arenillas: dave@cmmt.ubc.ca

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut


# The code begins HERE:

package TFBS::TFFM;

use strict;

sub new
{
    my $class = shift;
    my %args = @_;
    my $self = bless {}, ref($class) || $class;

    $self->{'ID'}               = $args{-ID} || "Unknown";
    $self->{'name'}             = $args{-name} || "Unknown";
    $self->{'matrix_ID'}        = $args{-matrix_ID};
    $self->{'log_p_1st_order'}  = $args{-log_p_1st_order};
    $self->{'log_p_detailed'}   = $args{-log_p_detailed};
    $self->{'experiment_name'}  = $args{-experiment_name};

    # The JASPAR matrix related to this TFFM
    my $matrix = $args{-matrix};
    if ($matrix) {
        if ($matrix->ISA('TFBS::Matrix')) {
            $self->{'matrix'} = $matrix;
        } else {
            $self->throw(
                "Provided -matrix argument does not refer to a TFBS::Matrix"
                . " object"
            );
        }
    }
    
    return $self;
}


=head2 ID

 Title   : ID
 Usage   : my $id = $tffm->ID();

 Function: Get/set the ID of this TFFM.
 Returns : The ID of this TFFM.
 Args    : None for get or a new string ID.

=cut

sub ID
{
    my ($self, $id) = @_;

    if ($id) {
        $self->{ID} = $id;
    }

    return $self->{ID};
}


=head2 name

 Title   : name
 Usage   : my $name = $tffm->name();

 Function: Get/set the name of the transcription factor for which this TFFM
           was modelled.
 Returns : Name of the TF modelled by this TFFM.
 Args    : None for get or a new string TF name.

=cut

sub name
{
    my ($self, $name) = @_;

    if ($name) {
        $self->{name} = $name;
    }

    return $self->{name};
}


=head2 experiment_name

 Title   : experiment_name
 Usage   : my $filename = $tffm->experiment_name();

 Function: Get/set the name of the experimental data on which this TFFM
           (generally ChIP-seq peak data) TFFM was trained. Often this
           is base file name of ChIP-seq peaks file.
 Returns : Name of the experiment/datafile.
 Args    : None for get or a new experiment/datafile name.

=cut

sub experiment_name
{
    my ($self, $exp_name) = @_;

    if ($exp_name) {
        $self->{experiment_name} = $exp_name;
    }

    return $self->{experiment_name};
}


=head2 log_p_1st_order

 Title   : log_p_1st_order
 Usage   : my $log_p_val = $tffm->log_p_1st_order();

 Function: Get/set the log(p) value for the 1st order model of this TFFM.
 Returns : Log(p) value of the 1st-order model.
 Args    : None for get or a new 1st-order log(p) value.

=cut

sub log_p_1st_order
{
    my ($self, $log_p_val) = @_;

    if ($log_p_val) {
        $self->{log_p_1st_order} = $log_p_val;
    }

    return $self->{log_p_1st_order};
}


=head2 log_p_detailed

 Title   : log_p_detailed
 Usage   : my $log_p_val = $tffm->log_p_detailed();

 Function: Get/set the log(p) value for the detailed model of this TFFM.
 Returns : Log(p) value of the detailed model.
 Args    : None for get or a new detailed log(p) value.

=cut

sub log_p_detailed
{
    my ($self, $log_p_val) = @_;

    if ($log_p_val) {
        $self->{log_p_detailed} = $log_p_val;
    }

    return $self->{log_p_detailed};
}


=head2 matrix_ID

 Title   : matrix_ID
 Usage   : my $matrix_id = $tffm->matrix_ID();

 Function: Get/set the ID of the matrix associated to this TFFM.
 Returns : ID of the matrix associated to this TFFM.
 Args    : None for get or a JASPAR matrix ID.

=cut

sub matrix_ID
{
    my ($self, $matrix_id) = @_;

    if ($matrix_id) {
        $self->{matrix_ID} = $matrix_id;
    }

    return $self->{matrix_ID};
}


=head2 matrix

 Title   : matrix
 Usage   : my $matrix = $tffm->matrix();

 Function: Get/set the matrix object related to this TFFM
 Returns : A reference to TFBS::Matrix object which was used to train the
           TFFM.
 Args    : None for get or a new TFBS::Matrix object reference.

=cut

sub matrix
{
    my ($self, $matrix) = @_;

    if ($matrix) {
        if ($matrix->ISA("TFBS::Matrix")) {
            $self->{matrix} = $matrix;
        } else {
            $self->throw(
                "Provided matrix argument does not refer to a TFBS::Matrix"
                . " object"
            );
        }
    }

    return $self->{'matrix'};
}

1;
