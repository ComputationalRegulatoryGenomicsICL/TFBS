package TFBS::SitePair;

use vars qw(@ISA);
use strict;

use Bio::SeqFeature::FeaturePair;
@ISA = qw(Bio::SeqFeature::FeaturePair);

# 'new' used to be inherited, but we need it now

sub new  {
    my ($caller, $site1, $site2) = @_;
    #if ($Bio::Root::Root::VERSION < 1.4) {
	#return $caller->SUPER::new($site1, $site2);
    #}
    #else {
	return $caller->SUPER::new(-feature1 => $site1,
				   -feature2 => $site2);
    #}

    # ^ Version check commented out because from BioPerl 1.5.2
    #   version nrs are represented differently. // PE 2007-7-11
}


=head2 pattern

 Title   : pattern
 Usage   : my $pattern = $sitepair->pattern();  # gets the pattern
                                                # sets the pattern to $pwm
 Function: gets the pattern object associated with the site pair
 Returns : pattern object, here TFBS::Matrix::PWM object
 Args    : none (get-only method)

=cut


sub pattern  {
    $_[0]->feature1->pattern();
}


=head2 GFF

 Title   : GFF
 Usage   : print $site->GFF();
         : print $site->GFF($gff_formatter)
 Function: returns a "standard" multiline GFF string 
 Returns : a string (multiline, newline terminated)
 Args    : a $gff_formatter function reference (optional)

=cut


sub GFF {
    return join "\n",  $_[0]->site1->GFF, $_[0]->site2->GFF;
}


=head2 site1
=head2 site2

 Title   : site1
           site2
 Usage   : my $site1 = $sitepair->site1();      
                                                
 Function:  Returns individual TFBS::Site objects, from the site pair
 Returns : a TFBS::Site
 Args    : none 

=cut


sub site1  {
    $_[0]->feature1();
}

sub site2  {
    $_[0]->feature2();
}



