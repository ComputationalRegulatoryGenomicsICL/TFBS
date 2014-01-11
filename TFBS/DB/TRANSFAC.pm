# TFBS module for TFBS::DB::TRANSFAC
#
# Copyright Boris Lenhard
# 
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::DB::TRANSFAC - interface to database of TRANSFAC public
position frequency matrices at TESS (http://www.cbil.upenn.edu/tess)

 -------------------------------- NOTICE ----------------------------------
  The TRANSFAC database is free for non-commercial use.  For commercial use
  the TRANSFAC databases and programs have to be licensed. Please read 
  the DISCLAIMER at http://transfac.gbf.de/TRANSFAC/disclaimer.htm.
 -------------------------------------------------------------------------

=head1 SYNOPSIS

=over 4

=item * creating a database object by connecting to TRANSFAC data

    my $db = TFBS::DB::TRANSFAC->connect();

=item * retrieving a TFBS::Matrix::* object from the database

    # retrieving a PFM by ID
    my $pfm = $db->get_Matrix_by_ID('V$CEBPA_01','PFM');
 
    #retrieving a PWM by TRANSFAC accession number
    my $pwm = $db->get_Matrix_by_acc('M00116', 'PWM');

=back

=head1 DESCRIPTION

TFBS::DB::TRANSFAC is a read only database interface that fetches
TRANSFAC matrix data from TESS web interface
(http://www.cbil.upen.edu/TESS) and returns TFBS::Matrix::* objects.

=cut

package TFBS::DB::TRANSFAC;

use vars qw(@ISA $ua);
use strict;
use Bio::Root::Root;
use TFBS::Matrix::PFM;
use LWP::Simple qw($ua get);

@ISA = qw(TFBS::DB Bio::Root::Root);

=head2 connect

 Title   : connect
 Usage   : my $db = TFBS::DB::TRANSFAC->connect(%args);
 Function: Creates a TRANSFAC database connection object, which can be used
           to retrieve matrices from public TRANSFAC databases via the web
 Returns : a TFBS::DB::TRANSFAC object
 Args    : -proxy # OPTIONAL: a http proxy server name, 
                  # usually required for accessing TRANSFAC from behind 
                  # a firewall
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
    my $self = bless {}, ref $caller || $caller;
    
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
    if (defined $args{'-proxy'}) {
	$ua->proxy('http',$args{'-proxy'});
    }
    return $self;
}

=head2 new

 Title   : connect
 Usage   : my $db = TFBS::DB::TRANSFAC->connect(%args);
 Function: Here, I<new> is just a synonim for I<connect>
           (to make the interface consistent with other
            bioperl read-obly Bio::DB::* objects)
 Returns : a TFBS::DB::TRANSFAC object
 Args    : -accept_conditions # see explanation at I<new>

=cut


sub new  {
    my ($caller, %args) = @_;
    $caller->connect(%args);
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
    my $url = "http://www.cbil.upenn.edu/cgi-bin/tess/tess33?request=MTX-DBRTRV-Id&key=$ID";
    # my $url = "http://www.cbil.upenn.edu/cgi-bin/tess/tess33?request=MTX-DBRTRV-Id&key=$ID";
    return $self->_get_Matrix_by_URL($url,  $mt);

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

    my $url = "http://www.cbil.upenn.edu/cgi-bin/tess/tess33?request=MTX-DBRTRV-Accno&key=$acc";
    return $self->_get_Matrix_by_URL($url,  $mt);
}

sub get_MatrixSet {
    my ($self, %args) = @_;
    # not yet implemented
}

sub _get_Matrix_by_URL  {
    my ($self, $url, $mt) = @_;
    my $HTMLpage = get $url || return undef;
    my (@As, @Cs, @Gs, @Ts, $name, $ID, $acc);
    my @lines = split "\n", $HTMLpage;
    foreach my $line (@lines)  {
        $line =~ s/\r//;
        $line =~ s/<\/{0,1}b>//gi;
        $line =~ s/&nbsp;//gi;
        if ($line =~ /Name<\/td><td>([^<]+)</)  {
            $name = $1;
        }
        elsif ($line =~ /ID<\/td><td>([^<]+)</)  {
	    
            $ID = $1;
        }
        elsif ($line =~ /AccNo\/Logo<\/td><td>([^<]+)</)  { 
            $acc = $1;
        }
        elsif ($line =~ /\d+\.\d+\s+(\d+\.\d+)\s+(\d+\.{0,1}\d*)\s+(\d+\.{0,1}\d*)\s+(\d+\.{0,1}\d*)\s+(\d+\.{0,1}\d*)/)  {
            my ($nr, $A, $C, $G, $T) = ($1,$2,$3,$4,$5); #split /\s+/, $line;
            push @As,$A; push @Cs,$C; push @Gs,$G; push @Ts,$T; 
        }
    }
    return undef unless @As;
    my $pfm = TFBS::Matrix::PFM-> new ( -ID     => $ID,
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
