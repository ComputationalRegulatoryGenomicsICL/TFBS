package TFBS::Matrix::_Alignment;

use vars qw(@ISA $AUTOLOAD);

use TFBS::SitePair;
use TFBS::SitePairSet;
use Bio::Root::Root;
use Bio::Seq;
use Bio::SimpleAlign;
use Bio::AlignIO;
use IO::String;
use PDL;

use strict;

@ISA =('Bio::Root::Root');


# CONSTANTS

use constant DEFAULT_WINDOW => 50;
use constant DEFAULT_CUTOFF => 70;
use constant DEFAULT_THRESHOLD => "80%";


sub new  {

    # this is ugly; OK, OK, I'll rewrite it as soon as I can
    my ($caller, %args) = @_;
    my $self = bless {}, ref $caller || $caller;
    $self->window($args{-window} or DEFAULT_WINDOW);
    $self->_parse_alignment(%args);
    $self->seq1length(length(_strip_gaps($self->alignseq1())));
    $self->seq2length(length(_strip_gaps($self->alignseq2())));
    $self->_set_subpart_bounds($args{-subpart});
    #
    # If a conservation profile is provided, no need to compute it again.
    # NOTE: conservation2 never seems to be used anywhere else so don't worry
    # about the fact we are ignoring it if conservation is passed in :)
    #
    my $cp = $args{-conservation};
    if ($cp) {
		$self->conservation1([$cp->conservation()]);
    } else {
		$self->conservation1($self->_calculate_conservation($self->window(),1));
		$self->conservation2($self->_calculate_conservation($self->window(),2));
    }

	$self->cutoff($args{-cutoff} or DEFAULT_CUTOFF);
	#$self->threshold($args{-threshold} or DEFAULT_THRESHOLD);
    #$self->_do_sitesearch
	#(($args{-pattern_set} or $self->throw("No -matrixset parameter")),
	# ($args{-threshold} or DEFAULT_THRESHOLD),
	# ());

    # $self->_set_start_end(%args);  # Maybe later...

    return $self;

}



sub DESTROY {
    # empty
}

sub _parse_alignment {
    my ($self, %args) = @_;
    my ($seq1, $seq2, $start);
    my $alignobj;

    if (defined $args{'-alignstring'})  {
		$alignobj = _alignstring_to_alignobj($args{'-alignstring'});
    }
    elsif (defined $args{'-file'})  {
		$alignobj = _alignfile_to_alignobj($args{'-file'});
    }
    elsif  (defined $args{-alignobj})  {
		$alignobj = $args{'-alignobj'};
    }
    else  {
		$self->throw("No -alignstring, -file or -alignobj passed.");
    }


    my @match;
    my ($seqobj1, $seqobj2) = $alignobj->each_seq;
    ($seq1, $seq2) = ($seqobj1->seq, $seqobj2->seq);
    $start = 1;
    $self->seq1name($seqobj1->display_id);
    $self->seq2name($seqobj2->display_id);


    $self->alignseq1($seq1);
    $self->alignseq2($seq2);
    my @seq1 = ("-", split('', $seq1) );
    my @seq2 = ("-", split('', $seq2) );
    $self->{alignseq1array} = [@seq1];
    $self->{alignseq2array} = [@seq2];

    my (@seq1index, @seq2index);
    my ($i1, $i2) = (0, 0);
    for my $pos (0..$#seq1) {
		my ($s1, $s2) = (0, 0);
		$seq1[$pos] ne "-" and  $s1 = ++$i1;
		$seq2[$pos] ne "-" and  $s2 = ++$i2;
		push @seq1index, $s1;
		push @seq2index, $s2;
    }

    $self->pdlindex( pdl [ [list sequence($#seq1+1)],
			   [@seq1index],
			   [@seq2index],
			   [list zeroes ($#seq1+1)] ]) ;

    return 1;

}

sub pdlindex {
    my ($self, $input, $p1, $p2) = @_ ;
    # print ("PARAMS ", join(":", @_), "\n");
    if (ref($input) eq "PDL")  {
	$self->{pdlindex} = $input;
    }

    unless (defined $p2)  {
	return $self->{pdlindex};
    }
    else {
	my @results = list
	    $self->{pdlindex}->xchg(0,1)->slice($p2)->where
		($self->{pdlindex}->xchg(0,1)->slice($p1)==$input);
	wantarray ? return @results : return $results[0];
    }
}

sub lower_pdlindex {
    my ($self, $input, $p1, $p2) = @_;
    unless (defined $p2)  {
		$self->throw("Wrong number of parameters passed to lower_pdlindex");
    }
    my $result;
    my $i = $input;

    until ($result = $self->pdlindex($i, $p1 => $p2))  {
		$i--;

		last if $i==0;
    }
    return $result or 1;
}

sub higher_pdlindex {
    my ($self, $input, $p1, $p2) = @_;
    unless (defined $p2)  {
		$self->throw("Wrong number of parameters passed to lower_pdlindex");
    }
    my $result;
    my $i = $input;
    until ($result = $self->pdlindex($i, $p1 => $p2))  {
	$i++;
	last unless ($self->pdlindex($i, $p1=>0) > 0);
    }
    return $result;
}


sub _calculate_conservation  {
    my ($self, $WINDOW, $which) = @_;
    my (@seq1, @seq2);
    if ($which==2)  {
	@seq1 = @{$self->{alignseq2array}};
	@seq2 = @{$self->{alignseq1array}};
    }
    else  {
	@seq1 = @{$self->{alignseq1array}};
	@seq2 = @{$self->{alignseq2array}};
	$which=1;
    }

    my @CONSERVATION;
    my @match;

    while ($seq1[0] eq "-")  {
	shift @seq1;
	shift @seq2;
    }

    for my $i (0..$#seq1) {
  	push (@match,( uc($seq1[$i]) eq uc($seq2[$i]) ? 1:0))
  	    unless ($seq1[$i] eq "-" or $seq1[$i] eq ".");
    }
    my @graph=($match[0]);
    for my $i (1..($#match+$WINDOW/2))  {
  	$graph[$i] = ($graph[$i-1] or 0)
  	           + ($i>$#match ? 0: $match[$i])
  		   - ($i<$WINDOW ? 0: $match[$i-$WINDOW]);
    }

    # at this point, the graph values are shifted $WINDOW/2 to the right
    # i.e. the score at a certain position is the score of the window
    # UPSTREAM of it: To fix it, we shoud discard the first $WINDOW/2 scores:
    #$self->conservation1 ([]);
    foreach my $pos (@graph[int($WINDOW/2)..$#graph])  {
	push @CONSERVATION, 100*$pos/$WINDOW;
    }

    # correction
    foreach my $pos (0..int($WINDOW/2))  {
	$CONSERVATION[$pos] =
	    $CONSERVATION[$pos]*$WINDOW/(int($WINDOW/2)+$pos);
	$CONSERVATION[$#CONSERVATION - $pos] =
	    $CONSERVATION[$#CONSERVATION - $pos]*$WINDOW/(int($WINDOW/2)+$pos);
    }


    return [@CONSERVATION];

}


sub _strip_gaps {
    # a utility function
    my $seq = shift;
    $seq =~ s/\-|\.//g;
    return $seq;
}


sub do_sitesearch  {
    my ($self, @args ) =  @_;

	my ($MATRIXSET, $THRESHOLD, $CUTOFF) =
	    $self->_rearrange([qw(PATTERN_SET THRESHOLD CUTOFF)], @args);
	if (!$MATRIXSET) {
		$self->throw("No -pattern_set passed to do_sitesearch");
	}
	$CUTOFF = ($CUTOFF or DEFAULT_CUTOFF);
	$THRESHOLD = ($THRESHOLD or DEFAULT_THRESHOLD);
    $self->site_pair_set(TFBS::SitePairSet->new());

    return if(($self->subpart1 and $self->subpart1->{-start} == 0) or
	      ($self->subpart2 and $self->subpart2->{-start} == 0));
	# ^^^ If one of the subparts is a gap, there's no point in searching

    my $seqobj1 = Bio::Seq->new(-seq=>_strip_gaps($self->alignseq1()),
				-id => "Seq1");
    my $siteset1 =
	$MATRIXSET->search_seq(-seqobj => $seqobj1,
			    -threshold => $THRESHOLD,
			      -subpart => $self->subpart1);
    my $siteset1_itr = $siteset1->Iterator(-sort_by => "start");

    my $seqobj2 = Bio::Seq->new(-seq=>_strip_gaps($self->alignseq2()),
				-id => "Seq2");
    my $siteset2 =
	$MATRIXSET->search_seq(-seqobj => $seqobj2,
			    -threshold => $THRESHOLD,
			      -subpart => $self->subpart2);
    my $siteset2_itr = $siteset2->Iterator(-sort_by => "start");

    my $site1 = $siteset1_itr->next();
    my $site2 = $siteset2_itr->next();

    while (defined $site1 and defined $site2) {
	my $pos1_in_aln = $self->pdlindex($site1->start(), 1=>0);
	my $pos2_in_aln = $self->pdlindex($site2->start(), 2=>0);
	my $cmp = (($pos1_in_aln <=> $pos2_in_aln)
		    or ($site1->pattern->name() cmp $site2->pattern->name())
		    or ($site1->strand() cmp $site2->strand()));

	if ($cmp==0) { ### match
	    if (# threshold test:
		$self->conservation1->[$site1->start()]
		>=
		$self->cutoff()
		)
	    {
		my $site_pair = TFBS::SitePair->new($site1, $site2);
		$self->site_pair_set->add_site_pair($site_pair);
	    }
	    $site1 = $siteset1_itr->next();
	    $site2 = $siteset2_itr->next();
	}
	elsif ($cmp<0)  { ### $siteset1 is behind
	    $site1 = $siteset1_itr->next();
	}
	elsif ($cmp>0)  { ### $siteset2 is behind
	    $site2 = $siteset2_itr->next();
	}
    }
}


sub _set_subpart_bounds {
    my ($self, $subpart) = @_;
    if(defined $subpart) {
	my ($relative_to, $start, $end) = ($subpart->{-relative_to},
					   $subpart->{-start},
					   $subpart->{-end});
	unless(defined($relative_to) and defined($start) and defined($end) ) {
	    $self->throw("Option -subpart missing suboption -relative_to, -start or -end");
	}
    	if($relative_to == 1) {
	    my $other_start = $self->higher_pdlindex($start, 1 => 2);
	    my $other_end = $self->lower_pdlindex($end, 1 => 2);
	    ($other_start, $other_end) = (0,0) if($other_start > $other_end);
	    $self->subpart1({ -start => $start, -end => $end });
	    $self->subpart2({ -start => $other_start, -end => $other_end });
	}
    	elsif($relative_to == 2) {
	    my $other_start = $self->higher_pdlindex($start, 2 => 1);
	    my $other_end = $self->lower_pdlindex($end, 2 => 1);
	    ($other_start, $other_end) = (0,0) if($other_start > $other_end);
	    $self->subpart1({ -start => $other_start, -end => $other_end });
	    $self->subpart2({ -start => $start, -end => $end });
	}
	else {
	    $self->throw("Suboption -relative_to should be 1 or 2");
	}
    }
}


sub _calculate_cutoff  {
    my ($self) = @_;
    my $ile = 0.9;
    my @conservation_array = sort {$a <=> $b} @{$self->conservation1()};

    my $perc_90 = $conservation_array[int($ile*scalar(@conservation_array))];
    return $perc_90;
}


sub _alignfile_to_string  {
    # a utility function
    # DEPRECATED !!!
    my $alignfile = shift;
    if ($alignfile =~ /\.msf$/i) {
	my $alignobj = Bio::SimpleAlign->new();
	$alignobj->read_MSF($alignfile);
        return _alignobj_to_string($alignobj);
    }
    else  { #assumed clustalw - no AlignIO import yet
	local $/ = undef;
	open FILE, $alignfile
	    or die("Could not read alignfile $alignfile, stopped");
	my $alignstring = <FILE>;
	return $alignstring;
    }
 }

sub _alignfile_to_alignobj  {
    # a utility function
    my ($alignfile, $format) = (@_,'clustalw');
    if (!$format and $alignfile =~ /\.msf$/i) { $format = 'msf' ;}
    my $alnio = Bio::AlignIO->new(-file=>$alignfile, -format=>$format);
    return $alnio->next_aln;
 }

sub _alignobj_to_string  {
    # a utility function
    # DEPRECATED
    my $alignobj = shift;
    my $alignstring;
    my $io = IO::String->new($alignstring);
    my $alnio = Bio::AlignIO->new(-fh=>$io, -format=>"clustalw");
    $alnio->write_aln($alignobj);
    $alnio->close();
#    $io->close;
    return $alignstring;
}

sub _alignstring_to_alignobj  {
    # a utility function
    my ($alignstring, $format) = (@_, 'clustalw');
    my $io = IO::String->new($alignstring);
    my $alnio = Bio::AlignIO->new(-fh=>$io, -format=>$format);
    my $alignobj = $alnio->next_aln();
    $alnio->close();
#    $io->close;
    return $alignstring;
}

# uglier than AUTOLOAD, but faster - a quick fix to get rid of Class::MethodMaker


sub cutoff
{ $_[0]->{'cutoff'}        = $_[1] if exists $_[1]; $_[0]->{'cutoff'};       }

sub window
{ $_[0]->{'window '}       = $_[1] if exists $_[1]; $_[0]->{'window '};      }

sub alignseq1
{ $_[0]->{'alignseq1'}     = $_[1] if exists $_[1]; $_[0]->{'alignseq1'};    }

sub alignseq2
{ $_[0]->{'alignseq2'}     = $_[1] if exists $_[1]; $_[0]->{'alignseq2'};    }

sub site_pair_set
{ $_[0]->{'site_pair_set'} = $_[1] if exists $_[1]; $_[0]->{'site_pair_set'};}

sub seq1name
{ $_[0]->{'seq1name'}      = $_[1] if exists $_[1]; $_[0]->{'seq1name'};     }

sub seq2name
{ $_[0]->{'seq2name'}      = $_[1] if exists $_[1]; $_[0]->{'seq2name'};     }

sub seq1length
{ $_[0]->{'seq1length'}    = $_[1] if exists $_[1]; $_[0]->{'seq1length'};   }

sub seq2length
{ $_[0]->{'seq2length'}    = $_[1] if exists $_[1]; $_[0]->{'seq2length'};   }

sub subpart1
{ $_[0]->{'subpart1'}  = $_[1] if exists $_[1]; $_[0]->{'subpart1'}; }

sub subpart2
{ $_[0]->{'subpart2'}  = $_[1] if exists $_[1]; $_[0]->{'subpart2'}; }

sub conservation1
{ $_[0]->{'conservation1'} = $_[1] if exists $_[1]; $_[0]->{'conservation1'};}

sub conservation2
{ $_[0]->{'conservation2'} = $_[1] if exists $_[1]; $_[0]->{'conservation2'};}

sub exclude_orf
{ $_[0]->{'exclude_orf'}   = $_[1] if exists $_[1]; $_[0]->{'exclude_orf'};  }

sub start_at
{ $_[0]->{'start_at'}      = $_[1] if exists $_[1]; $_[0]->{'start_at'};     }

sub end_at
{ $_[0]->{'end_at'}        = $_[1] if exists $_[1]; $_[0]->{'end_at'};     }




1;


