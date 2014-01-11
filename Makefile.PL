require 5.006;
use ExtUtils::MakeMaker;


my $NAME     = 'TFBS';
my $DISTNAME = "TFBS";
my $VERSION  = "0.5.0";

get_sql_data();

WriteMakefile(
	      NAME	  => $NAME,
	      DISTNAME    => $DISTNAME,
	      VERSION     => $VERSION,
	      'dist'      => {  COMPRESS     => 'gzip -9f',
				SUFFIX       => '.gz', 
				DIST_DEFAULT => 'all tardist',
			    },

	      );

sub get_sql_data  {
    my $ans = "abc";
    do {
	print "Do you have write access to a MySQL database server? [n] ";
	$ans=<STDIN>; chomp $ans;
    } until $ans =~ /^y|n/i or $ans eq "";

    if (uc(substr($ans,0,1)) eq 'Y')  {
	print "\nOK, tell me more about it.\n\n";
	print "\tHost name : [localhost] ";	
	my $hostname = <STDIN>; chomp $hostname;
	$hostname = 'localhost' unless $hostname;

	print "\tUsername  : [none]     ";
	my $username = <STDIN>; chomp $username;
	$username = '' unless $username;
	
	print "\tPassword  : [none]     ";
	my $password = <STDIN>; chomp $password;
	$password = '' unless password;

	open FILE, ">t/MYSQLCONNECT" 
	    or die "Can't write to t/ directory, stopped";
	print FILE join("::", $hostname, $username, $password, " ");
	close FILE;
    }
    else {
	unlink "t/MYSQLCONNECT" if -e "t/MYSQLCONNECT";
    }
}

BEGIN {
    my $fail = 0;
    unless (eval "use  Bio::Root::RootI;1") {
	$fail = 1;
	print qq!

	-------------------------------------------------
		            WARNING
	-------------------------------------------------

	 Bioperl does not seem to be installed.

         Bioperl 1.0 or newer is unconditionally required by TFBS.

	 Please install Bioperl BEFORE proceeding with 
	 TFBS installation. Go to http://bioperl.org for 
	 information on how to obtain and install it.

	-------------------------------------------------

	 !;
    }

    unless (eval "use PDL; 1") {
	$fail = 1;
	print qq!

	-------------------------------------------------
		            WARNING
	-------------------------------------------------

	 PDL (Perl Data Language) does not seem to be 
	 installed.

         PDL is unconditionally required by TFBS.

	 Please install PDL BEFORE proceeding with 
	 TFBS installation. Go to http://pdl.perl.org for 
	 information on how to obtain and install it.

         NOTE FOR LINUX USERS: PDL binary packages 
	 (.rpm, .deb) are included in all major Linux 
	 distributions and repositories. Unless you are an 
	 advanced Linux user, it is recommended that you 
	 install PDL from one of these packages, 
	 or from CPAN command line.
        
	-------------------------------------------------

	 !;
    }
    unless (eval "use File::Temp; 1") {
	$fail = 1;
	print qq!

	-------------------------------------------------
		            WARNING
	-------------------------------------------------

	 File::Temp package does not seem to be installed.

         File::Temp is unconditionally required by TFBS.

	 Please install File::Temp BEFORE proceeding with 
	 TFBS installation. The package is available from
	 CPAN (http://cpan.perl.org/).

	-------------------------------------------------

	 !;
    }
    if ($fail) {
	print STDERR "TFBS installation aborted.\n";
	print STDERR "Please install one or more missing modules before proceeding\n\n";
	exit(0);
    }
    unless (eval "use GD; 1") {
	# do not fail
	print qq!

	-------------------------------------------------
		            WARNING
	-------------------------------------------------
         GD.pm does not seem to be installed.

         GD is reqired to produce "sequence logos" from 
	 information content matrices. If you need this 
	 functionality, please visit 
	 http://stein.cshl.org/WWW/software/GD/ 
         for information on obtaining and installing GD.
        -------------------------------------------------

!;
    }
    
};
