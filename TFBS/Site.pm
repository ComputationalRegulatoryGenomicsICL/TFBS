# TFBS module for TFBS::Site
#
# Copyright Boris Lenhard
#
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME

TFBS::Site - a nucleotide sequence feature object representing (possibly putative) transcription factor binding site.

=head1 SYNOPSIS

    # manual creation of site object;
    # for details, see documentation of Bio::SeqFeature::Generic;

    my $site = TFBS::Site
                  (-start => $start_pos,     # integer
		   -end   => $end_pos,       # integer
		   -score => $score,         # float
		   -source => "TFBS",        # string
		   -primary => "TF binding site",  # primary tag
		   -strand => $strand,       # -1, 0 or 1
		   -seqobj => $seqobj,       # a Bio::Seq object whose sequence
		                             #            contains the site
		   -pattern => $pattern_obj  # usu. TFBS::Matrix:PWM obj.
		   -);


    # Searching sequence with a pattern (PWM) and retrieving individual sites:
    #
    #   The following objects should be defined for this example:
    #       $pwm    -   a TFBS::Matrix::PWM object
    #       $seqobj -   a Bio::Seq object
    #   Consult the documentation for the above modules if you do not know
    #   how to create them.

    #   Scanning sequence with $pwm returns a TFBS::SiteSet object:

    my $site_set = $pwm->search_seq(-seqobj => $seqobj,
				    -threshold => "80%");

    #   To retrieve individual sites from $site_set, create an iterator obj:

    my $site_iterator = $site_set->Iterator(-sort_by => "score");

    while (my $site = $site_iterator->next())  {
        # do something with $site
    }



=head1 DESCRIPTION

TFBS::Site object holds data for a (possibly predicted) transcription factor binding site on a nucleotide sequence (start, end, strand, score, tags, as well as references to the corresponding sequence and pattern objects). TFBS::Site is a subclass of Bio::SeqFeature::Generic and has acces to all of its method. Additionally, it contains the pattern() method, an accessor for pattern object associated with the site object.

=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

TFBS::Site is a class that extends Bio::SeqFeature::Generic. Please consult Bio::SeqFeature::Generic documentation for other available methods.

=cut


# The code begins HERE:


package TFBS::Site;

use vars qw(@ISA);
use strict;

use Bio::SeqFeature::Generic;
@ISA = qw(Bio::SeqFeature::Generic);

=head2 new

 Title   : new
 Usage   : my $site = TFBS::Site->new(%args)
 Function: constructor for the TFBS::Site object
 Returns : TFBS::Site object
 Args    : -start,       # integer
           -end,         # integer
           -strand,      # -1, 0 or 1
           -score,       # float
           -source,      # string (method used to detect it)
           -primary,     # string (primary tag)
           -seqobj,      # a Bio::Seq object
           -pattern      # a pattern object, usu. TFBS::Matrix::PWM

=cut


sub new  {
    my $class = shift;
    my %args = (-seq_id      => undef,
		-siteseq      => undef,
		-seqobj       => undef,
		-strand       => "0",
		-source       => "TFBS",
		-primary      => "TF binding site",
		-pattern      => undef,
		-score        => undef,
		-start        => undef,
		-end          => undef,
		-frame	      => 0,
		@_);
    my $obj = Bio::SeqFeature::Generic->new(%args);
    my $self = bless $obj, ref($class) || $class;
    if ($args{-seqobj}) {
	$self->attach_seq($args{-seqobj}) ;
	$self->add_tag_value('sequence', $self->seq->seq);
    }
    # this is only for GFF printing really, and will be moved there soon

    if (defined $args{'-pattern'}) {
	$self->pattern($args{'-pattern'});
	$self->add_tag_value('TF' => $self->pattern->name());
	$self->add_tag_value('class' => $self->pattern->class)
	    if  $self->pattern->class;
    }


    return $self;
}



=head2 pattern

 Title   : pattern
 Usage   : my $pattern = $site->pattern();  # gets the pattern
           $site->pattern($pwm);            # sets the pattern to $pwm
 Function: gets/sets the pattern object associated with the site
 Returns : pattern object, here TFBS::Matrix::PWM object
 Args    : pattern object (optional, for setting the pattern only)

=cut


sub pattern {
    my ($self, $pattern) = @_;
    if (defined $pattern)  {
        $self->{'pattern'} = $pattern;
    }
    return $self->{'pattern'};
}


=head2 rel_score

 Title   : rel_score
 Usage   : my $percent_score = $site->rel_score() * 100;  # gets the pattern
 Function: gets relative score (between 0.0 to 1.0) with respect of the score
           range of the associated pattern (matrix)
 Returns : floating point number between 0 and 1,
           or undef if pattern not defined
 Args    : none

=cut


sub rel_score  {
    my ($self) = @_;
    return undef unless $self->pattern();
    return ($self->score - $self->pattern->min_score)/
	($self->pattern->max_score - $self->pattern->min_score);
}

=head2 GFF

 Title   : GFF
 Usage   : print $site->GFF();
         : print $site->GFF($gff_formatter)
 Function: returns a "standard" GFF string - the "generic" gff_string
           method is left untouched for possible customizations
 Returns : a string (NOT newline terminated! )
 Args    : a $gff_formatter function reference (optional)

=cut



sub GFF  {
    # due to popular demand, GFF is again a legal method, this time
    # not requiring GFF modules

    return $_[0]->gff_string($_[1]);
}


=head2 location

=head2 start

=head2 end

=head2 length

=head2 score

=head2 frame

=head2 sub_SeqFeature

=head2 add_sub_SeqFeature

=head2 flush_sub_SeqFeature

=head2 primary_tag

=head2 source_tag

=head2 has_tag

=head2 add_tag_value

=head2 each_tag_value

=head2 all_tags

=head2 remove_tag

=head2 attach_seq

=head2 seq

=head2 entire_seq

=head2 seq_id

=head2 annotation

=head2 gff_format

=head2 gff_string

The above methods are inherited from Bio::SeqFeature::Generic.
Please see L<Bio::SeqFeature::Generic> for details on their usage.

=cut

##################################################################
# BACKWARD COMPATIBILITY METHODS

sub Matrix  {
    my ($self, %args) = @_;
    $self->pattern(%args);
}

sub seqobj  {

}

sub  siteseq  {
    $_[0]->seq->seq();
}

sub site_length  {
    my ($self) = @_;
    $self->warn("site_length method is present for backward compatibility only. In new code please use the length() method");
    return $self->length();
}


sub old_GFF {
    eval "require GFF::GeneFeature;";
    if ($@) { print STDERR "Failed to load GFF modules, stopped"; return; }
    my ($self, %tags) =@_;
    $self->warn("GFF method is for backward compatibility only, and its use in new code is not recommended. Please use Bio::SeqFeature::Generic gff methods if possible.");
    my $GFFgf = GFF::GeneFeature->new(2);

    $GFFgf->seqname ( $self->seqname() or "Unknown" );
    $GFFgf->source  ("TFBS");
    $GFFgf->feature ("TFBS");
    $GFFgf->start   ($self->start());
    $GFFgf->end     ($self->end());
    $GFFgf->score   ($self->score());
    $GFFgf->strand  (("-",".","+")[$self->strand()+1]);
    # $GFFgf->strand  ($self->strand());

    %tags = (TF    => $self->pattern->{name},
	     class => $self->pattern->{class},
	     sequence => $self->seq->seq(),
	     %tags);
    while (my ($tag, $value) = each %tags)  {
	my @values;
	if (ref($value)  eq "ARRAY") {
	    @values = @$value;
	}
	else {
	    @values = ($value);
	}
	$GFFgf->attribute($tag, @values);
    }
    return $GFFgf;
}


1;





