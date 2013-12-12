package TFBS::Run::ConservationProfileGenerator;

use strict;

use Bio::Root::Root;
use TFBS::ConservationProfile;
use Bio::AlignIO;

use constant DEFAULT_WINDOW => 50;
use constant DEFAULT_CUTOFF => 0.7;

use vars qw'@ISA';
@ISA = qw'Bio::Root::Root';

sub new {
    my ( $caller, %args ) = @_;
    my $self = bless {
        alignment    => undef,
        ref_sequence => undef,
        method       => undef,
        window       => DEFAULT_WINDOW,
        cutoff       => DEFAULT_CUTOFF,
        %args
      },
      ref $caller || $caller;

    if (   !defined( $self->alignment )
        or !$self->alignment->isa("Bio::SimpleAlign") )
    {
        $self->throw( "alignment: argument missing or wrong object type: "
              . ref( $self->alignment ) );
    }

    return $self;
}

sub run {
    my ( $self, %args ) = @_;
    my $method = ( $args{method} or $self->method or "simple" );

    my %method_subref = (
        simple     => \&_run_simple,
        malin      => \&_run_Malins,
        align_cons => \&_run_align_cons
    );

    if ( !defined( $method_subref{$method} ) ) {
        $self->throw("method $method not supported");
    }
    $method_subref{$method}->( $self, %args );

}

sub alignment {
    $_[0]->{'alignment'};
}

sub ref_sequence {
    $_[0]->{'ref_sequence'};
}

sub method {
    $_[0]->{'method'};
}

sub window {
    $_[0]->{'window'};
}

sub cutoff {
    $_[0]->{'cutoff'};
}

sub _run_simple {
    my ( $self, %args ) = @_;
    my ( $window_size, $cutoff, $ref_seq_nr, $other_seq_nr ) =
      $self->_rearrange( [qw(WINDOW CUTOFF REF_SEQ_NR OTHER_SEQ_NR)], %args );
    $window_size = $self->window unless $window_size;
    $cutoff      = $self->cutoff unless $cutoff;
    $ref_seq_nr = 1 if !$ref_seq_nr;
    $other_seq_nr = ( $other_seq_nr or 3 - $ref_seq_nr );

    my @seq1 = split "", $self->alignment->get_seq_by_pos($ref_seq_nr)->seq;
    my @seq2 = split "", $self->alignment->get_seq_by_pos($other_seq_nr)->seq;

    my @CONSERVATION;
    my @match;

    while ( $seq1[0] eq "-" or $seq1[0] eq "." ) {
        shift @seq1;
        shift @seq2;
    }

    for my $i ( 0 .. $#seq1 ) {
        push( @match, ( uc( $seq1[$i] ) eq uc( $seq2[$i] ) ? 1 : 0 ) )
          unless ( $seq1[$i] eq "-" or $seq1[$i] eq "." );
    }
    my @graph = ( $match[0] );
    for my $i ( 1 .. ( $#match + $window_size / 2 ) ) {
        $graph[$i] = $graph[ $i - 1 ] + ( $i > $#match ? 0 : $match[$i] ) -
          ( $i < $window_size ? 0 : $match[ $i - $window_size ] );
    }

  # at this point, the graph values are shifted $window_size/2 to the right
  # i.e. the score at a certain position is the score of the window
  # UPSTREAM of it: To fix it, we shoud discard the first $window_size/2 scores:
  #$self->conservation1 ([]);
    foreach my $match_point ( @graph[ int( $window_size / 2 ) .. $#graph ] ) {
        push @CONSERVATION, $match_point / $window_size;
    }

    return TFBS::ConservationProfile->new(
        conservation => \@CONSERVATION,
        parameters   => {
            window       => $window_size,
            cutoff       => $cutoff,
            ref_seq_nr   => $ref_seq_nr,
            other_seq_nr => $other_seq_nr,
            method       => "simple"
        },
        ref_sequence => $self->ref_sequence,
        alignment    => $self->alignment
    );

}

sub _run_Malins {
    shift->throw(
        "Not implemeted, sorry. Pick another method for the time being");
}

sub _run_align_cons {
    my ( $self, %args ) = @_;
    my ( $window_size, $increment, $cutoff, $stringency, $format, $prog ) =
      $self->_rearrange(
        [qw(WINDOW INCREMENT CUTOFF STRINGENCY FORMAT PROGRAM)], %args );

    my %params = (
        -w => $window_size,
        -n => $increment,
        -t => $cutoff,
        -s => $stringency,
        -r => "p",
        -f => ( $format or "c" )    # center by default
    );
    $prog = "align_cons" unless defined $prog;

    my @cl_args;
    while ( my ( $param, $value ) = each %params ) {
        if ( defined $value ) {
            push @cl_args, $param, $value;
        }
    }
    my $alnstring = $self->_alignment_to_string("fasta");
    $alnstring =~ s/[\"\$]/\\$1/gs;    # escape things that might confuse echo
    my $command      = join " ", $prog, @cl_args;
    my @output_lines = `echo "$alnstring" | $command`;

    # add error checking here!!!

    my @CONSERVATION;
    foreach my $line (@output_lines) {
        chomp $line;
        $line =~ s/^\D+//;
        my ( $pos, $value ) = split /\s+/, $line;
        push @CONSERVATION, $value;
    }

    return TFBS::ConservationProfile->new(
        conservation => \@CONSERVATION,
        parameters   => {
            window     => $window_size,
            cutoff     => $cutoff,
            increment  => $increment,
            stringency => $stringency,
            method     => "align_cons"
        },
        alignment    => $self->alignment,
        ref_sequence => $self->ref_sequence
    );

}

sub _alignment_to_string {
    my ( $self, $format ) = ( @_, "fasta" );
    my $alnstring;
    my $fh = IO::String->new($alnstring);
    my $outstream = Bio::AlignIO->new( -fh => $fh, -format => $format );
    $outstream->write_aln( $self->alignment );
    $outstream->close;
    return $alnstring;
}




#sub _UNIT_TESTS  {
#    require Test;
#    require CONSNP::Test::TestObjects;
#    my $to = CONSNP::Test::TestObjects->new;
#
#    plan(tests => 5);
#
#    exit(0);
#
#
#}


1;
