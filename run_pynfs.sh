#!/bin/bash -x
##
## run_connectathon.sh
##
## Made by Sean Dague
## Login   <sdague@orac>
##
## Started on  Fri Nov 19 11:12:16 2010 Sean Dague
##

CONFDIR=`dirname ${0}`
source $CONFDIR/CONFIG

SERVER=$1
HOSTFS=$2

$PWD = `pwd`
# get rid of the test files
rm -f $WORKSPACE/*.xml
sudo rm -rf /tmp/pynfs4.0 /tmp/pynfs4.1

echo "Building pynfs"
if [[ ! -d /home/hudson/pynfs ]]; then
    git clone $PYNFS_LOC /home/hudson/pynfs
fi

cd /home/hudson/pynfs/nfs4.0
git pull
yes | python setup.py build
mkdir -p /tmp/pynfs4.0
sudo python testserver.py $SERVER:$HOSTFS --maketree --hidepass all ganesha CIDCF2 LOOKP6 CMT1aa RD4 SATT1a SATT1s LKU6c LOCK13a noLOCKHELD &> /tmp/pynfs4.0/root-results
perl $HOME/scripts/parse_pynfs.pl /tmp/pynfs4.0/root-results &> $WORKSPACE/pynfs4.0_results.xml

#cd /home/hudson/pynfs/nfs4.1
#git pull
#yes | python setup.py build
#mkdir -p /tmp/pynfs4.1
#sudo python testserver.py $SERVER:$HOSTFS --maketree all &> /tmp/pynfs4.1/root-results
#perl parse_pynfs.pl /tmp/pynfs4.1/root-results &> $WORKSPACE/pynfs4.1_results.xml
