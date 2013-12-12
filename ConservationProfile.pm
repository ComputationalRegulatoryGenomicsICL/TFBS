package TFBS::ConservationProfile;

use strict;

use Bio::Root::Root;

use vars qw'@ISA';
@ISA = qw'Bio::Root::Root';

sub new {
    my ($caller, %args) = @_;
    my $self = bless {parameters=>{},
                        alignment => undef,
                        ref_sequence => undef,
                        %args
                     } ,ref $caller || $caller;

    if (!defined($self->{conservation}) or ref($self->{conservation}) ne "ARRAY") {
        $self->throw("conservation: argument missing or wrong object type");
    }

    return $self;

}

sub param  {
    my ($self, $param, $value) = @_;
    if (!defined $param)  {
        return keys %{$self->{parameters}};
    }
    elsif (defined $value)  {
        $self->{parameters}->{$param} = $value;
    }
    return $self->{parameters}->{$param};

}

sub alignment {
    $_[0]->{alignment}
}

sub ref_sequence {
    $_[0]->{ref_sequence}
}

sub conserved_regions_as_gff {
    my ($self,  %args) = @_;
    my @features = $self->conserved_regions_as_features;
    my $output = "";
    foreach my $f (@features) {
        $output .= $f->gff_string."\n";
    }
    return $output;
}

sub conserved_regions_as_features {
    my ($self,  %args) = @_;
    my ($excl_feature_ref, $cutoff) =
        $self->_rearrange([qw(exclude_features cutoff)], %args);
    $cutoff = ($cutoff or $self->param("cutoff") or 0.7);

    print STDERR "CURRENT CUTOFF $cutoff\n";

    my @conservation = $self->conservation;
    my ($START, $END);
    if ($self->ref_sequence and $self->ref_sequence->isa("Bio::LocatableSeq"))  {
        $START = $self->ref_sequence->start;
        $END   = $self->ref_sequence->end;
    }
    else {
        $START = $self->alignment->get_seq_by_pos($self->param("ref_seq_nr" or 1))->start;
        $END   = $self->alignment->get_seq_by_pos($self->param("ref_seq_nr" or 1))->end;
    }
    if ($excl_feature_ref and ref($excl_feature_ref) eq "ARRAY") {
        foreach my $f (@$excl_feature_ref)  {
            my ($s, $e) = ($f->start, $f->end);
            next if ($e<$START or $s>$END);
            $s = $START if $s<$START;
            $e = $END   if $e>$END;
            map { $conservation[$_] = 0 }  ($s-$START..$e-$START);
        }
    }
    # obtain a list of positions with threshold
    my @cons_positions = ( (grep {$conservation[$_-$START]>=$cutoff} ($START..$#conservation+$START)), $END+1000);
                          # $END+1000 is a dummy position that simplifies the procedure

    my @features;
    my $region_start = $cons_positions[0];
    my $counter = 0;
    foreach my $i (0..$#cons_positions )  {
        if ($cons_positions[$i+1]-$cons_positions[$i]>10) { # 10 can be changed to max allowed gap in a conserved region
            $counter++;
            my $f = Bio::SeqFeature::Generic->new(-start=>$region_start,
                                                  -end  =>$cons_positions[$i],
                                                  -primary => "CR$counter",
                                                  -score => $cons_positions[$i]-$region_start+1
                                                 );

            push @features, $f;
            print STDERR $features[-1]->gff_string."\n";
            $region_start = $cons_positions[$i+1];
        }
    }
    return @features;
}

sub conserved_regions_as_feature_pairs  {


}

sub conservation {
    my ($self, $start, $end) = @_;

    if (!defined $start) {
        return @{$self->{conservation}}
    }
    else  {
        my ($START, $END);
        if ($self->alignment) {
            my $ref_seq_nr = ($self->param("ref_seq_nr") or 1);
            $START = $self->alignment->get_seq_by_pos($ref_seq_nr)->start;
            $END = $self->alignment->get_seq_by_pos($ref_seq_nr)->end;
        }
        else  {
            $START = 1;
        }
        if (defined $end)  {
            my ($pad_start, $pad_end) = (0, 0);
            if ($start < $START)  { $pad_start = $START-$start; $start = $START; }
            if ($end   > $END)    { $pad_end   = $end-$END;     $end = $END }
            return (_blank_array($pad_start),
                    @{$self->{conservation}}[$start-$START, $end-$START],
                    _blank_array($pad_end)
                   );
        }
        elsif ($start< $START) {
            return undef;
        }
        else {
            return $self->{conservation}->[$start-$START];
        }
    }
}


sub _blank_array {
    my ($length) = @_;
    my @arr = map {undef} (0..$length);
    pop @arr;
    return @arr
}




sub conserved_sequences {

}

sub conserved_subalignments  {

}

1;
