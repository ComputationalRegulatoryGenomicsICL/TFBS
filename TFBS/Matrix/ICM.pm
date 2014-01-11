# TFBS module for TFBS::Matrix::ICM
#
# Copyright Boris Lenhard
# 
# You may distribute this module under the same terms as perl itself
#

# POD

=head1 NAME
    
TFBS::Matrix::ICM - class for information content matrices of nucleotide
patterns
    
=head1 SYNOPSIS

=over 4

=item * creating a TFBS::Matrix::ICM object manually:

    my $matrixref = [ [ 0.00, 0.30, 0.00, 0.00, 0.24, 0.00 ],
		      [ 0.00, 0.00, 0.00, 1.45, 0.42, 0.00 ],
		      [ 0.00, 0.89, 2.00, 0.00, 0.00, 0.00 ],
		      [ 0.00, 0.00, 0.00, 0.13, 0.06, 2.00 ]
		    ];	
    my $icm = TFBS::Matrix::ICM->new(-matrix => $matrixref,
				     -name   => "MyProfile",
				     -ID     => "M0001"
				    );
 
    # or
 
    my $matrixstring = <<ENDMATRIX
    2.00   0.30   0.00   0.00   0.24   0.00
    0.00   0.00   0.00   1.45   0.42   0.00
    0.00   0.89   2.00   0.00   0.00   0.00
    0.00   0.00   0.00   0.13   0.06   2.00
    ENDMATRIX
    ;
    my $icm = TFBS::Matrix::ICM->new(-matrixstring => $matrixstring,
				     -name   	   => "MyProfile",
				     -ID           => "M0001"
				    );


=item * retrieving a TFBS::Matix::ICM object from a database:

(See documentation of individual TFBS::DB::* modules to learn
how to connect to different types of pattern databases and retrieve
TFBS::Matrix::* objects from them.)
    
    my $db_obj = TFBS::DB::JASPAR2->new
		    (-connect => ["dbi:mysql:JASPAR2:myhost",
				  "myusername", "mypassword"]);
    my $pfm = $db_obj->get_Matrix_by_ID("M0001", "ICM");
    # or
    my $pfm = $db_obj->get_Matrix_by_name("MyProfile", "ICM");


=item * retrieving list of individual TFBS::Matrix::ICM objects
from a TFBS::MatrixSet object

(see decumentation of TFBS::MatrixSet to learn how to create 
objects for storage and manipulation of multiple matrices)

    my @icm_list = $matrixset->all_patterns(-sort_by=>"name");

* drawing a sequence logo
          
    $icm->draw_logo(-file=>"logo.png", 
		    -full_scale =>2.25,
		    -xsize=>500,
		    -ysize =>250, 
		    -graph_title=>"C/EBPalpha binding site logo", 
		    -x_title=>"position", 
		    -y_title=>"bits");

=back

=head1 DESCRIPTION

TFBS::Matrix::ICM is a class whose instances are objects representing
position weight matrices (PFMs). An ICM is normally calculated from a
raw position frequency matrix (see L<TFBS::Matrix::PFM>
for the explanation of position frequency matrices). For example, given
the following position frequency matrix,

    A:[ 12     3     0     0     4     0  ]
    C:[  0     0     0    11     7     0  ]
    G:[  0     9    12     0     0     0  ]
    T:[  0     0     0     1     1    12  ]

the standard computational procedure is applied to convert it into the
following information content matrix:

    A:[2.00  0.30  0.00  0.00  0.24  0.00]
    C:[0.00  0.00  0.00  1.45  0.42  0.00]
    G:[0.00  0.89  2.00  0.00  0.00  0.00]
    T:[0.00  0.00  0.00  0.13  0.06  2.00]

which contains the "weights" associated with the occurence of each
nucleotide at the given position in a pattern.

A TFBS::Matrix::PWM object is equipped with methods to search nucleotide
sequences and pairwise alignments of nucleotide sequences with the
pattern they represent, and return a set of sites in nucleotide
sequence (a TFBS::SiteSet object for single sequence search, and a
TFBS::SitePairSet for the alignment search).

=head1 FEEDBACK

Please send bug reports and other comments to the author.

=head1 AUTHOR - Boris Lenhard

Boris Lenhard E<lt>Boris.Lenhard@cgb.ki.seE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are preceded with an underscore.

=cut

# The code starts HERE:

package TFBS::Matrix::ICM;

use vars '@ISA';
use PDL;
use strict;
use Bio::Root::Root;
use Bio::SeqIO;
use TFBS::Matrix;
BEGIN {
	# this will not fail if the modules are nit available
	# but only if the user tries to actually draw a logo
	eval "use SVG";
	eval "use GD";

};
use File::Temp qw/:POSIX/;
@ISA = qw(TFBS::Matrix Bio::Root::Root);

#################################################################
# PUBLIC METHODS
#################################################################

=head2 new

 Title   : new
 Usage   : my $icm = TFBS::Matrix::ICM->new(%args)
 Function: constructor for the TFBS::Matrix::ICM object
 Returns : a new TFBS::Matrix::ICM object
 Args    : # you must specify either one of the following three:
 
	   -matrix,      # reference to an array of arrays of integers
	      #or
	   -matrixstring,# a string containing four lines
	                 # of tab- or space-delimited integers
	      #or
	   -matrixfile,  # the name of a file containing four lines
	                 # of tab- or space-delimited integers
	   #######
 
           -name,        # string, OPTIONAL
           -ID,          # string, OPTIONAL
           -class,       # string, OPTIONAL
           -tags         # an array reference, OPTIONAL

=cut


sub new  {
    my ($class, %args) = @_;
    my $matrix = TFBS::Matrix->new(%args, -matrixtype=>"ICM");
    my $self = bless $matrix, ref($class) || $class;
    $self->_check_ic_validity();
    return $self;
}

=head2 to_PWM

 Title   : to_PWM
 Usage   : my $pwm = $icm->to_PWM()
 Function: converts an  information content matrix (a TFBS::Matrix::ICM object)
	   to position weight matrix. At present it assumes uniform
	   background distribution of nucleotide frequencies.
 Returns : a new TFBS::Matrix::PWM object
 Args    : none; in the future releases, it should be able to accept
	   a user defined background probability of the four
	   nucleotides

=cut


sub to_PWM  {
    my ($self) = @_;
    $self->throw ("Method to_PWM not yet implemented.");
}

=head2 draw_logo

 Title   : draw_logo
 Usage   : my $gdImageObj = $icm->draw_logo(%args)
 Function: Draws a "sequence logo", a graphical representation
	   of a possibly degenerate fixed-width nucleotide
	   sequence pattern, from the information content matrix
 Returns : a GD::Image object;
	   if you only need the image file you can ignore it
 Args    : -file,       # the name of the output PNG image file
		        # OPTIONAL: default none
	   -xsize       # width of the image in pixels
		        # OPTIONAL: default 600
	   -ysize       # height of the image in pixels
		        # OPTIONAL: default 5/8 of -x_size
           -startpos    # start position in the logo for x axis
                        # OPTIONAL: default is 1
	   -margin      # size of image margins in pixels
		        # OPTIONAL: default 15% of -y_size
	   -full_scale  # the maximum value on the y-axis, in bits
		        # OPTIONAL: default 2.25
	   -graph_title,# the graph title
			# OPTIONAL: default none
	   -x_title,    # x-axis title; OPTIONAL: default none
	   -y_title     # y-axis title; OPTIONAL: default none
           -error_bars  # reference to an array of S.D. values for each column; OPTIONAL
           -ps          # if true, produces a postscript string instead of a GD::Image object
            -pdf          # if true AND the -file argumant is used, produces an output pdf file

=cut

sub draw_logo {
    
    no strict;
    my $self = shift;
    my %args = (-xsize      => 600,
		-full_scale => 2.25,
		-graph_title=> "",
		-x_title    => "",
		-y_title    => "",
        -startpos   => 1,
 		@_);
    # Other parameters that can be specified:
    #       -ysize -line_width -margin
    # do not have a fixed default value 
    #   - they are calculated from xsize if not specified
    
        # draw postscript logo if asked for
    if ($args{'-ps'} || $args{'-pdf'}){
      return _draw_ps_logo($self, %args);  
    }
    if ($args{'-svg'} || $args{'-SVG'}){
      return _draw_svg_logo($self, %args);  
    }

    my ($xsize,$FULL_SCALE, $x_title, $y_title)   
	= @args{qw(-xsize -full_scale -x_title y_title)} ;

    my $PER_PIXEL_LINE = 300;
    
    # calculate other parameters if not specified

    my $line_width = ($args{-line_width} or int ($xsize/$PER_PIXEL_LINE) or 1);
    my $ysize      = ($args{-ysize} or $xsize/1.6); 
    # remark (the line above): 1.6 is a standard screen x:y ratio
    my $margin     = ($args{-margin} or $ysize*0.15);

    my $image = GD::Image->new($xsize, $ysize);
    my $white = $image->colorAllocate(255,255,255);
    my $black = $image->colorAllocate(0,0,0);
    my $motif_size = $self->pdl_matrix->getdim(0);
    my $font = ((&GD::gdTinyFont(), &GD::gdSmallFont(), &GD::gdMediumBoldFont(), 
		&GD::gdLargeFont(), &GD::gdGiantFont())[int(($ysize-50)/100)]
	or &GD::gdGiantFont());
    my $title_font = ((&GD::gdSmallFont(), &GD::gdMediumBoldFont(), 
		&GD::gdLargeFont(), &GD::gdGiantFont())[int(($ysize-50)/100)]
	or &GD::gdGiantFont());


   # WRITE LABELS AND TITLE

    # graph title   #&GD::Font::MediumBold
    $image->string($title_font,
		   $xsize/2-length($args{-graph_title})* $title_font->width() /2,
		   $margin/2 - $title_font->height()/2,
		   $args{-graph_title}, $black);
    
    # x_title
    $image->string($font,
		   $xsize/2-length($args{-x_title})*$font->width()/2,
		   $ysize-( $margin - $font->height()*0  - 5*$line_width)/2 
		     - $font->height()/2*0,
		   $args{-x_title}, 
		   $black);
    # y_title
    $image->stringUp($font,
		     ($margin -$font->width()- 5*$line_width)/2 
		       - $font->height()/2 ,
		     $ysize/2+length($args{'-y_title'})*$font->width()/2,
		     $args{'-y_title'}, $black);
    

    # DRAW AXES

    # vertical: (top left to bottom right)
    $image->filledRectangle($margin-$line_width, $margin-$line_width, 
			 $margin-1, $ysize-$margin+$line_width, 
			 $black);
    # horizontal: (ditto)
    $image->filledRectangle($margin-$line_width, $ysize-$margin+1, 
			 $xsize-$margin+$line_width,$ysize-$margin+$line_width,
			 $black);

    # DRAW VERTICAL TICKS AND LABELS

    # vertical axis (IC 1 and 2) 
    my $ic_1 = ($ysize - 2* $margin) / $FULL_SCALE;
    foreach my $i (1..$FULL_SCALE)  {
		$image->filledRectangle($margin-3*$line_width, 
				     $ysize-$margin - $i*$ic_1, 
				     $margin-1, 
				     $ysize-$margin+$line_width - $i*$ic_1, 
				     $black);
		$image->string($font, 
			       $margin-5*$line_width - $font->width,
			       $ysize - $margin - $i*$ic_1 - $font->height()/2,
			       $i,
		       $black);
    }
    
    # DRAW HORIZONTAL TICKS AND LABELS, AND THE LOGO ITSELF 

    # define function refs as hash elements
    my %draw_letter = ( A => \&_png_draw_A,
			C => \&_png_draw_C,
			G => \&_png_draw_G,
			T => \&_png_draw_T );

    my $horiz_step = ($xsize -2*$margin) / $motif_size;

    #this is to avoid clutter on X axis:
    my $longest_label_length = length("$motif_size");
    if (length ($args{-startpos}) > $longest_label_length) {
      	$longest_label_length = length ($args{-startpos}); 
    }
    if (length ($args{-startpos}+$motif_size) > $longest_label_length) {
       	$longest_label_length = length ($args{-startpos}+$motif_size);
    }
    my $draw_every_nth_label = int($longest_label_length*$font->width+2) / $horiz_step + 1;
    foreach my $i (0..$motif_size)  {
	
		$image->filledRectangle($margin + $i*$horiz_step, 
				     $ysize-$margin+1, 
				     $margin + $i*$horiz_step+ $line_width, 
				     $ysize-$margin+3*$line_width, 
				     $black);
		last if $i==$motif_size;
	
		# get the $i-th column of matrix
		my %ic; 
		($ic{A}, $ic{C}, $ic{G}, $ic{T}) = list $self->pdl_matrix->slice($i);
	
		# sort nucleotides by increasing information content
		my @draw_order = sort {$ic{$a}<=>$ic{$b}} qw(A C G T);
	
		# draw logo column
		my $xlettersize = $horiz_step /1.1;
		my $ybottom = $ysize - $margin;
		foreach my $base (@draw_order)  {
		    my $ylettersize = int($ic{$base}*$ic_1 +0.5);
		    next if $ylettersize ==0;
	
		    # draw letter
		    $draw_letter{$base}->($image,
					  $margin + $i*$horiz_step,
					  $ybottom - $ylettersize,
				  $xlettersize, $ylettersize, $white);
		    $ybottom = $ybottom - $ylettersize-1;
		}	    
	    
		if ($args{'-error_bars'} and ref($args{'-error_bars'}) eq "ARRAY")  {
		    my $sd_pix   = int($args{'-error_bars'}->[$i]*$ic_1);
		    my $yt     = $ybottom - $sd_pix+1;
		    my $yb  = $ybottom + $sd_pix-1;
		    my $xpos     = $margin + ($i+0.45)*$horiz_step;
		    my $half_width;
		    
		    if ($yb > $ysize-$margin+$line_width)  {
			$yb = $ysize-$margin+$line_width
			}
		    else {
			$image->line($xpos - $xlettersize/8, $yb, 
				     $xpos + $xlettersize/8, $yb, 
				     $black);
		    }
		   	
		    $image->line($xpos, $yt, $xpos, $yb, $black);
		    $image->line($xpos - 1 , $ybottom, $xpos+1, $ybottom, $black);
		    $image->line($xpos - $xlettersize/8, $yt, 
				 $xpos + $xlettersize/8, $yt, 
				 $black);
		    
		    
		}
	
       # print position number on x axis (The if condition is for avoiding clutter)
       my $xlabel = $i+ $args{-startpos};
       if ($args{-startpos}<0 and $xlabel>=0) {
           $xlabel ++;
       }
       if ($xlabel % $draw_every_nth_label == 0) {
           $image->string($font,
                          $margin + ($i+0.5)*$horiz_step - $font->width()/2,
                          $ysize - $margin +5*$line_width,
                          $xlabel,
                          $black);
       }
    }
    
    # print $args{-file};
    if  ($args{-file}) {  
		open (PNGFILE, ">".$args{-file})
		    or $self->throw("Could not write to ".$args{-file});
	        print PNGFILE $image->png;
		close PNGFILE;
    }
    return $image;
}






sub total_ic  {
    return $_[0]->pdl_matrix->sum();
}
=head2 _draw_ps_logo

 Title   : _draw_ps_logo 
 Usage   : my $postscript_string = $icm->_draw_ps_logo(%args)
           Internal method, should be accessed using draw_logo()
 Function: Draws a "sequence logo", a graphical representation
	   of a possibly degenerate fixed-width nucleotide
	   sequence pattern, from the information content matrix
 Returns : a postscript string;
	   if you only need the image file you can ignore it
 Args    : -file,       # the name of the output PNG image file
		        # OPTIONAL: default none
	   -xsize       # width of the image in pixels
		        # OPTIONAL: default 600
	   -ysize       # height of the image in pixels
		        # OPTIONAL: default 5/8 of -x_size
	   -full_scale  # the maximum value on the y-axis, in bits
		        # OPTIONAL: default 2.25
	   -graph_title,# the graph title
			# OPTIONAL: default none
	   -x_title,    # x-axis title; OPTIONAL: default none
	   -y_title     # y-axis title; OPTIONAL: default none
           


=cut
sub _draw_ps_logo{
 my $self = shift;
 my %args = (-xsize      => 600,
	     -full_scale => 2.25,
	     -graph_title=> "",
	     -x_title    => "",
	     -y_title    => "",
	     @_);   
    
    my $xsize= $args{'-xsize'};
    my $max_ysize= $args{'-ysize'} ||int  5* $args{'-xsize'}/8;
    my $ysize=  $max_ysize*($args{'-full_scale'}-($args{'-full_scale'}-2))/$args{'-full_scale'};
   
    my $x=100; # nternal, for placement on 'paper'
    my $y=100; 
   
    my $out= "%!PS-Adobe-2.0 
%%Orientation: Portrait
%%Pages: 1
%%BoundingBox: 0 0 ".($args{'-xsize'}*1.2)." ".( $max_ysize*1.5)."
%%BeginSetup
%%EndSetup
%%Magnification: 1.0000
%%EndProlog
%%end
%%save
gsave\n";

    #colors and correction definitions
    my %color;
    $color{'black'}="0.000 0.000 0.000 setrgbcolor";
    $color{'A'}="0.000 1.000 0.000 setrgbcolor";
    $color{'C'}="0.000 0.000 1.000 setrgbcolor";
    $color{'G'}="1.000 0.860 0.000 setrgbcolor";
    $color{'T'}="1.000 0.000 0.000 setrgbcolor";

    my $fontsize= int $ysize*0.68;
    my $fontwidth=1.5*($xsize/$self->length());
    my %w_correct; # correction of font widths
    $w_correct{'A'}=0.95;
    $w_correct{'T'}=1.05;
    $w_correct{'C'}=0.90;
    $w_correct{'G'}=0.90;
    
    my %y_next;#correction of font heights
    $y_next{'A'}=1;
    $y_next{'T'}=1;           
    $y_next{'C'}=0.94;
    $y_next{'G'}=0.94;

    my %y_correct; #correction of font bounding boxes
    $y_correct{'A'}=0;
    $y_correct{'C'}=0.035*$fontsize;
    $y_correct{'G'}=0.035*$fontsize;
    $y_correct{'T'}=0;
 
 
    #define y axis,tickmarks and scaling
 
    my $font= $fontwidth/5;  
    $out.="newpath\n ". ($x-10)." ". ($y+2*$ysize/4 )." moveto\n". "$x ". ($y+2*$ysize/4 ) ." lineto\n stroke\n";
    $out.= "gsave\n/Times-Bold findfont $color{black} [$font 0 0 $font 0 0] makefont setfont\n".($x-20). " ".( $y+$ysize/2)."  moveto\n";
    $out.=" (1) show\n grestore\n" ;
    $out.="newpath\n ". ($x-10)." ". ($y+$ysize )." moveto\n". "$x ". ($y+$ysize) ." lineto\n stroke\n";
    $out.="newpath\n ". ($x-10)." ". ($y+$max_ysize )." moveto\n". "$x ". ($y+$max_ysize) ." lineto\n stroke\n";
    $out.= "gsave\n/Times-Bold findfont $color{black} [$font 0 0 $font 0 0] makefont setfont\n".($x-20). " ".( $y+$ysize)."  moveto\n";
    $out.=" (2) show\n grestore\n" ;
    $out.="newpath\n $x $y  moveto\n". ($x). " ".($y+$max_ysize) ." lineto\n stroke\n";
    $out.="newpath\n $x $y  moveto\n". ($x+$xsize). " ".($y) ." lineto\n stroke\n";
    
    
    # draw titles if requested
    if ($args{'-y_title'}){
        $out.= "gsave\n/Times-Italic findfont $color{black} [$font 0 0 $font 0 0] makefont setfont\n".($x-40). " ".( $y+$ysize/2)."  moveto\n";
        $out.=" 90 rotate ($args{'-y_title'}) show\n grestore\n" ;
        }
    if ($args{'-x_title'}){
        $out.= "gsave\n/Times-Italic findfont $color{black} [$font 0 0 $font 0 0] makefont setfont\n".($x+$xsize/2.5). " ".( $y*(0.60))."  moveto\n";
        $out.=" ($args{'-x_title'}) show\n grestore\n" ;
        }
    if ($args{'-title'}){
        $out.= "gsave\n/Times-Roman findfont $color{black} [".($font*2)." 0 0 $font 0 0] makefont setfont\n".($x+$xsize/3). " ".( $y+$max_ysize*1.1)."  moveto\n";
         
        $out.=" ($args{'-title'}) show\n grestore\n" ;
    }
    

    # define x axis and x tickmarks
    my $col_width=($xsize/$self->length()) -0.006*$xsize;
    my $x_now;

    for(my $i=1; $i<=$self->length(); $i++){
        $x_now=$x+$col_width*$i;    
        $out.="newpath\n ". ($x_now)." ". ($y)." moveto\n". ($x_now)." ". ($y-$ysize/20 ) ." lineto\n stroke\n";
        $out.= "gsave\n/Times-Bold findfont $color{black} [$font 0 0 $font 0 0] makefont setfont\n".($x_now-$col_width/2). " ".( $y-20)."  moveto\n";
        $out.=" ($i) show\n grestore\n" ;
    }
    
    # draw the logo
    foreach my $i (0..$self->length()-1 )  { # get the $i-th column of matrix
        
        my %ic; 
	($ic{A}, $ic{C}, $ic{G}, $ic{T}) = list $self->pdl_matrix->slice($i);  
        my @draw_order = sort {$ic{$a}<=>$ic{$b}} qw(A C G T);

        #draw this position
        
        foreach my $letter (@draw_order){
	    $ic{$letter}=0.0000001 if ( $ic{$letter}==0); # some interpretors do not uderstand size 0
            $out.= "gsave\n/Helvetica-Bold findfont   $color{$letter} [".$fontwidth*$w_correct{$letter}." 0 0 ";
            $out.= $ic{$letter}*$fontsize*$y_next{$letter} ;
            $y+=$y_correct{$letter}*$ic{$letter}; #movement that isletter specific, due to bounding boxes
            $out.= " 0 0] makefont setfont\n$x  $y  moveto\n";       
            $out.= " ($letter) show\n grestore\n"  ;    
            $y+=$fontsize*$ic{$letter}*0.75; #ic content move
        }
        $x+=$fontwidth/1.6;
        $y=100;

  }
    # save as file if requested 
    if  ($args{-file}) {  
	open (PSFILE, ">".$args{-file})
	    or $self->throw("Could not write to ".$args{-file});
        print PSFILE $out;
	close PSFILE;
    }
    if ($args{-pdf}){
       
	system "ps2pdf $args{-file} ".$args{-file}.".pdf "; 
        system " mv $args{-file}.pdf $args{-file}"; 
    }
    
    
    
    
    return $out;
}

=head2 _draw_svg_logo 


=cut

sub _draw_svg_logo {	
	my $self = shift;
 	my %args = (-xsize      => 800,
	     -full_scale => 2.25,
	     -graph_title=> "",
	     -x_title    => "",
	     -y_title    => "",
	     @_);   
    
    my $max_ysize= $args{'-ysize'} ||int  5* $args{'-xsize'}/8;
    my ($xsize,$FULL_SCALE, $x_title, $y_title)   
	= @args{qw(-xsize -full_scale -x_title y_title)} ;

    my $PER_PIXEL_LINE = 200;
    
    # calculate other parameters if not specified

    my $ysize      = ($args{-ysize} or $xsize/1.6); 
    my $line_width = ($args{-line_width} or $ysize/$PER_PIXEL_LINE);
    # remark (the line above): 1.6 is a standard screen x:y ratio
    my $margin     = ($args{-margin} or $ysize*0.15);

    
    
    my $image = SVG->new(width=>$xsize, height=>$ysize);
    my $white = 'rgb(255,255,255)';
    my $black = 'rgb(0,0,0)';
    my $motif_size = $self->pdl_matrix->getdim(0);
    my $fontsize = int ($ysize/25);
	my $title_font = {width=>$fontsize*1.5, height=>$fontsize*1.5};
	my $font = {width=>$fontsize, height=>$fontsize};

    # WRITE LABELS AND TITLE

    # graph title   
    $image->text(id=>"Title", 
    			'font-size'=>$title_font->{width},
    			 x => $xsize/2,
    			 y => 0.6*$margin,
    			'text-anchor'=>'middle'
    			)->cdata($args{-graph_title});
    # x title

    $image->text(id=>"X_title", 
    			'font-size'=>$font->{width},
    			 x => $xsize/2,
    			 y => $ysize -0.3*$margin,
    			'text-anchor'=>'middle'
    	)->cdata($args{-x_title});
	
	# y title
	
    my $g = $image->group;
    $g->text(id=>"Y_title", 
    			 'font-size'=>$font->{width},
    			 x => 0 ,
    			 'text-anchor'=>'middle',
    			 y => 0,
                 transform => 'rotate(-90) translate(-'.($ysize/2).','.($margin/2).')')->cdata($args{-y_title});
    

    # DRAW AXES

    # vertical: (top left to bottom right)
    $image->rectangle(id => "y_axis",
    				  style => {
                        		#stroke => $black,
                        		fill   => $black
                      			},
                      x => $margin-$line_width,
                      y => $margin,
                      width => $line_width,
                      height => $ysize -2*$margin
                    );
    #$image->filledRectangle($margin-$line_width, $margin-$line_width, 
    #			 $margin-1, $ysize-$margin+$line_width, #
	#		 $black);
    # horizontal: (ditto)
    $image->rectangle(id => "x_axis",
    				  style => {
                        		#stroke => $black,
                        		fill   => $black
                      			},
                      x => $margin-$line_width,
                      y => $ysize-$margin,
                      width => $xsize-2*$margin+$line_width,
                      height => $line_width
                    );
    #$image->filledRectangle($margin-$line_width, $ysize-$margin+1, 
	#		 $xsize-$margin+$line_width,$ysize-$margin+$line_width,
	#		 $black);

    # DRAW VERTICAL TICKS AND LABELS

    # vertical axis (IC 1 and 2) 
    my $ic_1 = ($ysize - 2* $margin) / $FULL_SCALE;
    foreach my $i (1..$FULL_SCALE)  {
    	$image->rectangle(x  => $margin-3*$line_width, 
    					  y  => $ysize-$margin - $i*$ic_1,
    					  width => 3*$line_width,
    					  height => $line_width
    					  );
    	$image->text(x  => $margin-5*$line_width - $font->{width},
    				 y  => $ysize - $margin - $i*$ic_1 +$font->{height}/2,
    				 'font-size'=>$font->{width},
    				 'text-anchor'=>"right"
    				 )->cdata($i);
    				 
    }
    
    # DRAW HORIZONTAL TICKS AND LABELS, AND THE LOGO ITSELF 

    # define function refs as hash elements

    my %draw_letter = ( A => \&_svg_draw_A,
						C => \&_svg_draw_C,
						G => \&_svg_draw_G,
						T => \&_svg_draw_T  );

    my $horiz_step = ($xsize -2*$margin) / $motif_size;

    #this is to avoid clutter on X axis:

    my $longest_label_length = length("$motif_size");
    if (length ($args{-startpos}) > $longest_label_length) {
      	$longest_label_length = length ($args{-startpos}); 
    }
    if (length ($args{-startpos}+$motif_size) > $longest_label_length) {
       	$longest_label_length = length ($args{-startpos}+$motif_size);
    }
    my $draw_every_nth_label = int(($longest_label_length+0.25)*$font->{width}) / $horiz_step + 1;
    
    foreach my $i (0..$motif_size)  {
    	my $height = 3*$line_width;
    	if ($i and $i==$args{-startpos}*-1){
    		$height = 5*$line_width;
    	}
		$image->rectangle(x  => $margin + $i*$horiz_step -$line_width/2, 
						  y  => $ysize-$margin,
						  width => $line_width,
						  height => $height
						  );
		last if $i==$motif_size;
	
		# get the $i-th column of matrix
		my %ic; 
		($ic{A}, $ic{C}, $ic{G}, $ic{T}) = list $self->pdl_matrix->slice($i);
	
		# sort nucleotides by increasing information content
		my @draw_order = sort {$ic{$a}<=>$ic{$b}} qw(A C G T);
	
		# draw logo column
		my $xlettersize = $horiz_step*0.95;
		my $ybottom = $ysize - $margin;
		foreach my $base (@draw_order)  {
		    my $ylettersize = $ic{$base}*$ic_1;
		    next if $ylettersize ==0;
	
		    # draw letter
		    $draw_letter{$base}->($image,
					  			  $margin + $i*$horiz_step + 0.025* $horiz_step,
					  			  $ybottom - $ylettersize,
				  				  $xlettersize, $ylettersize, $white);
		    $ybottom = $ybottom - $ylettersize;
		}	    
	    
		if ($args{'-error_bars'} and ref($args{'-error_bars'}) eq "ARRAY")  {
		    my $sd_pix   = int($args{'-error_bars'}->[$i]*$ic_1);
		    my $yt     = $ybottom - $sd_pix+1; 
		    my $yb  = $ybottom + $sd_pix-1;
		    my $xpos     = $margin + ($i+0.5)*$horiz_step;
		    my $half_width;
		    
		    if ($yb > $ysize-$margin+$line_width)  {
				$yb = $ysize-$margin+$line_width
			}
		    else {
				$image->line(x1=>$xpos - $xlettersize/8, y1=> $yb, 
					    x2=> $xpos + $xlettersize/8, y2=>$yb, stroke=>$black,
					    'stroke-width'=>$line_width);
		    }
		   	
		    $image->line(x1=>$xpos, y1=>$yt, x2=>$xpos, y2=>$yb, stroke=>$black,
					    'stroke-width'=>$line_width);
		    $image->line(x1=>$xpos - $line_width , y1=>$ybottom, x2=>$xpos+$line_width, y2=>$ybottom, stroke=>$black,
					    'stroke-width'=>$line_width);
		    $image->line(x1=>$xpos - $xlettersize/8, y1=>$yt, 
				 x2=>$xpos + $xlettersize/8, y2=>$yt, stroke=>$black,
					    'stroke-width'=>$line_width);
	    
    
       }
	
		# print position number on x axis
        my $xlabel = $i+ $args{-startpos};
        if ($args{-startpos}<0 and $xlabel>=0) {
               $xlabel ++;
        }
       if ($xlabel % $draw_every_nth_label == 0) {
		   $image->text(x  => $margin + ($i+0.5)*$horiz_step - $font->{width}/2,
					 y  => $ysize - $margin +5*$line_width + $font->{width}/2,
					 'font-size'=>$font->{width},
    				 'text-anchor'=>"bottom"
					 
					 )->cdata($xlabel);
       }
    }	
    
    # print to $args{-file};
    if  ($args{-file}) {  
		open (SVGFILE, ">".$args{-file})
		    or $self->throw("Could not write to ".$args{-file});
		my $xml = $image->xmlify;
		$xml =~ s/\s+<\/text/<\/text/gs;
	    print SVGFILE $xml;
		close SVGFILE;
    }
    return $image;
   
}


=head2 name

=head2 ID

=head2 class

=head2 matrix

=head2 length

=head2 revcom

=head2 rawprint

=head2 prettyprint

The above methods are common to all matrix objects. Please consult
L<TFBS::Matrix> to find out how to use them.

=cut


#################################################################
# INTERNAL METHODS
#################################################################


sub _check_ic_validity  {
    my ($self) = @_;
    # to do
}

sub DESTROY  {
    # nothing
}


#################################################################
# UTILITY FUNCTIONS
#################################################################


# letter drawing routines

sub _png_draw_A {
    
    my ($im, $x, $y, $xsize, $ysize, $white) = @_;
    my $green = $im->colorAllocate(0,255,0);
    my $outPoly = GD::Polygon->new();
    $outPoly->addPt($x, $y+$ysize);
    $outPoly->addPt($x+$xsize*.42, $y);
    $outPoly->addPt($x+$xsize*.58, $y);
    $outPoly->addPt($x+$xsize, $y+$ysize);
    $outPoly->addPt($x+0.85*$xsize, $y+$ysize);
    $outPoly->addPt($x+0.725*$xsize, $y+0.75*$ysize);
    $outPoly->addPt($x+0.275*$xsize, $y+0.75*$ysize);
    $outPoly->addPt($x+0.15*$xsize, $y+$ysize);
    $im->filledPolygon($outPoly, $green);
    if ($ysize>8)  {
	my $inPoly = GD::Polygon->new();
	$inPoly->addPt($x+$xsize*.5, $y+0.2*$ysize);
	$inPoly->addPt($x+$xsize*.34, $y+0.6*$ysize-1);
	$inPoly->addPt($x+$xsize*.64, $y+0.6*$ysize-1);
	$im->filledPolygon($inPoly, $white);
    }
    return 1;
}
    
sub _png_draw_C  {
    my ($im, $x, $y, $xsize, $ysize, $white) = @_;
    my $blue = $im->colorAllocate(0,0,255);
    $im->arc($x+$xsize*0.54, $y+$ysize/2,1.08*$xsize,$ysize,0,360,$blue);
    $im->fill($x+$xsize/2, $y+$ysize/2, $blue);
    if ($ysize>12) {
	$im->arc($x+$xsize*0.53, $y+$ysize/2, 
		 0.75*$xsize, (0.725-0.725/$ysize)*$ysize,
		 0,360,$white);
	$im->fill($x+$xsize/2, $y+$ysize/2, $white);
	$im->filledRectangle($x+$xsize/2, $y+$ysize/4+1, 
			     $x+$xsize*1.1, $y+(3*$ysize/4)-1,
			     $white);
    }
    elsif ($ysize>3)  {
	$im->arc($x+$xsize*0.53, $y+$ysize/2, 
		 (0.75-0.75/$ysize)*$xsize, (0.725-0.725/$ysize)*$ysize,
		 0,360,$white);
	$im->fill($x+$xsize/2, $y+$ysize/2, $white);
	$im->filledRectangle($x+$xsize*0.25, $y+$ysize/2, 
			     $x+$xsize*1.1, $y+$ysize/2,
			     $white);

    }
   return 1;
}

sub _png_draw_G  {
    my ($im, $x, $y, $xsize, $ysize, $white) = @_;
    my $yellow = $im->colorAllocate(200,200,0);
    $im->arc($x+$xsize*0.54, $y+$ysize/2,1.08*$xsize,$ysize,0,360,$yellow);
    $im->fill($x+$xsize/2, $y+$ysize/2, $yellow);
    if ($ysize>20) {
	$im->arc($x+$xsize*0.53, $y+$ysize/2, 
		 0.75*$xsize, (0.725-0.725/$ysize)*$ysize,
		 0,360,$white);
	$im->fill($x+$xsize/2, $y+$ysize/2, $white);
	$im->filledRectangle($x+$xsize/2, $y+$ysize/4+1, 
			     $x+$xsize*1.1, $y+$ysize/2-1,
			     $white);
    }
    elsif($ysize>3)  {
	$im->arc($x+$xsize*0.53, $y+$ysize/2, 
		 (0.75-0.75/$ysize)*$xsize, (0.725-0.725/$ysize)*$ysize,
		 0,360,$white);
	$im->fill($x+$xsize/2, $y+$ysize/2, $white);
	$im->filledRectangle($x+$xsize*0.25, $y+$ysize/2, 
			     $x+$xsize*1.1, $y+$ysize/2,
			     $white);

    }
    $im->filledRectangle($x+0.85*$xsize, $y+$ysize/2,
			 $x+$xsize,$y+(3*$ysize/4)-1,
			  $yellow);
    $im->filledRectangle($x+0.6*$xsize, $y+$ysize/2,
			 $x+$xsize,$y+(5*$ysize/8)-1,
			  $yellow);
   return 1;
}
    
sub _png_draw_T {
    
    my ($im, $x, $y, $xsize, $ysize, $white) = @_;
    my $red = $im->colorAllocate(255,0,0);
    $im->filledRectangle($x, $y, $x+$xsize, $y+0.16*$ysize, $red);
    $im->filledRectangle($x+0.42*$xsize, $y, $x+0.58*$xsize, $y+$ysize, $red);
    return 1;
}
 


sub _svg_draw_A {
    
    my ($im, $x, $y, $xsize, $ysize) = @_;
    $im->polygon( points => [$x, $y+$ysize, $x+$xsize*.42, $y, $x+$xsize*.58, $y, $x+$xsize, $y+$ysize,
    			  			$x+0.85*$xsize, $y+$ysize, $x+0.725*$xsize, $y+0.75*$ysize,  $x+0.275*$xsize, $y+0.75*$ysize, 
    			  			$x+0.15*$xsize, $y+$ysize,  $x, $y+$ysize],
    			  fill => 'rgb(0,255,0)'
    			  );
    $im->polygon( points => [$x+$xsize*.5, $y+0.2*$ysize, $x+$xsize*.34, $y+0.6*$ysize, $x+$xsize*.64, $y+0.6*$ysize ],
    			  fill => 'rgb(255,255,255)');
    return 1;
}


sub _svg_draw_C  {
    my ($im, $x, $y, $xsize, $ysize) = @_;
    $im->ellipse(cx=>$x+$xsize*0.54, cy=>$y+$ysize/2, rx=>$xsize*0.54, ry=>$ysize/2,
                 fill => 'rgb(0,0,255)');
    $im->ellipse( cx=>$x+$xsize*0.53, cy=>$y+$ysize/2, rx=>$xsize*0.375, ry=>$ysize*0.375,
                 fill => 'rgb(255,255,255)');
	$im->rectangle(x=>$x+$xsize/2, y=>$y+$ysize/4,
					width =>$xsize*0.6, height =>$ysize/2,
					fill=> 'rgb(255,255,255)');
    return 1;
}    
    
sub _svg_draw_G  {
    my ($im, $x, $y, $xsize, $ysize, $white) = @_;
    $im->ellipse(cx => $x+$xsize*0.54, cy => $y+$ysize/2,
    			 rx => 0.54*$xsize, ry => $ysize/2,
    			 fill => 'rgb(200,200,0)');
    $im->ellipse(cx => $x+$xsize*0.53, cy => $y+$ysize/2,
    			 rx => 0.375*$xsize, ry => 0.375*$ysize,
    			 fill => 'rgb(255,255,255)');
    
	$im->rectangle(x=>$x+$xsize/2, y=>$y+$ysize/4,
					width =>$xsize*0.6, height =>$ysize/2,
					fill=> 'rgb(255,255,255)');
	$im->rectangle(x=>$x+0.80*$xsize, y=>$y+$ysize/2,
					width =>$xsize*0.208, height =>$ysize/4,
					fill=> 'rgb(200,200,0)');
	$im->rectangle(x=>$x+0.6*$xsize, y=>$y+$ysize/2,
					width =>$xsize*0.408, height =>$ysize/8,
					fill=> 'rgb(200,200,0)');
    
    return 1;
}

sub _svg_draw_T {
    
    my ($im, $x, $y, $xsize, $ysize, $white) = @_;
    $im->polygon (points =>[$x, $y, $x+$xsize, $y, $x+$xsize, $y+0.16*$ysize, 
    						$x+0.58*$xsize, $y+0.16*$ysize, $x+0.58*$xsize, $y+$ysize,
    						$x+0.42*$xsize, $y+$ysize, $x+0.42*$xsize, $y+0.16*$ysize, 
    						$x, $y+0.16*$ysize],
    			  fill => 'rgb(255,0,0)');
    return 1;
}
    


1;









