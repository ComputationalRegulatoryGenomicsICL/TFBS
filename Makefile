# This Makefile is for the TFBS extension to perl.
#
# It was generated automatically by MakeMaker version
# 6.74 (Revision: 67400) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#       ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#

#   MakeMaker Parameters:

#     BUILD_REQUIRES => {  }
#     CONFIGURE_REQUIRES => {  }
#     DISTNAME => q[TFBS]
#     NAME => q[TFBS]
#     PREREQ_PM => {  }
#     TEST_REQUIRES => {  }
#     VERSION => q[0.5.0]
#     dist => { DIST_DEFAULT=>q[all tardist], COMPRESS=>q[gzip -9f], SUFFIX=>q[.gz] }

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /System/Library/Perl/5.12/darwin-thread-multi-2level/Config.pm).
# They may have been overridden via Makefile.PL or on the command line.
AR = ar
CC = clang
CCCDLFLAGS =  
CCDLFLAGS =  
DLEXT = bundle
DLSRC = dl_dlopen.xs
EXE_EXT = 
FULL_AR = /usr/bin/ar
LD = clang -mmacosx-version-min=10.8
LDDLFLAGS = -arch i386 -arch x86_64 -bundle -undefined dynamic_lookup -L/usr/local/lib -fstack-protector
LDFLAGS = -arch i386 -arch x86_64 -fstack-protector -L/usr/local/lib
LIBC = 
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = darwin
OSVERS = 12.0
RANLIB = /usr/bin/ar s
SITELIBEXP = /Library/Perl/5.12
SITEARCHEXP = /Library/Perl/5.12/darwin-thread-multi-2level
SO = dylib
VENDORARCHEXP = /Network/Library/Perl/5.12/darwin-thread-multi-2level
VENDORLIBEXP = /Network/Library/Perl/5.12


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
DIRFILESEP = /
DFSEP = $(DIRFILESEP)
NAME = TFBS
NAME_SYM = TFBS
VERSION = 0.5.0
VERSION_MACRO = VERSION
VERSION_SYM = 0_5_0
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION = 0.5.0
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
INST_BIN = blib/bin
INST_LIB = blib/lib
INST_MAN1DIR = blib/man1
INST_MAN3DIR = blib/man3
MAN1EXT = 1
MAN3EXT = 3pm
INSTALLDIRS = site
DESTDIR = 
PREFIX = $(SITEPREFIX)
PERLPREFIX = /
SITEPREFIX = /usr/local
VENDORPREFIX = /usr/local
INSTALLPRIVLIB = /Library/Perl/Updates/5.12.4
DESTINSTALLPRIVLIB = $(DESTDIR)$(INSTALLPRIVLIB)
INSTALLSITELIB = /Library/Perl/5.12
DESTINSTALLSITELIB = $(DESTDIR)$(INSTALLSITELIB)
INSTALLVENDORLIB = /Network/Library/Perl/5.12
DESTINSTALLVENDORLIB = $(DESTDIR)$(INSTALLVENDORLIB)
INSTALLARCHLIB = /Library/Perl/Updates/5.12.4/darwin-thread-multi-2level
DESTINSTALLARCHLIB = $(DESTDIR)$(INSTALLARCHLIB)
INSTALLSITEARCH = /Library/Perl/5.12/darwin-thread-multi-2level
DESTINSTALLSITEARCH = $(DESTDIR)$(INSTALLSITEARCH)
INSTALLVENDORARCH = /Network/Library/Perl/5.12/darwin-thread-multi-2level
DESTINSTALLVENDORARCH = $(DESTDIR)$(INSTALLVENDORARCH)
INSTALLBIN = /usr/bin
DESTINSTALLBIN = $(DESTDIR)$(INSTALLBIN)
INSTALLSITEBIN = /usr/local/bin
DESTINSTALLSITEBIN = $(DESTDIR)$(INSTALLSITEBIN)
INSTALLVENDORBIN = /usr/local/bin
DESTINSTALLVENDORBIN = $(DESTDIR)$(INSTALLVENDORBIN)
INSTALLSCRIPT = /usr/bin
DESTINSTALLSCRIPT = $(DESTDIR)$(INSTALLSCRIPT)
INSTALLSITESCRIPT = /usr/local/bin
DESTINSTALLSITESCRIPT = $(DESTDIR)$(INSTALLSITESCRIPT)
INSTALLVENDORSCRIPT = /usr/local/bin
DESTINSTALLVENDORSCRIPT = $(DESTDIR)$(INSTALLVENDORSCRIPT)
INSTALLMAN1DIR = /usr/share/man/man1
DESTINSTALLMAN1DIR = $(DESTDIR)$(INSTALLMAN1DIR)
INSTALLSITEMAN1DIR = /usr/local/share/man/man1
DESTINSTALLSITEMAN1DIR = $(DESTDIR)$(INSTALLSITEMAN1DIR)
INSTALLVENDORMAN1DIR = /usr/local/share/man/man1
DESTINSTALLVENDORMAN1DIR = $(DESTDIR)$(INSTALLVENDORMAN1DIR)
INSTALLMAN3DIR = /usr/share/man/man3
DESTINSTALLMAN3DIR = $(DESTDIR)$(INSTALLMAN3DIR)
INSTALLSITEMAN3DIR = /usr/local/share/man/man3
DESTINSTALLSITEMAN3DIR = $(DESTDIR)$(INSTALLSITEMAN3DIR)
INSTALLVENDORMAN3DIR = /usr/local/share/man/man3
DESTINSTALLVENDORMAN3DIR = $(DESTDIR)$(INSTALLVENDORMAN3DIR)
PERL_LIB = /System/Library/Perl/5.12
PERL_ARCHLIB = /System/Library/Perl/5.12/darwin-thread-multi-2level
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKEFILE_OLD = Makefile.old
MAKE_APERL_FILE = Makefile.aperl
PERLMAINCC = $(CC)
PERL_INC = /System/Library/Perl/5.12/darwin-thread-multi-2level/CORE
PERL = /usr/bin/perl
FULLPERL = /usr/bin/perl
ABSPERL = $(PERL)
PERLRUN = $(PERL)
FULLPERLRUN = $(FULLPERL)
ABSPERLRUN = $(ABSPERL)
PERLRUNINST = $(PERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
FULLPERLRUNINST = $(FULLPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
ABSPERLRUNINST = $(ABSPERLRUN) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)"
PERL_CORE = 0
PERM_DIR = 755
PERM_RW = 644
PERM_RWX = 755

MAKEMAKER   = /Library/Perl/5.12/ExtUtils/MakeMaker.pm
MM_VERSION  = 6.74
MM_REVISION = 67400

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
MAKE = make
FULLEXT = TFBS
BASEEXT = TFBS
PARENT_NAME = 
DLBASE = $(BASEEXT)
VERSION_FROM = 
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic
BOOTDEP = 

# Handy lists of source code files:
XS_FILES = 
C_FILES  = 
O_FILES  = 
H_FILES  = 
MAN1PODS = 
MAN3PODS = TFBS/DB/FlatFileDir.pm \
	TFBS/DB/JASPAR2.pm \
	TFBS/DB/JASPAR4.pm \
	TFBS/DB/LocalTRANSFAC.pm \
	TFBS/DB/TRANSFAC.pm \
	TFBS/Matrix.pm \
	TFBS/Matrix/ICM.pm \
	TFBS/Matrix/PFM.pm \
	TFBS/Matrix/PWM.pm \
	TFBS/MatrixSet.pm \
	TFBS/PatternGen.pm \
	TFBS/PatternGen/AnnSpec.pm \
	TFBS/PatternGen/AnnSpec/Motif.pm \
	TFBS/PatternGen/Elph.pm \
	TFBS/PatternGen/Elph/Motif.pm \
	TFBS/PatternGen/Gibbs.pm \
	TFBS/PatternGen/Gibbs/Motif.pm \
	TFBS/PatternGen/MEME.pm \
	TFBS/PatternGen/MEME/Motif.pm \
	TFBS/PatternGen/SimplePFM.pm \
	TFBS/PatternGen/YMF.pm \
	TFBS/PatternGen/YMF/Motif.pm \
	TFBS/PatternI.pm \
	TFBS/Site.pm \
	TFBS/SitePair.pm \
	TFBS/SitePairSet.pm \
	TFBS/SiteSet.pm \
	TFBS/Word.pm \
	TFBS/Word/Consensus.pm

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIB)$(DFSEP)Config.pm $(PERL_INC)$(DFSEP)config.h

# Where to build things
INST_LIBDIR      = $(INST_LIB)
INST_ARCHLIBDIR  = $(INST_ARCHLIB)

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC      = 
INST_DYNAMIC     = 
INST_BOOT        = 

# Extra linker info
EXPORT_LIST        = 
PERL_ARCHIVE       = 
PERL_ARCHIVE_AFTER = 


TO_INST_PM = TFBS/DB.pm \
	TFBS/DB/FlatFileDir.pm \
	TFBS/DB/JASPAR2.pm \
	TFBS/DB/JASPAR4.pm \
	TFBS/DB/LocalTRANSFAC.pm \
	TFBS/DB/TRANSFAC.pm \
	TFBS/Matrix.pm \
	TFBS/Matrix/ICM.pm \
	TFBS/Matrix/PFM.pm \
	TFBS/Matrix/PWM.pm \
	TFBS/Matrix/_Alignment.pm \
	TFBS/MatrixSet.pm \
	TFBS/PatternGen.pm \
	TFBS/PatternGen/AnnSpec.pm \
	TFBS/PatternGen/AnnSpec/Motif.pm \
	TFBS/PatternGen/Elph.pm \
	TFBS/PatternGen/Elph/Motif.pm \
	TFBS/PatternGen/Gibbs.pm \
	TFBS/PatternGen/Gibbs/Motif.pm \
	TFBS/PatternGen/MEME.pm \
	TFBS/PatternGen/MEME/Motif.pm \
	TFBS/PatternGen/Motif/Matrix.pm \
	TFBS/PatternGen/Motif/Word.pm \
	TFBS/PatternGen/SimplePFM.pm \
	TFBS/PatternGen/YMF.pm \
	TFBS/PatternGen/YMF/Motif.pm \
	TFBS/PatternGenI.pm \
	TFBS/PatternI.pm \
	TFBS/Site.pm \
	TFBS/SitePair.pm \
	TFBS/SitePairSet.pm \
	TFBS/SiteSet.pm \
	TFBS/Tools/SetOperations.pm \
	TFBS/Word.pm \
	TFBS/Word/Consensus.pm \
	TFBS/_Iterator.pm \
	TFBS/_Iterator/_MatrixSetIterator.pm \
	TFBS/_Iterator/_SiteSetIterator.pm

PM_TO_BLIB = TFBS/PatternGen/YMF.pm \
	$(INST_LIB)/TFBS/PatternGen/YMF.pm \
	TFBS/DB/TRANSFAC.pm \
	$(INST_LIB)/TFBS/DB/TRANSFAC.pm \
	TFBS/DB.pm \
	$(INST_LIB)/TFBS/DB.pm \
	TFBS/DB/LocalTRANSFAC.pm \
	$(INST_LIB)/TFBS/DB/LocalTRANSFAC.pm \
	TFBS/PatternGen/MEME.pm \
	$(INST_LIB)/TFBS/PatternGen/MEME.pm \
	TFBS/PatternGen/Gibbs.pm \
	$(INST_LIB)/TFBS/PatternGen/Gibbs.pm \
	TFBS/PatternGen/Elph.pm \
	$(INST_LIB)/TFBS/PatternGen/Elph.pm \
	TFBS/DB/JASPAR4.pm \
	$(INST_LIB)/TFBS/DB/JASPAR4.pm \
	TFBS/PatternGenI.pm \
	$(INST_LIB)/TFBS/PatternGenI.pm \
	TFBS/Matrix/ICM.pm \
	$(INST_LIB)/TFBS/Matrix/ICM.pm \
	TFBS/PatternGen/YMF/Motif.pm \
	$(INST_LIB)/TFBS/PatternGen/YMF/Motif.pm \
	TFBS/SitePairSet.pm \
	$(INST_LIB)/TFBS/SitePairSet.pm \
	TFBS/PatternGen/Elph/Motif.pm \
	$(INST_LIB)/TFBS/PatternGen/Elph/Motif.pm \
	TFBS/Site.pm \
	$(INST_LIB)/TFBS/Site.pm \
	TFBS/_Iterator/_MatrixSetIterator.pm \
	$(INST_LIB)/TFBS/_Iterator/_MatrixSetIterator.pm \
	TFBS/Tools/SetOperations.pm \
	$(INST_LIB)/TFBS/Tools/SetOperations.pm \
	TFBS/Matrix/PFM.pm \
	$(INST_LIB)/TFBS/Matrix/PFM.pm \
	TFBS/PatternI.pm \
	$(INST_LIB)/TFBS/PatternI.pm \
	TFBS/Word/Consensus.pm \
	$(INST_LIB)/TFBS/Word/Consensus.pm \
	TFBS/PatternGen/Gibbs/Motif.pm \
	$(INST_LIB)/TFBS/PatternGen/Gibbs/Motif.pm \
	TFBS/SiteSet.pm \
	$(INST_LIB)/TFBS/SiteSet.pm \
	TFBS/Matrix/_Alignment.pm \
	$(INST_LIB)/TFBS/Matrix/_Alignment.pm \
	TFBS/PatternGen/AnnSpec.pm \
	$(INST_LIB)/TFBS/PatternGen/AnnSpec.pm \
	TFBS/PatternGen/Motif/Word.pm \
	$(INST_LIB)/TFBS/PatternGen/Motif/Word.pm \
	TFBS/SitePair.pm \
	$(INST_LIB)/TFBS/SitePair.pm \
	TFBS/_Iterator/_SiteSetIterator.pm \
	$(INST_LIB)/TFBS/_Iterator/_SiteSetIterator.pm \
	TFBS/_Iterator.pm \
	$(INST_LIB)/TFBS/_Iterator.pm \
	TFBS/PatternGen/MEME/Motif.pm \
	$(INST_LIB)/TFBS/PatternGen/MEME/Motif.pm \
	TFBS/DB/FlatFileDir.pm \
	$(INST_LIB)/TFBS/DB/FlatFileDir.pm \
	TFBS/PatternGen.pm \
	$(INST_LIB)/TFBS/PatternGen.pm \
	TFBS/MatrixSet.pm \
	$(INST_LIB)/TFBS/MatrixSet.pm \
	TFBS/PatternGen/SimplePFM.pm \
	$(INST_LIB)/TFBS/PatternGen/SimplePFM.pm \
	TFBS/Word.pm \
	$(INST_LIB)/TFBS/Word.pm \
	TFBS/DB/JASPAR2.pm \
	$(INST_LIB)/TFBS/DB/JASPAR2.pm \
	TFBS/Matrix.pm \
	$(INST_LIB)/TFBS/Matrix.pm \
	TFBS/PatternGen/AnnSpec/Motif.pm \
	$(INST_LIB)/TFBS/PatternGen/AnnSpec/Motif.pm \
	TFBS/PatternGen/Motif/Matrix.pm \
	$(INST_LIB)/TFBS/PatternGen/Motif/Matrix.pm \
	TFBS/Matrix/PWM.pm \
	$(INST_LIB)/TFBS/Matrix/PWM.pm


# --- MakeMaker platform_constants section:
MM_Unix_VERSION = 6.74
PERL_MALLOC_DEF = -DPERL_EXTMALLOC_DEF -Dmalloc=Perl_malloc -Dfree=Perl_mfree -Drealloc=Perl_realloc -Dcalloc=Perl_calloc


# --- MakeMaker tool_autosplit section:
# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(ABSPERLRUN)  -e 'use AutoSplit;  autosplit($$$$ARGV[0], $$$$ARGV[1], 0, 1, 1)' --



# --- MakeMaker tool_xsubpp section:

XSUBPPDIR = /System/Library/Perl/5.12/ExtUtils
XSUBPP = $(XSUBPPDIR)$(DFSEP)xsubpp
XSUBPPRUN = $(PERLRUN) $(XSUBPP)
XSPROTOARG = 
XSUBPPDEPS = /System/Library/Perl/5.12/ExtUtils/typemap $(XSUBPP)
XSUBPPARGS = -typemap /System/Library/Perl/5.12/ExtUtils/typemap
XSUBPP_EXTRA_ARGS =


# --- MakeMaker tools_other section:
SHELL = /bin/sh
CHMOD = chmod
CP = cp
MV = mv
NOOP = $(TRUE)
NOECHO = @
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1
MKPATH = $(ABSPERLRUN) -MExtUtils::Command -e 'mkpath' --
EQUALIZE_TIMESTAMP = $(ABSPERLRUN) -MExtUtils::Command -e 'eqtime' --
FALSE = false
TRUE = true
ECHO = echo
ECHO_N = echo -n
UNINST = 0
VERBINST = 0
MOD_INSTALL = $(ABSPERLRUN) -MExtUtils::Install -e 'install([ from_to => {@ARGV}, verbose => '\''$(VERBINST)'\'', uninstall_shadows => '\''$(UNINST)'\'', dir_mode => '\''$(PERM_DIR)'\'' ]);' --
DOC_INSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'perllocal_install' --
UNINSTALL = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'uninstall' --
WARN_IF_OLD_PACKLIST = $(ABSPERLRUN) -MExtUtils::Command::MM -e 'warn_if_old_packlist' --
MACROSTART = 
MACROEND = 
USEMAKEFILE = -f
FIXIN = $(ABSPERLRUN) -MExtUtils::MY -e 'MY->fixin(shift)' --


# --- MakeMaker makemakerdflt section:
makemakerdflt : all
	$(NOECHO) $(NOOP)


# --- MakeMaker dist section:
TAR = COPY_EXTENDED_ATTRIBUTES_DISABLE=1 COPYFILE_DISABLE=1 tar
TARFLAGS = cvf
ZIP = zip
ZIPFLAGS = -r
COMPRESS = gzip -9f
SUFFIX = .gz
SHAR = shar
PREOP = $(NOECHO) $(NOOP)
POSTOP = $(NOECHO) $(NOOP)
TO_UNIX = $(NOECHO) $(NOOP)
CI = ci -u
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = all tardist
DISTNAME = TFBS
DISTVNAME = TFBS-0.5.0


# --- MakeMaker macro section:


# --- MakeMaker depend section:


# --- MakeMaker cflags section:

CCFLAGS = -arch i386 -arch x86_64 -g -pipe -fno-common -DPERL_DARWIN -fno-strict-aliasing -fstack-protector -I/usr/local/include
OPTIMIZE = -Os
PERLTYPE = 
MPOLLUTE = 


# --- MakeMaker const_loadlibs section:

# TFBS might depend on some other libraries:
# See ExtUtils::Liblist for details
#


# --- MakeMaker const_cccmd section:
CCCMD = $(CC) -c $(PASTHRU_INC) $(INC) \
	$(CCFLAGS) $(OPTIMIZE) \
	$(PERLTYPE) $(MPOLLUTE) $(DEFINE_VERSION) \
	$(XS_DEFINE_VERSION)

# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	OPTIMIZE="$(OPTIMIZE)"\
	PREFIX="$(PREFIX)"


# --- MakeMaker special_targets section:
.SUFFIXES : .xs .c .C .cpp .i .s .cxx .cc $(OBJ_EXT)

.PHONY: all config static dynamic test linkext manifest blibdirs clean realclean disttest distdir



# --- MakeMaker c_o section:

.c.i:
	clang -E -c $(PASTHRU_INC) $(INC) \
	$(CCFLAGS) $(OPTIMIZE) \
	$(PERLTYPE) $(MPOLLUTE) $(DEFINE_VERSION) \
	$(XS_DEFINE_VERSION) $(CCCDLFLAGS) "-I$(PERL_INC)" $(PASTHRU_DEFINE) $(DEFINE) $*.c > $*.i

.c.s:
	$(CCCMD) -S $(CCCDLFLAGS) "-I$(PERL_INC)" $(PASTHRU_DEFINE) $(DEFINE) $*.c

.c$(OBJ_EXT):
	$(CCCMD) $(CCCDLFLAGS) "-I$(PERL_INC)" $(PASTHRU_DEFINE) $(DEFINE) $*.c

.cpp$(OBJ_EXT):
	$(CCCMD) $(CCCDLFLAGS) "-I$(PERL_INC)" $(PASTHRU_DEFINE) $(DEFINE) $*.cpp

.cxx$(OBJ_EXT):
	$(CCCMD) $(CCCDLFLAGS) "-I$(PERL_INC)" $(PASTHRU_DEFINE) $(DEFINE) $*.cxx

.cc$(OBJ_EXT):
	$(CCCMD) $(CCCDLFLAGS) "-I$(PERL_INC)" $(PASTHRU_DEFINE) $(DEFINE) $*.cc

.C$(OBJ_EXT):
	$(CCCMD) $(CCCDLFLAGS) "-I$(PERL_INC)" $(PASTHRU_DEFINE) $(DEFINE) $*.C


# --- MakeMaker xs_c section:

.xs.c:
	$(XSUBPPRUN) $(XSPROTOARG) $(XSUBPPARGS) $(XSUBPP_EXTRA_ARGS) $*.xs > $*.xsc && $(MV) $*.xsc $*.c


# --- MakeMaker xs_o section:

.xs$(OBJ_EXT):
	$(XSUBPPRUN) $(XSPROTOARG) $(XSUBPPARGS) $*.xs > $*.xsc && $(MV) $*.xsc $*.c
	$(CCCMD) $(CCCDLFLAGS) "-I$(PERL_INC)" $(PASTHRU_DEFINE) $(DEFINE) $*.c


# --- MakeMaker top_targets section:
all :: pure_all manifypods
	$(NOECHO) $(NOOP)


pure_all :: config pm_to_blib subdirs linkext
	$(NOECHO) $(NOOP)

subdirs :: $(MYEXTLIB)
	$(NOECHO) $(NOOP)

config :: $(FIRST_MAKEFILE) blibdirs
	$(NOECHO) $(NOOP)

help :
	perldoc ExtUtils::MakeMaker


# --- MakeMaker blibdirs section:
blibdirs : $(INST_LIBDIR)$(DFSEP).exists $(INST_ARCHLIB)$(DFSEP).exists $(INST_AUTODIR)$(DFSEP).exists $(INST_ARCHAUTODIR)$(DFSEP).exists $(INST_BIN)$(DFSEP).exists $(INST_SCRIPT)$(DFSEP).exists $(INST_MAN1DIR)$(DFSEP).exists $(INST_MAN3DIR)$(DFSEP).exists
	$(NOECHO) $(NOOP)

# Backwards compat with 6.18 through 6.25
blibdirs.ts : blibdirs
	$(NOECHO) $(NOOP)

$(INST_LIBDIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_LIBDIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_LIBDIR)
	$(NOECHO) $(TOUCH) $(INST_LIBDIR)$(DFSEP).exists

$(INST_ARCHLIB)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHLIB)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHLIB)
	$(NOECHO) $(TOUCH) $(INST_ARCHLIB)$(DFSEP).exists

$(INST_AUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_AUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_AUTODIR)
	$(NOECHO) $(TOUCH) $(INST_AUTODIR)$(DFSEP).exists

$(INST_ARCHAUTODIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_ARCHAUTODIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_ARCHAUTODIR)
	$(NOECHO) $(TOUCH) $(INST_ARCHAUTODIR)$(DFSEP).exists

$(INST_BIN)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_BIN)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_BIN)
	$(NOECHO) $(TOUCH) $(INST_BIN)$(DFSEP).exists

$(INST_SCRIPT)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_SCRIPT)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_SCRIPT)
	$(NOECHO) $(TOUCH) $(INST_SCRIPT)$(DFSEP).exists

$(INST_MAN1DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN1DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN1DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN1DIR)$(DFSEP).exists

$(INST_MAN3DIR)$(DFSEP).exists :: Makefile.PL
	$(NOECHO) $(MKPATH) $(INST_MAN3DIR)
	$(NOECHO) $(CHMOD) $(PERM_DIR) $(INST_MAN3DIR)
	$(NOECHO) $(TOUCH) $(INST_MAN3DIR)$(DFSEP).exists



# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	$(NOECHO) $(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic section:

dynamic :: $(FIRST_MAKEFILE) $(INST_DYNAMIC) $(INST_BOOT)
	$(NOECHO) $(NOOP)


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
static :: $(FIRST_MAKEFILE) $(INST_STATIC)
	$(NOECHO) $(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:

POD2MAN_EXE = $(PERLRUN) "-MExtUtils::Command::MM" -e pod2man "--"
POD2MAN = $(POD2MAN_EXE)


manifypods : pure_all  \
	TFBS/Matrix/PFM.pm \
	TFBS/PatternI.pm \
	TFBS/PatternGen/YMF.pm \
	TFBS/DB/TRANSFAC.pm \
	TFBS/PatternGen/Gibbs/Motif.pm \
	TFBS/Word/Consensus.pm \
	TFBS/SiteSet.pm \
	TFBS/DB/LocalTRANSFAC.pm \
	TFBS/PatternGen/AnnSpec.pm \
	TFBS/PatternGen/Gibbs.pm \
	TFBS/PatternGen/MEME.pm \
	TFBS/SitePair.pm \
	TFBS/PatternGen/Elph.pm \
	TFBS/DB/FlatFileDir.pm \
	TFBS/PatternGen/MEME/Motif.pm \
	TFBS/DB/JASPAR4.pm \
	TFBS/PatternGen.pm \
	TFBS/MatrixSet.pm \
	TFBS/PatternGen/SimplePFM.pm \
	TFBS/Matrix/ICM.pm \
	TFBS/Word.pm \
	TFBS/SitePairSet.pm \
	TFBS/PatternGen/YMF/Motif.pm \
	TFBS/DB/JASPAR2.pm \
	TFBS/Matrix.pm \
	TFBS/PatternGen/Elph/Motif.pm \
	TFBS/PatternGen/AnnSpec/Motif.pm \
	TFBS/Site.pm \
	TFBS/Matrix/PWM.pm
	$(NOECHO) $(POD2MAN) --section=3 --perm_rw=$(PERM_RW) \
	  TFBS/Matrix/PFM.pm $(INST_MAN3DIR)/TFBS::Matrix::PFM.$(MAN3EXT) \
	  TFBS/PatternI.pm $(INST_MAN3DIR)/TFBS::PatternI.$(MAN3EXT) \
	  TFBS/PatternGen/YMF.pm $(INST_MAN3DIR)/TFBS::PatternGen::YMF.$(MAN3EXT) \
	  TFBS/DB/TRANSFAC.pm $(INST_MAN3DIR)/TFBS::DB::TRANSFAC.$(MAN3EXT) \
	  TFBS/PatternGen/Gibbs/Motif.pm $(INST_MAN3DIR)/TFBS::PatternGen::Gibbs::Motif.$(MAN3EXT) \
	  TFBS/Word/Consensus.pm $(INST_MAN3DIR)/TFBS::Word::Consensus.$(MAN3EXT) \
	  TFBS/SiteSet.pm $(INST_MAN3DIR)/TFBS::SiteSet.$(MAN3EXT) \
	  TFBS/DB/LocalTRANSFAC.pm $(INST_MAN3DIR)/TFBS::DB::LocalTRANSFAC.$(MAN3EXT) \
	  TFBS/PatternGen/AnnSpec.pm $(INST_MAN3DIR)/TFBS::PatternGen::AnnSpec.$(MAN3EXT) \
	  TFBS/PatternGen/Gibbs.pm $(INST_MAN3DIR)/TFBS::PatternGen::Gibbs.$(MAN3EXT) \
	  TFBS/PatternGen/MEME.pm $(INST_MAN3DIR)/TFBS::PatternGen::MEME.$(MAN3EXT) \
	  TFBS/SitePair.pm $(INST_MAN3DIR)/TFBS::SitePair.$(MAN3EXT) \
	  TFBS/PatternGen/Elph.pm $(INST_MAN3DIR)/TFBS::PatternGen::Elph.$(MAN3EXT) \
	  TFBS/DB/FlatFileDir.pm $(INST_MAN3DIR)/TFBS::DB::FlatFileDir.$(MAN3EXT) \
	  TFBS/PatternGen/MEME/Motif.pm $(INST_MAN3DIR)/TFBS::PatternGen::MEME::Motif.$(MAN3EXT) \
	  TFBS/DB/JASPAR4.pm $(INST_MAN3DIR)/TFBS::DB::JASPAR4.$(MAN3EXT) \
	  TFBS/PatternGen.pm $(INST_MAN3DIR)/TFBS::PatternGen.$(MAN3EXT) \
	  TFBS/MatrixSet.pm $(INST_MAN3DIR)/TFBS::MatrixSet.$(MAN3EXT) \
	  TFBS/PatternGen/SimplePFM.pm $(INST_MAN3DIR)/TFBS::PatternGen::SimplePFM.$(MAN3EXT) \
	  TFBS/Matrix/ICM.pm $(INST_MAN3DIR)/TFBS::Matrix::ICM.$(MAN3EXT) \
	  TFBS/Word.pm $(INST_MAN3DIR)/TFBS::Word.$(MAN3EXT) \
	  TFBS/SitePairSet.pm $(INST_MAN3DIR)/TFBS::SitePairSet.$(MAN3EXT) \
	  TFBS/PatternGen/YMF/Motif.pm $(INST_MAN3DIR)/TFBS::PatternGen::YMF::Motif.$(MAN3EXT) \
	  TFBS/DB/JASPAR2.pm $(INST_MAN3DIR)/TFBS::DB::JASPAR2.$(MAN3EXT) \
	  TFBS/Matrix.pm $(INST_MAN3DIR)/TFBS::Matrix.$(MAN3EXT) \
	  TFBS/PatternGen/Elph/Motif.pm $(INST_MAN3DIR)/TFBS::PatternGen::Elph::Motif.$(MAN3EXT) \
	  TFBS/PatternGen/AnnSpec/Motif.pm $(INST_MAN3DIR)/TFBS::PatternGen::AnnSpec::Motif.$(MAN3EXT) \
	  TFBS/Site.pm $(INST_MAN3DIR)/TFBS::Site.$(MAN3EXT) \
	  TFBS/Matrix/PWM.pm $(INST_MAN3DIR)/TFBS::Matrix::PWM.$(MAN3EXT) 




# --- MakeMaker processPL section:


# --- MakeMaker installbin section:


# --- MakeMaker subdirs section:

# The default clean, realclean and test targets in this Makefile
# have automatically been given entries for each subdir.


subdirs ::
	$(NOECHO) cd Ext && $(MAKE) $(USEMAKEFILE) $(FIRST_MAKEFILE) all $(PASTHRU)


# --- MakeMaker clean_subdirs section:
clean_subdirs :
	$(ABSPERLRUN)  -e 'exit 0 unless chdir '\''Ext'\'';  system '\''$(MAKE) clean'\'' if -f '\''$(FIRST_MAKEFILE)'\'';' --


# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean :: clean_subdirs
	- $(RM_F) \
	  *$(LIB_EXT) core \
	  core.[0-9] $(INST_ARCHAUTODIR)/extralibs.all \
	  core.[0-9][0-9] $(BASEEXT).bso \
	  pm_to_blib.ts MYMETA.json \
	  core.[0-9][0-9][0-9][0-9] MYMETA.yml \
	  $(BASEEXT).x $(BOOTSTRAP) \
	  perl$(EXE_EXT) tmon.out \
	  *$(OBJ_EXT) pm_to_blib \
	  $(INST_ARCHAUTODIR)/extralibs.ld blibdirs.ts \
	  core.[0-9][0-9][0-9][0-9][0-9] *perl.core \
	  core.*perl.*.? $(MAKE_APERL_FILE) \
	  $(BASEEXT).def perl \
	  core.[0-9][0-9][0-9] mon.out \
	  lib$(BASEEXT).def perl.exe \
	  perlmain.c so_locations \
	  $(BASEEXT).exp 
	- $(RM_RF) \
	  blib 
	  $(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	- $(MV) $(FIRST_MAKEFILE) $(MAKEFILE_OLD) $(DEV_NULL)


# --- MakeMaker realclean_subdirs section:
realclean_subdirs :
	- $(ABSPERLRUN)  -e 'chdir '\''Ext'\'';  system '\''$(MAKE) $(USEMAKEFILE) $(MAKEFILE_OLD) realclean'\'' if -f '\''$(MAKEFILE_OLD)'\'';' --
	- $(ABSPERLRUN)  -e 'chdir '\''Ext'\'';  system '\''$(MAKE) $(USEMAKEFILE) $(FIRST_MAKEFILE) realclean'\'' if -f '\''$(FIRST_MAKEFILE)'\'';' --


# --- MakeMaker realclean section:
# Delete temporary files (via clean) and also delete dist files
realclean purge ::  clean realclean_subdirs
	- $(RM_F) \
	  $(MAKEFILE_OLD) $(FIRST_MAKEFILE) 
	- $(RM_RF) \
	  $(DISTVNAME) 


# --- MakeMaker metafile section:
metafile : create_distdir
	$(NOECHO) $(ECHO) Generating META.yml
	$(NOECHO) $(ECHO) '---' > META_new.yml
	$(NOECHO) $(ECHO) 'abstract: unknown' >> META_new.yml
	$(NOECHO) $(ECHO) 'author:' >> META_new.yml
	$(NOECHO) $(ECHO) '  - unknown' >> META_new.yml
	$(NOECHO) $(ECHO) 'build_requires:' >> META_new.yml
	$(NOECHO) $(ECHO) '  ExtUtils::MakeMaker: 0' >> META_new.yml
	$(NOECHO) $(ECHO) 'configure_requires:' >> META_new.yml
	$(NOECHO) $(ECHO) '  ExtUtils::MakeMaker: 0' >> META_new.yml
	$(NOECHO) $(ECHO) 'dynamic_config: 1' >> META_new.yml
	$(NOECHO) $(ECHO) 'generated_by: '\''ExtUtils::MakeMaker version 6.74, CPAN::Meta::Converter version 2.132140'\''' >> META_new.yml
	$(NOECHO) $(ECHO) 'license: unknown' >> META_new.yml
	$(NOECHO) $(ECHO) 'meta-spec:' >> META_new.yml
	$(NOECHO) $(ECHO) '  url: http://module-build.sourceforge.net/META-spec-v1.4.html' >> META_new.yml
	$(NOECHO) $(ECHO) '  version: 1.4' >> META_new.yml
	$(NOECHO) $(ECHO) 'name: TFBS' >> META_new.yml
	$(NOECHO) $(ECHO) 'no_index:' >> META_new.yml
	$(NOECHO) $(ECHO) '  directory:' >> META_new.yml
	$(NOECHO) $(ECHO) '    - t' >> META_new.yml
	$(NOECHO) $(ECHO) '    - inc' >> META_new.yml
	$(NOECHO) $(ECHO) 'requires: {}' >> META_new.yml
	$(NOECHO) $(ECHO) 'version: v0.5.0' >> META_new.yml
	-$(NOECHO) $(MV) META_new.yml $(DISTVNAME)/META.yml
	$(NOECHO) $(ECHO) Generating META.json
	$(NOECHO) $(ECHO) '{' > META_new.json
	$(NOECHO) $(ECHO) '   "abstract" : "unknown",' >> META_new.json
	$(NOECHO) $(ECHO) '   "author" : [' >> META_new.json
	$(NOECHO) $(ECHO) '      "unknown"' >> META_new.json
	$(NOECHO) $(ECHO) '   ],' >> META_new.json
	$(NOECHO) $(ECHO) '   "dynamic_config" : 1,' >> META_new.json
	$(NOECHO) $(ECHO) '   "generated_by" : "ExtUtils::MakeMaker version 6.74, CPAN::Meta::Converter version 2.132140",' >> META_new.json
	$(NOECHO) $(ECHO) '   "license" : [' >> META_new.json
	$(NOECHO) $(ECHO) '      "unknown"' >> META_new.json
	$(NOECHO) $(ECHO) '   ],' >> META_new.json
	$(NOECHO) $(ECHO) '   "meta-spec" : {' >> META_new.json
	$(NOECHO) $(ECHO) '      "url" : "http://search.cpan.org/perldoc?CPAN::Meta::Spec",' >> META_new.json
	$(NOECHO) $(ECHO) '      "version" : "2"' >> META_new.json
	$(NOECHO) $(ECHO) '   },' >> META_new.json
	$(NOECHO) $(ECHO) '   "name" : "TFBS",' >> META_new.json
	$(NOECHO) $(ECHO) '   "no_index" : {' >> META_new.json
	$(NOECHO) $(ECHO) '      "directory" : [' >> META_new.json
	$(NOECHO) $(ECHO) '         "t",' >> META_new.json
	$(NOECHO) $(ECHO) '         "inc"' >> META_new.json
	$(NOECHO) $(ECHO) '      ]' >> META_new.json
	$(NOECHO) $(ECHO) '   },' >> META_new.json
	$(NOECHO) $(ECHO) '   "prereqs" : {' >> META_new.json
	$(NOECHO) $(ECHO) '      "build" : {' >> META_new.json
	$(NOECHO) $(ECHO) '         "requires" : {' >> META_new.json
	$(NOECHO) $(ECHO) '            "ExtUtils::MakeMaker" : "0"' >> META_new.json
	$(NOECHO) $(ECHO) '         }' >> META_new.json
	$(NOECHO) $(ECHO) '      },' >> META_new.json
	$(NOECHO) $(ECHO) '      "configure" : {' >> META_new.json
	$(NOECHO) $(ECHO) '         "requires" : {' >> META_new.json
	$(NOECHO) $(ECHO) '            "ExtUtils::MakeMaker" : "0"' >> META_new.json
	$(NOECHO) $(ECHO) '         }' >> META_new.json
	$(NOECHO) $(ECHO) '      },' >> META_new.json
	$(NOECHO) $(ECHO) '      "runtime" : {' >> META_new.json
	$(NOECHO) $(ECHO) '         "requires" : {}' >> META_new.json
	$(NOECHO) $(ECHO) '      }' >> META_new.json
	$(NOECHO) $(ECHO) '   },' >> META_new.json
	$(NOECHO) $(ECHO) '   "release_status" : "stable",' >> META_new.json
	$(NOECHO) $(ECHO) '   "version" : "v0.5.0"' >> META_new.json
	$(NOECHO) $(ECHO) '}' >> META_new.json
	-$(NOECHO) $(MV) META_new.json $(DISTVNAME)/META.json


# --- MakeMaker signature section:
signature :
	cpansign -s


# --- MakeMaker dist_basics section:
distclean :: realclean distcheck
	$(NOECHO) $(NOOP)

distcheck :
	$(PERLRUN) "-MExtUtils::Manifest=fullcheck" -e fullcheck

skipcheck :
	$(PERLRUN) "-MExtUtils::Manifest=skipcheck" -e skipcheck

manifest :
	$(PERLRUN) "-MExtUtils::Manifest=mkmanifest" -e mkmanifest

veryclean : realclean
	$(RM_F) *~ */*~ *.orig */*.orig *.bak */*.bak *.old */*.old



# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT) $(FIRST_MAKEFILE)
	$(NOECHO) $(ABSPERLRUN) -l -e 'print '\''Warning: Makefile possibly out of date with $(VERSION_FROM)'\''' \
	  -e '    if -e '\''$(VERSION_FROM)'\'' and -M '\''$(VERSION_FROM)'\'' < -M '\''$(FIRST_MAKEFILE)'\'';' --

tardist : $(DISTVNAME).tar$(SUFFIX)
	$(NOECHO) $(NOOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) $(DISTVNAME).tar$(SUFFIX) > $(DISTVNAME).tar$(SUFFIX)_uu
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).tar$(SUFFIX)_uu'

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).tar$(SUFFIX)'
	$(POSTOP)

zipdist : $(DISTVNAME).zip
	$(NOECHO) $(NOOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).zip'
	$(POSTOP)

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(NOECHO) $(ECHO) 'Created $(DISTVNAME).shar'
	$(POSTOP)


# --- MakeMaker distdir section:
create_distdir :
	$(RM_RF) $(DISTVNAME)
	$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"

distdir : create_distdir distmeta 
	$(NOECHO) $(NOOP)



# --- MakeMaker dist_test section:
disttest : distdir
	cd $(DISTVNAME) && $(ABSPERLRUN) Makefile.PL 
	cd $(DISTVNAME) && $(MAKE) $(PASTHRU)
	cd $(DISTVNAME) && $(MAKE) test $(PASTHRU)



# --- MakeMaker dist_ci section:

ci :
	$(PERLRUN) "-MExtUtils::Manifest=maniread" \
	  -e "@all = keys %{ maniread() };" \
	  -e "print(qq{Executing $(CI) @all\n}); system(qq{$(CI) @all});" \
	  -e "print(qq{Executing $(RCS_LABEL) ...\n}); system(qq{$(RCS_LABEL) @all});"


# --- MakeMaker distmeta section:
distmeta : create_distdir metafile
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -e q{META.yml};' \
	  -e 'eval { maniadd({q{META.yml} => q{Module YAML meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.yml to MANIFEST: $$$${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'exit unless -f q{META.json};' \
	  -e 'eval { maniadd({q{META.json} => q{Module JSON meta-data (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add META.json to MANIFEST: $$$${'\''@'\''}\n"' --



# --- MakeMaker distsignature section:
distsignature : create_distdir
	$(NOECHO) cd $(DISTVNAME) && $(ABSPERLRUN) -MExtUtils::Manifest=maniadd -e 'eval { maniadd({q{SIGNATURE} => q{Public-key signature (added by MakeMaker)}}) }' \
	  -e '    or print "Could not add SIGNATURE to MANIFEST: $$$${'\''@'\''}\n"' --
	$(NOECHO) cd $(DISTVNAME) && $(TOUCH) SIGNATURE
	cd $(DISTVNAME) && cpansign -s



# --- MakeMaker install section:

install :: pure_install doc_install
	$(NOECHO) $(NOOP)

install_perl :: pure_perl_install doc_perl_install
	$(NOECHO) $(NOOP)

install_site :: pure_site_install doc_site_install
	$(NOECHO) $(NOOP)

install_vendor :: pure_vendor_install doc_vendor_install
	$(NOECHO) $(NOOP)

pure_install :: pure_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

doc_install :: doc_$(INSTALLDIRS)_install
	$(NOECHO) $(NOOP)

pure__install : pure_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	$(NOECHO) $(ECHO) INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLARCHLIB)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLPRIVLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLARCHLIB) \
		$(INST_BIN) $(DESTINSTALLBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(SITEARCHEXP)/auto/$(FULLEXT)


pure_site_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLSITELIB) \
		$(INST_ARCHLIB) $(DESTINSTALLSITEARCH) \
		$(INST_BIN) $(DESTINSTALLSITEBIN) \
		$(INST_SCRIPT) $(DESTINSTALLSITESCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLSITEMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLSITEMAN3DIR)
	$(NOECHO) $(WARN_IF_OLD_PACKLIST) \
		$(PERL_ARCHLIB)/auto/$(FULLEXT)

pure_vendor_install :: all
	$(NOECHO) $(MOD_INSTALL) \
		read $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(DESTINSTALLVENDORARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(DESTINSTALLVENDORLIB) \
		$(INST_ARCHLIB) $(DESTINSTALLVENDORARCH) \
		$(INST_BIN) $(DESTINSTALLVENDORBIN) \
		$(INST_SCRIPT) $(DESTINSTALLVENDORSCRIPT) \
		$(INST_MAN1DIR) $(DESTINSTALLVENDORMAN1DIR) \
		$(INST_MAN3DIR) $(DESTINSTALLVENDORMAN3DIR)

doc_perl_install :: all
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLPRIVLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_site_install :: all
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod

doc_vendor_install :: all
	$(NOECHO) $(ECHO) Appending installation info to $(DESTINSTALLARCHLIB)/perllocal.pod
	-$(NOECHO) $(MKPATH) $(DESTINSTALLARCHLIB)
	-$(NOECHO) $(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLVENDORLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(DESTINSTALLARCHLIB)/perllocal.pod


uninstall :: uninstall_from_$(INSTALLDIRS)dirs
	$(NOECHO) $(NOOP)

uninstall_from_perldirs ::
	$(NOECHO) $(UNINSTALL) $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist

uninstall_from_sitedirs ::
	$(NOECHO) $(UNINSTALL) $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist

uninstall_from_vendordirs ::
	$(NOECHO) $(UNINSTALL) $(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE :
	$(NOECHO) $(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:
# We take a very conservative approach here, but it's worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
$(FIRST_MAKEFILE) : Makefile.PL $(CONFIGDEP)
	$(NOECHO) $(ECHO) "Makefile out-of-date with respect to $?"
	$(NOECHO) $(ECHO) "Cleaning current config before rebuilding Makefile..."
	-$(NOECHO) $(RM_F) $(MAKEFILE_OLD)
	-$(NOECHO) $(MV)   $(FIRST_MAKEFILE) $(MAKEFILE_OLD)
	- $(MAKE) $(USEMAKEFILE) $(MAKEFILE_OLD) clean $(DEV_NULL)
	$(PERLRUN) Makefile.PL 
	$(NOECHO) $(ECHO) "==> Your Makefile has been rebuilt. <=="
	$(NOECHO) $(ECHO) "==> Please rerun the $(MAKE) command.  <=="
	$(FALSE)



# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = /usr/bin/perl

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) $(USEMAKEFILE) $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE) pm_to_blib
	$(NOECHO) $(ECHO) Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	$(NOECHO) $(PERLRUNINST) \
		Makefile.PL DIR=Ext \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:

TEST_VERBOSE=0
TEST_TYPE=test_$(LINKTYPE)
TEST_FILE = test.pl
TEST_FILES = t/*.t
TESTDB_SW = -d

testdb :: testdb_$(LINKTYPE)

test :: $(TEST_TYPE) subdirs-test

subdirs-test ::
	$(NOECHO) $(NOOP)

subdirs-test ::
	$(NOECHO) cd Ext && $(MAKE) test $(PASTHRU)


test_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) "-MExtUtils::Command::MM" "-e" "test_harness($(TEST_VERBOSE), '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_dynamic :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERLRUN) $(TESTDB_SW) "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)

test_ : test_dynamic

test_static :: pure_all $(MAP_TARGET)
	PERL_DL_NONLAZY=1 ./$(MAP_TARGET) "-MExtUtils::Command::MM" "-e" "test_harness($(TEST_VERBOSE), '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)

testdb_static :: pure_all $(MAP_TARGET)
	PERL_DL_NONLAZY=1 ./$(MAP_TARGET) $(TESTDB_SW) "-I$(INST_LIB)" "-I$(INST_ARCHLIB)" $(TEST_FILE)



# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd :
	$(NOECHO) $(ECHO) '<SOFTPKG NAME="$(DISTNAME)" VERSION="$(VERSION)">' > $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <ABSTRACT></ABSTRACT>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <AUTHOR></AUTHOR>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    <IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <ARCHITECTURE NAME="darwin-thread-multi-2level-5.12" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '        <CODEBASE HREF="" />' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '    </IMPLEMENTATION>' >> $(DISTNAME).ppd
	$(NOECHO) $(ECHO) '</SOFTPKG>' >> $(DISTNAME).ppd


# --- MakeMaker pm_to_blib section:

pm_to_blib : $(FIRST_MAKEFILE) $(TO_INST_PM)
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)/auto'\'', q[$(PM_FILTER)], '\''$(PERM_DIR)'\'')' -- \
	  TFBS/PatternGen/YMF.pm $(INST_LIB)/TFBS/PatternGen/YMF.pm \
	  TFBS/DB/TRANSFAC.pm $(INST_LIB)/TFBS/DB/TRANSFAC.pm \
	  TFBS/DB.pm $(INST_LIB)/TFBS/DB.pm \
	  TFBS/DB/LocalTRANSFAC.pm $(INST_LIB)/TFBS/DB/LocalTRANSFAC.pm \
	  TFBS/PatternGen/MEME.pm $(INST_LIB)/TFBS/PatternGen/MEME.pm \
	  TFBS/PatternGen/Gibbs.pm $(INST_LIB)/TFBS/PatternGen/Gibbs.pm \
	  TFBS/PatternGen/Elph.pm $(INST_LIB)/TFBS/PatternGen/Elph.pm \
	  TFBS/DB/JASPAR4.pm $(INST_LIB)/TFBS/DB/JASPAR4.pm \
	  TFBS/PatternGenI.pm $(INST_LIB)/TFBS/PatternGenI.pm \
	  TFBS/Matrix/ICM.pm $(INST_LIB)/TFBS/Matrix/ICM.pm \
	  TFBS/PatternGen/YMF/Motif.pm $(INST_LIB)/TFBS/PatternGen/YMF/Motif.pm \
	  TFBS/SitePairSet.pm $(INST_LIB)/TFBS/SitePairSet.pm \
	  TFBS/PatternGen/Elph/Motif.pm $(INST_LIB)/TFBS/PatternGen/Elph/Motif.pm \
	  TFBS/Site.pm $(INST_LIB)/TFBS/Site.pm \
	  TFBS/_Iterator/_MatrixSetIterator.pm $(INST_LIB)/TFBS/_Iterator/_MatrixSetIterator.pm \
	  TFBS/Tools/SetOperations.pm $(INST_LIB)/TFBS/Tools/SetOperations.pm \
	  TFBS/Matrix/PFM.pm $(INST_LIB)/TFBS/Matrix/PFM.pm \
	  TFBS/PatternI.pm $(INST_LIB)/TFBS/PatternI.pm \
	  TFBS/Word/Consensus.pm $(INST_LIB)/TFBS/Word/Consensus.pm \
	  TFBS/PatternGen/Gibbs/Motif.pm $(INST_LIB)/TFBS/PatternGen/Gibbs/Motif.pm \
	  TFBS/SiteSet.pm $(INST_LIB)/TFBS/SiteSet.pm \
	  TFBS/Matrix/_Alignment.pm $(INST_LIB)/TFBS/Matrix/_Alignment.pm \
	  TFBS/PatternGen/AnnSpec.pm $(INST_LIB)/TFBS/PatternGen/AnnSpec.pm \
	  TFBS/PatternGen/Motif/Word.pm $(INST_LIB)/TFBS/PatternGen/Motif/Word.pm \
	  TFBS/SitePair.pm $(INST_LIB)/TFBS/SitePair.pm \
	  TFBS/_Iterator/_SiteSetIterator.pm $(INST_LIB)/TFBS/_Iterator/_SiteSetIterator.pm \
	  TFBS/_Iterator.pm $(INST_LIB)/TFBS/_Iterator.pm \
	  TFBS/PatternGen/MEME/Motif.pm $(INST_LIB)/TFBS/PatternGen/MEME/Motif.pm \
	  TFBS/DB/FlatFileDir.pm $(INST_LIB)/TFBS/DB/FlatFileDir.pm \
	  TFBS/PatternGen.pm $(INST_LIB)/TFBS/PatternGen.pm \
	  TFBS/MatrixSet.pm $(INST_LIB)/TFBS/MatrixSet.pm \
	  TFBS/PatternGen/SimplePFM.pm $(INST_LIB)/TFBS/PatternGen/SimplePFM.pm \
	  TFBS/Word.pm $(INST_LIB)/TFBS/Word.pm \
	  TFBS/DB/JASPAR2.pm $(INST_LIB)/TFBS/DB/JASPAR2.pm \
	  TFBS/Matrix.pm $(INST_LIB)/TFBS/Matrix.pm \
	  TFBS/PatternGen/AnnSpec/Motif.pm $(INST_LIB)/TFBS/PatternGen/AnnSpec/Motif.pm \
	  TFBS/PatternGen/Motif/Matrix.pm $(INST_LIB)/TFBS/PatternGen/Motif/Matrix.pm \
	  TFBS/Matrix/PWM.pm $(INST_LIB)/TFBS/Matrix/PWM.pm 
	$(NOECHO) $(TOUCH) pm_to_blib


# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:


# End.
