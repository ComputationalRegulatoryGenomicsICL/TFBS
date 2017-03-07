# This is the README file for TFBS modules distribution, Version 0.7.1


**NOTE**
TFBS perl module is no longer under active development.
All the functionality can be found in [TFBSTools](http://bioconductor.org/packages/TFBSTools/) Bioconductor package.
Users are highly encouraged to switch to TFBSTools.

## About TFBS
TFBS is a computational framework for transcription factor binding site
analysis. It can also be used for analysis involving other DNA paterns
representable by matrices, e.g. splice sites. 


## Contact info
Author: b.lenhard at imperial.ac.uk

TFBS website: http://tfbs.genereg.net/

Bug reports: https://github.com/ComputationalRegulatoryGenomicsICL/TFBS/issues

Please send bug reports, in particular about documentation which you
think is unclear or problems in installation.
The author is also interested in suggestions on directions in which TFBS functionality should be expanded.

## System requirements
* Tested on Linux/i686, Mac OS 10.12.3
* perl 5.10.0 or later
* ANSI C or Gnu C compiler for XS extensions
* bioperl 1.0 or later
* Additional perl module and application dependencies listed at http://tfbs.genereg.net/

## Documentation

The modules have a reasovably complete POD documentation. After instalation, type e.g.

```sh
perldoc TFBS::Matrix::ICM
```

to display the documentation for a particular module.

POD documentation for all modules, as well as additional information can be accessed from TFBS web page at 
http://tfbs.genereg.net/POD/.

A limited amount of example code, can also be found in the `examples/` directory. 
The current collection includes scripts for demonstrational purposes.
The explanations an be found in the source code of individual scripts.

## Installation
The TFBS modules are distributed as a tar file in standard perl CPAN distribution form. 
This means that installation is very simple. 
Once you have unpacked the tar distribution there is a directory called TFBS-xx/, which is where this file is.  
Move into that directory and issue the following commands:

```sh
perl Makefile.PL   # makes a system-specific makefile
make               # makes the distribution
make test          # runs the test code
make install       # [may need root access for system install. See below for how to get around this.]
```
 
This should build, test and install the distribution cleanly on your system, 
provided that all prerequisite modules have been installed.
Running perl Makefile.PL will ask you for a MySQL server write access 
details if you want to test TFBS::DB::JASPAR7 module.
You can safely choose not to do the test by answering "no" tho the first questions.

To install you need write permission in the `perl5/site_perl/` source area. 
Quite often this will require you (or someone else) becoming root, 
so you will want to talk to your systems manager if you don't  have the necessary access.

It is possible to install the package outside of the standard Perl5 location. See below for details.

### INSTALLING TFBS IN A PERSONAL OR PRIVATE MODULE AREA

If you lack permission to install perl modules into the standard `site_perl/` system area you can configure TFBS to
install itself anywhere you choose. 
Ideally this would be a personal perl directory or standard place where you plan to put all your 'local' or personal perl modules. 

*Note*: you _must_ have write permission to this area.

Simply pass a parameter to perl as it builds your system specific makefile.

Example:

```sh
perl Makefile.PL  PREFIX=/home/borisl/perllib
make
make test
make install
```

This will cause perl to install the TFBS modules in: `/home/borisl/perllib/lib/perl5/site_perl/`

And the man pages will go in: `/home/dag/My_Perl_Modules/lib/perl5/man/`

To specify a directory besides `lib/perl5/site_perl`, or if there are still permission problems, 
include an **INSTALLSITELIB** directive along with the PREFIX:

```sh
perl Makefile.PL  PREFIX=/home/borisl/perl INSTALLSITELIB=/home/borisl/perl/lib
```

See below for how to use modules that are not installed in the standard Perl5 location.

### USING MODULES NOT INSTALLED IN THE STANDARD PERL LOCATION
You can explicitly tell perl where to look for modules by using the lib module which comes standard with perl. 

Example:

```sh
#!/usr/bin/perl -w
use lib "/home/borisl/perllib/";
use TFBS::PatternGen::Gibbs;
# etc...
```
