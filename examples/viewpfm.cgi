#!/usr/bin/perl -w 

# viewpfm.cgi
#   by Boris Lenhard
#
# See POD documentation for this CGI script at the end of the file
#



use strict;
use CGI ();
use TFBS::Matrix::PFM;
use TFBS::DB::FlatFileDir;


use constant DATABASE_DIR => "examples/SAMPLE_FlatFileDir";

  # The directory to store created logo image: we need an absolute
  # path for access by the script, and a relative path for 
  # access by the web browser
use constant ABSOLUTE_IMAGE_DIR => "/var/www/html/TEMP";
use constant RELATIVE_IMAGE_DIR => "/TEMP";
use constant THIS_SCRIPT => "/cgi-bin/viewpfm.cgi";

  # IMPORTANT NOTE: this script does not delete image files it creates
  # page 

  # connect to FlatFileDir matrix database
  # (there is a sample FlatFileDir matrix database directory 
  # examples/SAMPLE_FlatFileDir in the TFBS distribution package)
  # Change this line if you want to use a different type of database
  # (e.g. TFBS::DB::JASPAR2)

my $db = TFBS::DB::FlatFileDir->connect(DATABASE_DIR);

if (CGI::param("matrix_id")) { # matrix entry
    matrix_info($db, CGI::param("matrix_id"));
}
else { # draw logo
    matrix_list_page($db);
}


sub matrix_list_page  {
    my ($db) = @_;
    
    my $q = CGI->new;

       # get all matrices (TFBS::Matrix::PWM objects) into a TFBS::MatrixSet object

    my $matrixset = $db->get_MatrixSet(-matrixtype=>"PFM");
       
    print $q->header, $q->start_html;
    print $q->h1("Matrices in the database");
    
    my $matrix_iterator = $matrixset->Iterator(-sort_by=>"ID");
    my @table_rows = ($q->Tr($q->th([ 'MatrixID', 'Name', 
			      'Class','Length', 'Total IC'])));

    while (my $pfm = $matrix_iterator->next)  {
	push @table_rows, 
	$q->Tr($q->td([$q->a({-href=>THIS_SCRIPT."?matrix_id=".$pfm->ID},
			     $pfm->ID),
		       $pfm->name, $pfm->class, 
		       $pfm->length, $pfm->to_ICM->total_ic]));

    }
	
    print $q->table({-border=>1}, @table_rows);
    print $q->end_html;
}


sub matrix_info {
    my ($db, $matrix_id) = @_;
    my $q = CGI->new;
    my $pfm = $db->get_matrix_by_ID($matrix_id);
    
    unless(defined $pfm) {
	# first we draw a sequence logo and store it in a .png file
	
	my $logofile = $pfm->ID.".png";
          # we want image size to vary with motif length:
	my $xsize = 60+20*$pfm->length();
	  # ...but it should not be too narrow for short motifs:
	$xsize=278 if($pfm->length()<10);
	    
	$pfm->draw_logo(-file =>ABSOLUTE_IMAGE_DIR."/$logofile",
			      -full_scale =>2.25,
			      -xsize      =>$xsize,
			      -ysize      =>190, 
			      -graph_title=> $pfm->name,
			      -x_title=>"Nucleotide position", 
			      -y_title=>"ic [bits]");

	# then we output the page
	print $q->header, $q->start_html;
	print $q->div("Matrix ID : ".$pfm->ID);
	print $q->div("Transctiption factor name : ", $pfm->name);
	print $q->div("Structural class              : ", $pfm->class);
	print $q->div("Total information content     : ", 
	       sprintf("%2.2f",$pfm->to_ICM->total_ic));
	print $q->div("Matrix:");
	print $q->div($q->pre($pfm->prettyprint));
	print $q->div("Sequence logo:");
	print $q->img({-src=>RELATIVE_IMAGE_DIR."/$logofile"});
	print $q->div($q->a({-href=>THIS_SCRIPT}, "Back to matrix list"));
	print $q->end_html;
    }
    else  { # matrix not found
	print $q->header, $q->start_html;
	print $q->h2("Matrix $matrix_id not found in the database");
	print $q->a({-href=>THIS_SCRIPT}, "Back to matrix list");
	print $q->end_html;
    }

}
