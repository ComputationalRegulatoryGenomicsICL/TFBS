/*---------------------------------------------------------------
 * INCLUDES
 *---------------------------------------------------------------*/
#include <stdio.h>
#include <math.h>

/*---------------------------------------------------------------
 * DECLARATIONS
 *---------------------------------------------------------------*/
/* 
extern double atof();
extern double log2();
extern double sqrt();
extern FILE *fopen();
*/ 
void err_log(), err_show();

/*---------------------------------------------------------------
 * DEFINES
 *---------------------------------------------------------------*/
#define __DEBUG__ 0              /* put debug messages on */
#define FNAMELEN 1000        /* max allowed length of file name */
#define MAX_LINE 200
#define MAXCOUNTS 1000       /* max number of counts in count matrix */
#define MAXERR 100          /* max number of errors that err_log can handle */
#define MAXHITS 1000
#define SEQLEN 1000000       /* max sequence length allowed */
#define SEQNAMELEN MAX_LINE  /* max allowed sequence name length */

/*---------------------------------------------------------------
 * GLOBALS
 *---------------------------------------------------------------*/
static char PANIC[] = "err_log function failure";

static char *__ERR__[MAXERR];

static int NUM_ERRS=0;

static char SQCOMP[] =   /* calculate base on complementary strand */
   {                        /* ASCII chars; IUPAC conventions */
   /* Control characters unchanged */
   '\000','\001','\002','\003','\004','\005','\006','\007',
   '\010','\011','\012','\013','\014','\015','\016','\017',
   '\020','\021','\022','\023','\024','\025','\026','\027',
   '\030','\031','\032','\033','\034','\035','\036','\037',
   /* Punctuation and digits unchanged */
   '\040','\041','\042','\043','\044','\045','\046','\047',
   '\050','\051','\052','\053','\054','\055','\056','\057',
   '\060','\061','\062','\063','\064','\065','\066','\067',
   '\070','\071','\072','\073','\074','\075','\076','\077',
   /* Capitals go to capitals */
   '\100',   'T',   'V',   'G',   'H',   '?',   '?',   'C',   /* @,A-G */
      'D',   '?',   '?',   'M',   '?',   'K',   'N',   '?',   /* H-O */
      '?',   '?',   'Y',   'S',   'A',   '?',   'B',   'W',   /* P-W */
      '?',   'R',   '?','\133','\134','\135','\136','\137',   /* X-Z,etc */
   /* Lower case goes to lower case */
   '\140',   't',   'v',   'g',   'h',   '?',   '?',   'c',
      'd',   '?',   '?',   'm',   '?',   'k',   'n',   '?',
      '?',   '?',   'y',   's',   'a',   '?',   'b',   'w',
      '?',   'r',   '?','\173','\174','\175','\176','\177'
   };
 
static int TRANS[] =   /* translate characters to numbers */
   {                        /* A=0; C=1; G=2; T=3; other = 4 */
   /* Control characters */
    4,4,4,4,4,4,4,4,
    4,4,4,4,4,4,4,4,
    4,4,4,4,4,4,4,4,
    4,4,4,4,4,4,4,4,
   /* Punctuation and digits */
    4,4,4,4,4,4,4,4,
    4,4,4,4,4,4,4,4,
    4,4,4,4,4,4,4,4,
    4,4,4,4,4,4,4,4,
   /* Capitals */
    4,0,4,1,4,4,4,2,   /* @,A-G */
    4,4,4,4,4,4,4,4,   /* H-O */
    4,4,4,4,3,3,4,4,   /* P-W */
    4,4,4,4,4,4,4,4,   /* X-Z,etc */
   /* Lower case */
    4,0,4,1,4,4,4,2,   /* @,A-G */
    4,4,4,4,4,4,4,4,   /* H-O */
    4,4,4,4,3,3,4,4,   /* P-W */
    4,4,4,4,4,4,4,4   /* X-Z,etc */
   };
 
 
/*---------------------------------------------------------------
 * STRUCTURE DEFINITIONS
 *---------------------------------------------------------------*/
/* ARGUMENTS -- Structure to contain shared arguments */
struct arguments
{
   char counts_file[FNAMELEN+1];   /* file name, count matrix */
   char mask_file[FNAMELEN+1];     /* file name, masked seq output,
                                      "" means none. */
   char seq_file[FNAMELEN+1];      /* file name, sequences */
   char name[FNAMELEN+1];          /* TF name */
   char class[FNAMELEN+1];         /* TF structural class */
   int print_all;                  /* print scores of all hits */
   long best_base;                 /* base for best score on sequence */
   int best_only;                  /* only show best score on each
                                      sequence */
   double best_score;              /* best score on this sequence */
   int best_strand;                /* strand for best score on sequence */
   double max_score;               /* max score possible (implied 
                                      from pwm) */
   double min_score;               /* min score possible (implied 
                                      from pwm) */
   double threshold;               /* print stuff with log score >
                                      max_possible - threshold */
   int width;                      /* pattern width (implied from
                                      number of counts) */
};

/* HIT - location and score of a site scoring above threshold */
struct HIT
{
   long base;      /* location */
   int strand;     /* 0 forward, 1 complement */
   double score;   /* score */
};







