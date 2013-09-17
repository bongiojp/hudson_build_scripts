#!/bin/bash -x
#
# Copyright IBM  (2012)
# Author(s): Jeremy Bongio   jbongio@us.ibm.com
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
CONFDIR=`dirname ${0}`
source $CONFDIR/CONFIG

SERVER=$1
HOSTFS=$2

declare -a arch=(hudson hudson64)
declare -a users=(jenkins root)
declare -a clients=(rhel60 rhel66_64 rhel55_32 ubuntu32 HamzyTest)
declare -a tests=(nfsv3tcp nfsv3udp nfsv4tcp sigmund pynfs)

for arch in ${arch[@]}
do
    for user in ${users[@]}
    do
        for client in ${clients[@]}
        do
            for test in ${tests[@]}
            do
                echo "building directory: $HOSTFS/$arch/$user/$client/$test"
                ssh -tt root@$SERVER mkdir -p $HOSTFS/$arch/$user/$client/$test
            done
        done
        ssh -tt root@$SERVER chown $user $HOSTFS/$arch/$user -R
        ssh -tt root@$SERVER chgrp $user $HOSTFS/$arch/$user -R
    done
    ssh -tt root@$SERVER chown jenkins $HOSTFS/$arch -R
    ssh -tt root@$SERVER chgrp jenkins $HOSTFS/$arch -R
done
