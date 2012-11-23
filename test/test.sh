#!/bin/sh

die() {
  echo 2>&1 "$@"
  exit 1
}

if ! [ -x test.sh ]; then
  echo "You must run this test from the directory containing test.h"
  exit 1
fi

rm -rf var
mkdir var || die "Failed to create test/var"

TEST_DIR=`pwd`/var

export glidein_config=$TEST_DIR/glidein_config
sed < glidein_config > $glidein_config "s|TEST_DIR|$TEST_DIR|g" || die "Failed to create test/var/glidein_config"

mkdir $TEST_DIR/parrot
tar x -C $TEST_DIR/parrot -f `pwd`/../parrot.tgz || die "Failed to extract parrot"

mkdir $TEST_DIR/cms_siteconf
tar x -C $TEST_DIR/cms_siteconf -f `pwd`/../cms_siteconf.tgz || die "Failed to extract cms_siteconf"

touch $TEST_DIR/condor_vars.lst

#cp `pwd`/../parrot_cfg_wisc $TEST_DIR/parrot_cfg
cp `pwd`/../parrot_cfg_cern $TEST_DIR/parrot_cfg

env - ../parrot_setup $TEST_DIR/glidein_config || die "parrot_setup failed"
env - ../parrot_cms_setup $TEST_DIR/glidein_config || die "parrot_cms_setup failed"


mkdir -p $TEST_DIR/execute
cd $TEST_DIR/execute

export _CONDOR_SCRATCH_DIR=`pwd`
export _CONDOR_SLOT=1
export _CONDOR_JOB_AD=.jobad
echo RequiresCVMFS=True > $_CONDOR_JOB_AD

export PATH=/bin:/usr/bin:/usr/local/bin
unset LD_LIBRARY_PATH
export CVMFS_OSG_APP=`grep -i "^CVMFS_OSG_APP " $glidein_config | awk '{print $2}'`
export VO_CMS_SW_DIR=`grep -i "^VO_CMS_SW_DIR " $glidein_config | awk '{print $2}'`
export GLIDEIN_PARROT=`grep -i "^GLIDEIN_PARROT " $glidein_config | awk '{print $2}'`
export GLIDEIN_PARROT_OPTIONS=`grep -i "^GLIDEIN_PARROT_OPTIONS " $glidein_config | awk '{$1=""; print $0}'`

if [ "$CVMFS_OSG_APP" != "" ]; then
  sh ../../../cvmfs_job_wrapper test -d $CVMFS_OSG_APP || die "cvmfs_job_wrapper failed to find $OSG_APP"
fi

sh ../../../cvmfs_job_wrapper test -d $VO_CMS_SW_DIR || die "cvmfs_job_wrapper failed to find $VO_CMS_SW_DIR"

sh ../../../cvmfs_job_wrapper sh -c "ls > /dev/null" || die "cvmfs_job_wrapper failed to write to /dev/null"

sh ../../../cvmfs_job_wrapper sh -c "mkdir -p workdir/blah1/blah2 && touch workdir/blah1/file1 && rm -rf workdir" || die "cvmfs_job_wrapper failed to create/remove workdir"

# the following makes use of the fact that /tmp is remapped to _CONDOR_SCRATCH_DIR/tmp

sh ../../../cvmfs_job_wrapper cp $VO_CMS_SW_DIR/SITECONF/local/PhEDEx/storage.xml /tmp || die "cvmfs_job_wrapper failed"

diff ../cms_siteconf/SITECONF/local/PhEDEx/storage.xml tmp/storage.xml || die "storage.xml copied from within parrot does not match expected"

echo "Success"
