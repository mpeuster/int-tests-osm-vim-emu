#!/bin/bash

#set -x
set -e

###
### Test 1
###
echo "********* Test 1: vim-create *********"
echo "Getting vim-emu container IP ..."
export VIMEMU_HOSTNAME=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' vim-emu)
echo $VIMEMU_HOSTNAME
# check if no vim is present before test
if [ $(osm vim-list | wc -l) -ne 4 ]; then
    echo "FAIL"
    exit 1
fi
# creat vim
osm vim-create --name test-vim1 --user username --password password --auth_url http://$VIMEMU_HOSTNAME:6001/v2.0 --tenant tenantName --account_type openstack
sleep 1
# check if vim is there
if [ $(osm vim-list | grep -c 'test-vim1') == 0 ]; then
    echo "FAIL"
    exit 1
fi
echo "PASS"




###
### Test 7
###
echo "********* Test 7: vim-delete *********"
osm vim-delete test-vim1
sleep 1
if [ $(osm vim-list | wc -l) -ne 4 ]; then
    echo "FAIL"
    exit 1
fi
echo "PASS"

###
### Done
###
echo "**************************************"
echo "*********        PASS        *********"
echo "**************************************"
