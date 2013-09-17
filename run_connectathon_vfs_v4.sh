#!/bin/bash -x
#
# Copyright IBM  (2012)
# Author(s): Sean Dague      sdague@us.ibm.com
#            Jeremy Bongio   jbongio@us.ibm.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
# ---------------------------------------
##
## run_connectathon.sh
##
## Made by Sean Dague
## Login   <sdague@orac>
##
## Started on  Fri Nov 19 11:12:16 2010 Sean Dague
## Last update Fri Nov 19 11:12:16 2010 Sean Dague
##

CONFDIR=`dirname ${0}`
source $CONFDIR/CONFIG

SERVER=$1
HOSTFS=$2

# get rid of the test files
rm -f $WORKSPACE/*.xml
sudo rm -rf /tmp/root /tmp/jenkins

echo "Building connectathon"
if [[ ! -d /home/hudson/cthon04 ]]; then
    git clone $CTHON04_LOC /home/hudson/cthon04
fi

sh $HOME/scripts/build_dirs.sh $SERVER $HOSTFS
cd /home/hudson/cthon04
git pull
sudo rm -f domount
make
sudo chown root domount
sudo chmod u+s domount

echo "Unmounting everything"
sudo killall runcthon
sudo killall tlocklfs

sudo ./runcthon --unmountall
sleep 1
sudo umount -l /mnt

ssh -tt root@${SERVER} service nfs-ganesha-vfs restart || exit 1
sleep 5

NFSNOTREADY=1
while [ $NFSNOTREADY -ne 0 ]
do
    sudo mount -t nfs -o vers=3 ${SERVER}:$HOSTFS /mnt
    NFSNOTREADY=$?
    sleep 5
    echo "sleeping 5 seconds to ensure NFS is ready"
done
sudo umount -l /mnt
sleep 1

sudo ./runcthon --server ${SERVER} --serverdir $HOSTFS/hudson/root/$NODE_NAME --onlyv4 --noudp

echo "Unmounting everything"
sudo killall runcthon
sudo killall tlocklfs

sudo ./runcthon --unmountall
sleep 1
sudo umount -l /mnt

ssh -tt root@${SERVER} service nfs-ganesha-vfs restart || exit 1
sleep 5

NFSNOTREADY=1
while [ $NFSNOTREADY -ne 0 ]
do
    sudo mount -t nfs -o vers=3 ${SERVER}:$HOSTFS /mnt
    NFSNOTREADY=$?
    sleep 5
    echo "sleeping 5 seconds to ensure NFS is ready"
done
sudo umount -l /mnt
sleep 1

./runcthon --server ${SERVER} --serverdir $HOSTFS/hudson/jenkins/$NODE_NAME --onlyv4 --noudp
sudo ./runcthon --unmountall


echo "Running the parser"
# get the parse
if [[ ! -d /home/hudson/cthon2junit ]]; then
    git clone $CTHON2JUNIT_LOC /home/hudson/cthon2junit
else
    cd /home/hudson/cthon2junit
    git fetch $CTHON2JUNIT_LOC master
    git reset --hard FETCH_HEAD
fi

cd /home/hudson/cthon2junit
git pull
./cthon2junit.rb $WORKSPACE /tmp/root "root-" noudp nokrb v3
./cthon2junit.rb $WORKSPACE /tmp/jenkins "jenkins-" noudp nokrb v3
