#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "pwm_searchPFF.c"
#include <stdio.h>


MODULE = TFBS::Ext::pwmsearch		PACKAGE = TFBS::Ext::pwmsearch		
int
search_xs (matrixfile, seqfile, threshold, tfname, tfclass, outfile)
    char* matrixfile;
    char* seqfile;
    double threshold;
    char* tfname;
    char* tfclass;
    char* outfile;
    CODE:
	do_search(matrixfile, seqfile, threshold, tfname, tfclass, outfile);

