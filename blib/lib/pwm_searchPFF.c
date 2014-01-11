/*--------------------------------------------------------------------
 * BUGS or limitations
 *    mask option not yet implemented.
 *
 * Extensions/revisions worth considering
 *    pwm_calc that calculates pwm scores for every position; pipe to
 *    selection programs that pull what I want.
 *------------------------------------------------------------------*/
/*--------------------------------------------------------------------
 * This version is a quick and dirty modification of Wyeth Wasserman's
 * standalone pwm_searchPFF program.
 * 
 * Boris Lenhard, August 2001
 *
 * Read pwm matrix
 *    Figure maximum and minimum possible scores
 * Read sequences (fasta format) one at a time, and for each:
 *    Window through the sequence and complement
 *
 *    Find all occurrences of pattern with 
 *      matrix score > threshold
 *
 *    If -a flag is set just print all the values, otherwise:
 *
 *    If -b flag is not set, 
 *        For each find, show seq name, location, find, score
 *    otherwise
 *        just show the best hit for this sequence
 *    If "-m" option is set, write out all input sequences to
 *       filename given, with finds replaced by 'n's.
 *
 * Exit: 0 for success, -1 otherwise.
 *------------------------------------------------------------------*/
#include "pwm_search.h"

int do_search(char* matrixfile, 
	      char* seqfile,
	      float threshold,
	      char* tfname,
	      char* tfclass,
	      char* outfile)
     /*was: main
       int argc;
       char **argv;*/
{
   double pwm[2*MAXCOUNTS];   /* for pwm matrix */
                              /* do own indexing; 5*pos + nt */
   int exitval = -1;          /* exit value from main */
   struct arguments args;          /* command line args */
   FILE *fp;                  /* for sequence input file */
   FILE *outfp;
   NUM_ERRS = 0;
    if (__DEBUG__) fprintf(stderr, "%s %s %f %s %s %s\n", matrixfile, seqfile, threshold, tfname, tfclass, outfile);
   if ( __DEBUG__ )
      announce("+++\nEntering main.\n+++\n");

   /* Parse command line arguments */
   /*if ( get_cmd_args(argc,argv,&args) )
   {
      err_log(
      "Usage:  pwm_searchPFF pwm_file seq_file threshold [-a][-b]|[-m mask_file] [-n TFname] [-c TFclass]\n"
             );
	     }*/

   strcpy(args.counts_file, matrixfile);
   strcpy(args.seq_file, seqfile);
   args.threshold = threshold;
   strcpy(args.name, tfname);
   strcpy(args.class, tfclass);
   args.print_all = 0;
   args.best_only= 0;
   /* Read in the pwm; calculate max/min score */
   //else 
   if ( get_matrix(&args,pwm) )
   {
      err_log("MAIN: get_matrix failed.");
   }

   /* Open the sequence file */
   else if ( (fp=fopen(args.seq_file,"r")) == NULL )
   {
      err_log("MAIN: open_seq_file failed.");
   }
   else if ( (outfp=fopen(outfile,"w")) == NULL )
   {
      err_log("MAIN: open_outfile failed.");
   }
 
   /* Loop on sequences */
   else if ( loop_on_seqs(&args,pwm,fp,outfp) )
   {
      err_log("MAIN:  loop_on_seqs failed.");
   }

   /* Normal completion */
   else
   {
      exitval = 0;
   }

   /* Clean up and close out */
   err_show();
   fclose(fp);
   fclose(outfp);
   if ( __DEBUG__ )
      announce("+++\nLeaving main.\n+++\n");
 
   return(exitval);
}

/*--------------------------------------------------------------------
 * Announce
 *
 * Print a debugging message
 *
 * Returns 0
 *------------------------------------------------------------------*/
int
announce(msg)
char *msg;
{
   int retval = 0;

   fprintf(stderr,msg);

   return(retval);
}

/*--------------------------------------------------------------------
 * BEST_SAVE - Save the best score so far
 * 
 * Called by do_seq
 * 
 * Returns: 0 
 *------------------------------------------------------------------*/
int best_save(struct arguments* pargs, long base, int strand, double score)
     //struct arguments *pargs;  /* args from command line */
     //long base;           /* base where score occurs */
     //int strand;          /* strand where score occurs */
     //double score;        /* score of hit to save */
{
   if ( pargs->best_base < 0  ||  score > pargs->best_score )
   {
      pargs->best_base = base;
      pargs->best_score = score;
      pargs->best_strand = strand;
   }

   return(0);
}

/*--------------------------------------------------------------------
 * BEST_PULL - Copy back the best score saved
 * 
 * Called by do_seq
 * 
 * Returns: 0 
 *------------------------------------------------------------------*/
best_pull(pargs,pbase,pstrand,pscore)
struct arguments *pargs;  /* args from command line */
long *pbase;         /* base where score occurs */
int *pstrand;        /* strand where score occurs */
double *pscore;      /* score of hit to pull back */
{
   *pbase = pargs->best_base;
   if ( pargs->best_base >= 0 )
   {
      *pscore = pargs->best_score;
      *pstrand = pargs->best_strand;
   }
   return(0);
}

/*--------------------------------------------------------------------
 * DO_SEQ - Search through the given sequence with the given matrix
 * 
 * Called by loop_on_seqs
 * 
 * Returns: 0 for success, -1 for failure.
 *------------------------------------------------------------------*/
int
do_seq(pargs,pwm,seqid,seq,outfp)
struct arguments *pargs;  /* args from command line */
double *pwm;         /* pwm from get_matrix */
char *seqid;         /* id of sequence to work on */
char *seq;           /* the sequence to work on */
FILE *outfp;
{
   double backward_score;
   double forward_score;
   double score;
   long base;
   int done = 0;
   int nt;
   int pos;
   int retval = 0;
   int strand;
   long l;
   long nhit=0L;
   struct HIT hits[MAXHITS];

   if ( __DEBUG__ )
      announce("+++\nEntering do_seq.\n+++\n");

   /* first make sure sequence is long enough */
   for ( base=0; base < pargs->width; ++base )
   {
      if ( seq[base] == '\0' )
         done = 1;
   }

   /* loop on windows */
   pargs->best_base = -1;
   for ( base=0; !retval && !done && seq[base+pargs->width-1]; ++base )
   {
      forward_score = 0.0;
      backward_score = 0.0;
      for ( pos=0; pos<pargs->width; ++pos )
      {
         nt = TRANS[seq[base+pos]];
         forward_score += pwm[5*pos + nt];
         nt = ( nt==4 ) ? 4 : 3-nt;
         backward_score += pwm[5*(pargs->width - pos -1) + nt];
      }
      if ( forward_score > pargs->threshold )
      {
         if ( pargs->print_all )
         {
            if ( save_hit(base,0,forward_score,hits,&nhit) )
            {
               err_log("DO_SEQ:  save_hit failed");
               retval = -1;
            }
         }
         else if ( pargs->best_only )
         {
            best_save(pargs,base,0,forward_score);
         }
         else if ( output(pargs,seqid,base,seq,0,forward_score,outfp) )
         {
             err_log("DO_SEQ:  output failed");
             retval = -1;
         }
      }
      if ( backward_score > pargs->threshold )
      {
         if ( pargs->print_all )
         {
            if ( save_hit(base,1,backward_score,hits,&nhit) )
            {
               err_log("DO_SEQ:  save_hit failed");
               retval = -1;
            }
         }
         else if ( pargs->best_only )
         {
            best_save(pargs,base,1,backward_score);
         }
         else if ( output(pargs,seqid,base,seq,1,backward_score, outfp) )
         {
             err_log("DO_SEQ:  output failed");
             retval = -1;
         }
      }
      
   }

   if ( pargs->print_all )
   {
      for ( l=0; l<nhit; ++l )
         printf("%ld %.3f\n",1+hits[l].base,hits[l].score);
/*
      printf("# forward strand hits\n\n");
      for ( l=0; l<nhit; ++l )
      {
         if ( hits[l].strand == 0 )
            printf("%ld %.3f\n",1+hits[l].base,hits[l].score);
      }
      printf("\n# comp strand hits\n\n");
      for ( l=0; l<nhit; ++l )
      {
         if ( hits[l].strand == 1 )
            printf("%ld %.3f\n",1+hits[l].base,hits[l].score);
      }
*/
   }

   else
   {
      best_pull(pargs,&base,&strand,&score);
      if ( base>=0 )
      {
         if ( output(pargs,seqid,base,seq,strand,score,outfp) )
         {
             err_log("DO_SEQ:  output failed");
             retval = -1;
         }
      }
   }
 
   if ( __DEBUG__ )
      announce("+++\nLeaving do_seq.\n+++\n");

   return(retval);
 
}

/***********************************************************************
 * ERR_LOG and ERR_SHOW
 *
 * A pair of functions for saving up and then printing error messages.
 * err_log stores away an error message each time it is called.  When
 * err_show is called it prints all the messages saved up so far.
 *
 * Neither function returns a value
 **********************************************************************/
void
err_log(msg)
char *msg;
{
   if ( __DEBUG__ )
      announce("+++\nEntering err_log\n+++\n");
 
   NUM_ERRS++;
   if ( (__ERR__[NUM_ERRS-1] = (char *) malloc( 1+strlen(msg) ) ) == NULL )
      __ERR__[NUM_ERRS - 1] = PANIC;
   else
      strcpy( __ERR__[NUM_ERRS - 1],msg );
 
   if ( __DEBUG__ )
      announce("+++\nLeaving err_log\n+++\n");
   return;
}     
 
void
err_show()
{
   int err_num;
   for ( err_num=0; err_num<NUM_ERRS; ++err_num )
      fprintf(stderr,"%s\n",__ERR__[err_num]);
   return;
}     

/*--------------------------------------------------------------------
 * GET_CMD_ARGS - Parse execute line, fill arg structure.
 * 
 * Called by main.
 * 
 * Returns: 0 for success, -1 for failure.
 *------------------------------------------------------------------*/
int get_cmd_args(argc,argv,pargs)
int argc;            /* argc as passed to main */
char **argv;         /* argv as passed to main */
struct arguments *pargs;  /* args from command line */
{
   int retval = 0;
   int arg_count = 4;

   if ( __DEBUG__ )
      announce("+++\nEntering get_cmd_args\n+++\n");

   /* See if we got at least three arguments */
   if ( argc < 4 )
   {  retval = -1;
      err_log("GET_CMD_ARGS: Too few arguments.");
   }

   /* Get the arguments */
   else
   {  strcpy(pargs->counts_file,argv[1]);
      strcpy(pargs->seq_file,argv[2]);
      pargs->threshold = atof(argv[3]);
      pargs->best_only = 0;
      pargs->print_all = 0;
      pargs->mask_file[0] = '\0';
      while (arg_count < argc) 
        { 
           if ( argv[arg_count][0]=='-' && argv[arg_count][1]=='b' )
              {
               pargs->best_only = 1;
               arg_count++;
              }
            else if ( argv[arg_count][0]=='-' && argv[arg_count][1]=='a' )
              {
               pargs->print_all = 1;
               arg_count++;
              }
            else if ( arg_count<argc-1 && 
               argv[arg_count][0]=='-' && argv[arg_count][1]=='m' && 
               argv[arg_count+1][0]!='\0' 
               )
              {
               strcpy(pargs->mask_file,argv[arg_count+1]);
               arg_count = arg_count+2;
	      }
            else if ( arg_count<argc-1 && 
               argv[arg_count][0]=='-' && argv[arg_count][1]=='n' && 
               argv[arg_count+1][0]!='\0' 
               )
              {
               strcpy(pargs->name,argv[arg_count+1]);
               arg_count = arg_count+2;
	      }
           else if ( arg_count<argc-1 && 
               argv[arg_count][0]=='-' && argv[arg_count][1]=='c' && 
               argv[arg_count+1][0]!='\0' 
               )
              {
               strcpy(pargs->class,argv[arg_count+1]);
               arg_count = arg_count+2;
	      }
            else 
	      {
	      arg_count++;
	      }
     }
   }
   if ( __DEBUG__ )
      announce("+++\nLeaving get_cmd_args\n+++\n");
   return( retval );
}
 
/*--------------------------------------------------------------------
 * GET_MATRIX - Read in pwm.
 * 
 * Called by main.
 * 
 * Returns: 0 for success, -1 for failure.
 *------------------------------------------------------------------*/
int
get_matrix(struct arguments* pargs, double* pwm)
     /* struct arguments *pargs;  args from command line 
        double *pwm;      array for pwm */
                              /* do own indexing; 5*pos + nt */
{
   double counts[2*MAXCOUNTS];
   double max_log;
   double min_log;
   double scratch[1+MAXCOUNTS];
   int done = 0;
   int nt;
   int num_counts;
   int pos;
   int retval=0;
   FILE *fp;         /* stream for counts file */

   if ( __DEBUG__ )
      announce("+++\nEntering get_matrix\n+++\n");

   /* Open the file */
   if ( (fp=fopen(pargs->counts_file,"r")) == NULL )
   {
      err_log("GET_MATRIX:  could not open specified file.");
      retval = -1;
   }

   /* Read in the real numbers without regard to dimension */
   else
   {
      for ( num_counts=0; !done && num_counts<MAXCOUNTS; ++num_counts )
      {
         if ( fscanf(fp,"%lf,%*c",scratch+num_counts) == EOF )
            done = 1;
      }
      if ( !done )
      {
         err_log("GET_MATRIX:  too many counts.");
         retval = -1;
      }
   }

   fclose(fp);
   if ( !retval )
   {

   /* Put the weights where they belong, and put avg of ACGT for 'n' */
      pargs->width = num_counts/4;
      for ( pos=0; pos<pargs->width; ++pos )
      {
         for ( nt=0; nt<4; ++nt )
         {
            pwm[5*pos + nt] = scratch[(pargs->width)*nt + pos];
         }

         pwm[5*pos + 4] = 
           (pwm[5*pos + 0] +
            pwm[5*pos + 1] +
            pwm[5*pos + 2] +
            pwm[5*pos + 3]
           ) / 4;
      }


   /* Next the extreme scores */
      pargs->max_score = 0;
      pargs->min_score = 0;
      for ( pos=0; pos<pargs->width; ++pos )
      {
         max_log = -10.0;
         min_log = 10.0;
         for ( nt=0; nt<4; ++nt )
         {
            max_log = ( max_log>pwm[5*pos+nt] ) ? max_log : pwm[5*pos+nt];
            min_log = ( min_log<pwm[5*pos+nt] ) ? min_log : pwm[5*pos+nt];
         }
         pargs->max_score += max_log;
         pargs->min_score += min_log;
      }
   }

   if ( __DEBUG__ )
      announce("+++\nLeaving get_matrix\n+++\n");

   return (retval);
}

/*--------------------------------------------------------------------
 * GET_SEQUENCE
 * 
 * Get the next sequence from the input file (fasta format)
 * 
 * Called by loop_on_seqs.
 * 
 * Return 0 normally, -1 on error, 1 if called at EOF.
 *------------------------------------------------------------------*/
get_sequence(fp,seq_id,sequence)
FILE *fp;           /* file to read */
char *seq_id;       /* name of sequence */
char *sequence;     /* text of sequence */
{
   char msg[2*MAX_LINE];
   int c;
   int done=0;
   int position;
   int retval = 0;
   int word = 0;
   int count = 0;
   long base = 0L;
   char line[MAX_LINE]; // was static
   int at_eof = 0;      // was static
   int first_time=1;    // was static

   if ( __DEBUG__ )
   {
      announce("+++\nEntering Get_sequence\n+++\n");
   }
 
   if ( first_time )
   {
      first_time=0;
      if ( fgets(line,MAX_LINE,fp)==NULL )
      {
         at_eof = 1;
      }
   }
   if ( at_eof )  /* this time or last time */
   {
      retval = 1;
   }
 
  /* At this point, line should always be the first line of an entry */
  /* Pull out the id */
   if ( !retval )
      {
      strcpy(seq_id,line+1);
      seq_id[ strlen(seq_id) -1 ] = '\0';
      while (count < strlen(seq_id) && !word)
        {
        if (seq_id[count] == ' ') 
            {
            word++;
            seq_id[count]= '\0';
            }
        count++;
        }

   }
 
  /* Read in the sequence */
   while ( !retval && !done )
   {
    if ( __DEBUG__ )
       {
	  announce("+++\nReading in...\n+++\n");
       }	
 
      if ( fgets(line,MAX_LINE,fp) == NULL )
      {
         at_eof = 1;
         done = 1;
      }
      else if ( line[0] == '>' )
      {
         done = 1;
      }
      else
      {
         for ( position=0; !retval && line[position]!='\0'; ++position)
         {
            c = line[position];
            if ( !isdigit( c ) && !isspace( c ) )
            {
               if ( base >= SEQLEN )
               {
                  err_log("GET_SEQUENCE:  Sequence too long.");
                  retval = -1;
               }
               else
               {
                  sequence[base++] = c;
               }
            }
         }
      }
   }
   sequence[base] = '\0';
 
   if ( __DEBUG__ )
   {
      announce("+++\nLeaving Get_sequence\n+++\n");
      sprintf(msg,"seq_id=%s\nlength=%ld\n",
                   seq_id,    base
             );
      announce(msg);
   }
 
   return(retval);
}

/*--------------------------------------------------------------------
 * LOOP_ON_SEQS - Loop through the sequences of the input file,
 * doing the search and output.
 * 
 * Called by main.
 * 
 * Returns: 0 for success, -1 for failure.
 *------------------------------------------------------------------*/
int
loop_on_seqs(pargs,pwm,fp, outfp)
struct arguments *pargs;  /* args from command line */
double *pwm;         /* pwm, from get_matrix  */
FILE *fp;            /* sequence file pointer */
FILE *outfp;         /* output file pointer   */
{
   char seq[SEQLEN+1];
   char seqid[SEQNAMELEN+1];
   int done = 0;
   int retval=0;
   if ( __DEBUG__ )
      announce("+++\nEntering loop_on_seqs\n+++\n");

   /* Main loop */
   while ( !retval && !done )
   {
      done = get_sequence(fp,seqid,seq);
      if ( done == -1 )
      {
         err_log("LOOP_ON_SEQS:  get_sequence failed.");
         retval = -1;
      }
      else if ( done == 0 )
      {
         if ( do_seq(pargs,pwm,seqid,seq,outfp) )
         {
            err_log("LOOP_ON_SEQS:  do_seq failed.");
            retval = -1;
         }
      }
   }

   if ( __DEBUG__ )
      announce("+++\nLeaving loop_on_seqs\n+++\n");

   return (retval);
}

/*--------------------------------------------------------------------
 * MARK - write "width" dashes, to mark strand
 * 
 * Called by output.
 * 
 * Returns: 0 for success, -1 for failure.
 *------------------------------------------------------------------*/
int
mark(width)
int width;
{
   int pos;

   for ( pos=0; pos<width; ++pos )
      putchar('-');
   putchar('\n');
}

/*--------------------------------------------------------------------
 * OUTPUT - Print a find in its context.
 * 
 * Called by do_seq.
 * 
 * Returns: 0 for success, -1 for failure.
 *------------------------------------------------------------------*/
int
output(pargs,seqid,base,seq,strand,score, outfp)
struct arguments *pargs;  /* args from command line */
char *seqid;         /* id of sequence in which pattern found */
long base;           /* base of pattern nearest base 0 of top strand */
char *seq;           /* the sequence itself, ascii, top strand */
int strand;          /* find is on (0) top strand or (1) bottom */
double score;        /* score of the find */
FILE *outfp;
{
   int pos;
   int retval = 0;

   if ( __DEBUG__ )
      announce("+++\nEntering output\n+++\n");

/* if 1
#   printf("*********************************************\n");
   printf("%s\tTFBS\t",seqid);

#   printf("Score: %6.3f(%6.1f) in range %6.3f(0.0) to %6.3f(100.0)\n",
#      score,
#      100*(score - pargs->min_score)/(pargs->max_score - pargs->min_score),
#      pargs->min_score,
#      pargs->max_score);

#   printf("\n%ld\n",base+1);
*/
   fprintf(outfp, "%s\tTFBS\t%s\t%s\t",seqid,pargs->name,pargs->class);

   if (strand) 
     { 
       fprintf(outfp, "-\t"); /* FIXED BY BORIS : 1 is for "-" strand */
     }
     else fprintf(outfp, "+\t"); /* FIXED BY BORIS : 0 is for "+" strand */

   fprintf(outfp, "%6.3f\t%6.1f\t", score,
      100*(score - pargs->min_score)/(pargs->max_score - pargs->min_score));

   fprintf(outfp, "%ld\t%ld\t",base+1,base+pargs->width);

   for ( pos=0; pos<pargs->width; ++pos )
   {
      putc(seq[base+pos], outfp);
   }
   putc('\n', outfp);
 
/* #endif */
   if ( __DEBUG__ )
      announce("+++\nLeaving output\n+++\n");

   return( retval );
}

/*--------------------------------------------------------------------
 * SAVE_HIT - save location, strand and score of a hit in an array of such
 * 
 * Called by do_seq.
 * 
 * Returns: 0 for success, -1 for failure.
 *------------------------------------------------------------------*/
int
save_hit(base,strand,score,hits,pnhit)
long base;
int strand;
double score;
struct HIT *hits;
long *pnhit;
{
   int retval = 0;

   if ( *pnhit == MAXHITS )
   {
      err_log("SAVE_HIT:  MAXHITS limit reached.");
      retval = -1;
   }

   hits[*pnhit].base = base;
   hits[*pnhit].strand = strand;
   hits[*pnhit].score = score;
   *pnhit = *pnhit + 1;

   return(retval);
}
