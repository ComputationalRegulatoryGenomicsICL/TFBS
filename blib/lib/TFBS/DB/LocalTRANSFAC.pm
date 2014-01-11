# TFBS module for TFBS::DB::LocalTRANSFAC
#
# Copyright Stephen Montgomery smontgom@bcgsc.bc.ca
#
# Contributors: Boris Lenhard, Leonardo Marino-Ramirez
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::DB::LocalTRANSFAC - interface to local transfac database
position frequency matrices (matrix.dat)

 -------------------------------- NOTICE ----------------------------------
  The TRANSFAC database is free for non-commercial use.  For commercial use
  the TRANSFAC databases and programs have to be licensed. Please read
  the DISCLAIMER at http://transfac.gbf.de/TRANSFAC/disclaimer.htm.
 -------------------------------------------------------------------------

=head1 SYNOPSIS

=over 4

=item * creating a database object by connecting to TRANSFAC data

    my $db = TFBS::DB::LocalTRANSFAC->connect(-localdir => '/home/someusr');

    localdir is the location of the matrix.dat TRANSFAC datafile

=item * retrieving a TFBS::Matrix::* object from the database

    # retrieving a PFM by ID
    my $pfm = $db->get_Matrix_by_ID('V$CEBPA_01','PFM');

    #retrieving a PWM by TRANSFAC accession number
    my $pwm = $db->get_Matrix_by_acc('M00116', 'PWM');

=back

=head1 DESCRIPTION

TFBS::DB::LocalTRANSFAC is a read only database interface that fetches
TRANSFAC matrix data from a local TRANSFAC install (matrix.dat)

=cut

package TFBS::DB::LocalTRANSFAC;

use vars qw(@ISA);
use strict;
use TFBS::DB::TRANSFAC;
use TFBS::Matrix::PFM;

@ISA = qw(TFBS::DB::TRANSFAC);

=head2 connect

 Title   : connect
 Usage   : my $db = TFBS::DB::TRANSFAC->connect(%args);
 Function: Creates a TRANSFAC database connection object, which can be used
           to retrieve matrices from a locally installed TRANSFAC database
 Returns : a TFBS::DB::TRANSFAC object
 Args    : -localdir 	# REQUIRED: the directory of the matrix.dat TRANSFAC
                  	# datafile.  matrix.dat must have read access.
           -accept_conditions # OPTIONAL: by setting this to a true
                              # value, you confirm that you
                              # have read and accepted the terms
                              # of use of TRANSFAC at
                              # http://transfac.gbf.de/TRANSFAC/disclaimer.htm;
                              # this also supresses the annoying
                              # message that is printed to STDERR
                              # upon invoking the method

=cut

sub connect  {
    my ($caller, %args) = @_;
    my $self = bless { 'loc' => $args{'-localdir'}}, ref $caller || $caller;

    unless (defined ($args{-accept_conditions}) and $args{-accept_conditions}) {
        print STDERR <<ENDNOTICE
    -------------------------------- NOTICE ----------------------------------
    The TRANSFAC database is free for non-commercial use.  For commercial use
    the TRANSFAC databases and programs have to be licensed. Please read
    the DISCLAIMER at http://transfac.gbf.de/TRANSFAC/disclaimer.htm.
                                    -----------
    If you have read the disclaimer and accept the conditions stated therein,
    you can suppres this notice by connecting to TRANSFAC like this:
         my \$db = TFBS::DB::TRANSFAC->connect(-accept_conditions => 1);
    --------------------------------------------------------------------------
ENDNOTICE
;
    }
    unless (defined $args{-localdir}) {
	$self->throw("Need directory of TRANSFAC database");
    }

    return $self;
}

=head2 get_Matrix_by_acc

 Title   : get_Matrix_by_acc
 Usage   : my $pfm = $db->get_Matrix_by_acc('V$CREB_01', 'PFM');
 Function: fetches matrix data under the given TRANSFAC aaccession number
	   from database and returns a TFBS::Matrix::* object
 Returns : a TFBS::Matrix::* object; the exact type of the
	   object depending on the second argument (allowed
	   values are 'PFM', 'ICM', and 'PWM'); returns undef if
	   matrix with the given ID is not found
 Args    : (Matrix_ID, Matrix_type)
	   Matrix_ID is a string; Matrix_type is one of the
	   following: 'PFM' (raw position frequency matrix),
	   'ICM' (information content matrix) or 'PWM' (position
	   weight matrix)
	   If Matrix_type is omitted, a PFM is retrieved by default.

=cut

sub get_Matrix_by_acc  {
    my ($self, $acc, $mt) = @_;
    unless (defined $acc)  {
        $self->throw("No parameters passed to get_Matrix_by_ID.");
    }

    my $datablock = _get_Matrix_Block (	'acc' => $acc,
    					'loc' => $self->{'loc'});

    return $self->_get_Matrix_by_Block($datablock,  $mt);
}

=head2 get_Matrix_by_ID

 Title   : get_Matrix_by_ID
 Usage   : my $pfm = $db->get_Matrix_by_ID('V$CREB_01', 'PFM');
 Function: fetches matrix data under the given TRANSFAC ID from the
           database and returns a TFBS::Matrix::* object
 Returns : a TFBS::Matrix::* object; the exact type of the
	   object depending on the second argument (allowed
	   values are 'PFM', 'ICM', and 'PWM'); returns undef if
	   matrix with the given ID is not found
 Args    : (Matrix_ID, Matrix_type)
	   Matrix_ID is a string; Matrix_type is one of the
	   following: 'PFM' (raw position frequency matrix),
	   'ICM' (information content matrix) or 'PWM' (position
	   weight matrix)
	   If Matrix_type is omitted, a PFM is retrieved by default.

=cut

sub get_Matrix_by_ID  {
    my ($self, $ID, $mt) = @_;
    unless (defined $ID)  {
        $self->throw("No parameters passed to get_Matrix_by_ID.");
    }

    my $datablock = _get_Matrix_Block (	'ID' => $ID,
    					'loc' => $self->{'loc'});

    return $self->_get_Matrix_by_Block($datablock,  $mt);

}

sub _get_Matrix_Block {
	my %params = @_;
 	my $loc = $params{'loc'};
  	my $acc = $params{'acc'};
   	my $ID = $params{'ID'};

   	$loc = $loc . "/matrix.dat";
   	open(HANDLE, $loc) || die ("File opening failed for matrix.dat: Check file permissions");
   	my @raw_data=<HANDLE>;

	my @block = ();
	my $hit = 0;

	foreach my $line (@raw_data)
	{
		if ($line eq "//\n")
		{
			foreach my $lineinblock (@block)
			{
				if (defined $ID) {
					if ($lineinblock eq "ID  $ID\n") { $hit = 1 };
				}
				if (defined $acc) {
					if ($lineinblock eq "AC  $acc\n") { $hit = 1 };
				}
			}
			if ($hit == 0) { @block = (); }
		}
		if ($hit == 0) { push @block, $line; }
	}

	close(HANDLE);
	return \@block;
}


sub _get_Matrix_by_Block  {
	my ($self, $datablock, $mt) = @_;
        my @datalines = @$datablock;
    	my (@As, @Cs, @Gs, @Ts, $name, $ID, $acc);

    	foreach my $line (@datalines)
    	{
    		if ($line =~ /NA\s+(\S+)\n/) {
			$name = $1;
		}
    		if ($line =~ /ID\s+(\S+)\n/) {
			$ID = $1;
		}
    		if ($line =~ /AC\s+(\S+)\n/) {
			$acc = $1;
		}
		#if ($line =~ /\d{2}\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\n/)  {
		# change to allow for both older and newer file format
		# contributed by Leonardo Marino-Ramirez:
		# Updated 2003-09-05 to enable parsing of non-integer entries

		if ($line =~ /^\d{2}\s+(\d+\.?\d*)\s+(\d+\.?\d*)\s+(\d+\.?\d*)\s+(\d+\.?\d*).*$/) {
			push @As, $1;
			push @Cs, $2;
			push @Gs, $3;
			push @Ts, $4;
		}
    	}

	return undef unless @As;

    	my $pfm = TFBS::Matrix::PFM-> new ( 	-ID     => $ID,
                                        	-name   => $name,
                                        	-tags   => {acc=>$acc},
                                        	-matrix => [ \@As, \@Cs, \@Gs, \@Ts]
                                           );

    	if (!defined($mt) or uc($mt) eq "PFM") {return $pfm;}
    	elsif (uc($mt) eq "ICM") {return $pfm->to_ICM;}
    	elsif (uc($mt) eq "PWM") {return $pfm->to_PWM;}
    	else  {  $self->throw("Unrecognized matrix format: $mt");  }
}

1;
