#!/bin/bash
#
# Installs hgx and associated tools into LIBDIR and 
# creates softlinks for the executables into BINDIR
#
# Change either of the two xxxDIR vars below if 
# you'd like to install in different directories.
#
LIBDIR=~/ConfigFiles/Mercurial
BINDIR=~/bin

set -e
read -p "About to place pbranch,perfarce,qimportbz and hgx tools in $LIBDIR. OK? " REP
[[ "${REP:0:1}" = "y" ]] || exit 1

echo -e ${HGUP} > hgrc.updates

{ set +e; mkdir -p $LIBDIR ; set -e; } &> /dev/null
pushd $LIBDIR
LIBDIR=`pwd`

echo "Obtaining needed mercurial repos"

REPOS="http://hg.mozilla.org/users/rreitmai_adobe.com/hgx  http://www.kingswood-consulting.co.uk/hg/perfarce http://bitbucket.org/parren/hg-pbranch http://hg.mozilla.org/users/robarnold_cmu.edu/qimportbz"

for REP in $REPOS; do
    RDIR=${REP##*/}
	if [[ -a "${RDIR}" ]]; then 
		read -ep "${RDIR} : exists, freshen it? " ANS
		[[ "${ANS:0:1}" = "y" ]] && { hg -R ${RDIR} pull -u ; }
	else
		echo "cloning ${REP} to ${RDIR}"
		hg clone ${REP} ${RDIR}
    fi
done
popd

# instals hgx commands using softlinks
echo ""
read -p "Create softlinks for hgx commands to ${BINDIR}. OK? " REP
[[ "${REP:0:1}" = "y" ]] || exit 1

{ set +e; mkdir $BINDIR ; set -e; } &> /dev/null
pushd $BINDIR
BINDIR=`pwd`
popd

pushd $LIBDIR/hgx
for i in `ls branch*` `ls hgx*` 'bugz_update' 'hgbl' 'avmws' ; do 
   ln -fvs `pwd`/${i} ${BINDIR}
done
popd

echo -e "\n**** NOTE : Apply contents of the file 'hgrc.updates' to your ~/.hgrc file"
HGUP="[extensions]\n"\
"color =\n"\
"convert = \n"\
"graphlog = \n"\
"mq = \n"\
"rebase = \n"\
"pbranch = ${LIBDIR}/hg-pbranch/hgext/pbranch.py\n"\
"perfarce = ${LIBDIR}/perfarce/perfarce.py\n"\
"qimportbz = ${LIBDIR}/qimportbz\n"\
"\n[defaults]\n"\
"pdiff = --git\n"\
"\n[perfarce]\n"\
"keep = False\n"\
"submit = False\n"\
"tags = False\n"\
"ignorecase = True\n"\
"\n[qimportbz]\n"\
"auto_choose_all = True\n"\
"patch_format = \"bug-%(bugnum)s-%(id)s.diff\"\n"\
"msg_format = Bug %(bugnum)s - %(title)s (%(flags)s)\n"\
" .\n"\
" . attachment %(id)s - %(desc)s \n"\
" .\n"\
" %(bugdesc)s\n"\

echo -e ${HGUP} > hgrc.updates
