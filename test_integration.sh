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
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi
# create vim
osm vim-create --name test-vim1 --user username --password password --auth_url http://$VIMEMU_HOSTNAME:6001/v2.0 --tenant tenantName --account_type openstack
sleep 1
# check if vim is there
if [ $(osm vim-list | grep -c 'test-vim1') == 0 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi

###
### Test 2
###
echo "********* Test 2: on-boarding *********"
# create VNFDs
osm vnfd-create vnf/hackfest_1_vnfd.tar.gz
osm vnfd-create vnf/hackfest_2_vnfd.tar.gz
# check if VNFDs are there
if [ $(osm vnfd-list | grep -c 'hackfest1-vnf') == 0 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi
if [ $(osm vnfd-list | grep -c 'hackfest2-vnf') == 0 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi
# create NSD
osm nsd-create ns/hackfest_1_nsd.tar.gz
# check if NSD is there
if [ $(osm nsd-list | grep -c 'hackfest1-ns') == 0 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi


###
### Test 3
###
echo "********* Test 3: instantiation *********"
osm ns-create --nsd_name hackfest1-ns --ns_name test-ns1-cli --vim_account test-vim1
# wait for instantiation (FIXME quick hack)
echo "Waiting for instantiation ..."
sleep 20
echo "done"
if [ $(osm ns-list | grep -c 'test-ns1-cli') == 0 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi
if [ $(osm ns-list | grep -c 'running') == 0 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi
if [ $(osm ns-list | grep -c 'configured') == 0 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi
if [ $(osm ns-list | grep -c 'done') == 0 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi



###
### Test 4
###
echo "********* Test 4: list commands *********"
if [ $(osm vim-list | grep -c 'test-vim1') == 0 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi
if [ $(osm vnfd-list | grep -c 'hackfest1-vnf') == 0 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi
if [ $(osm vnfd-list | grep -c 'hackfest2-vnf') == 0 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi
if [ $(osm nsd-list | grep -c 'hackfest1-ns') == 0 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi
if [ $(osm ns-list | grep -c 'test-ns1-cli') == 0 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi

###
### OPTIONAL: Manual hold running deployment
###
#echo "All test deployments done."
#read -p "Press any key to continue and terminate... " -n1 -s
#sleep 2

###
### Test 5
###
echo "********* Test 5: termination *********"
osm ns-delete test-ns1-cli
# wait (FIXME quick hack)
echo "Waiting for termination ..."
sleep 10
echo "done"
if [ $(osm ns-list | wc -l) -ne 4 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi

###
### Test 6
###
echo "********* Test 6: delete descriptors *********"
# delete NSD
osm nsd-delete hackfest1-ns
if [ $(osm nsd-list | wc -l) -ne 4 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi
# delete VNFDs
osm vnfd-delete hackfest1-vnf
osm vnfd-delete hackfest2-vnf
if [ $(osm vnfd-list | wc -l) -ne 4 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi

###
### Test 7
###
echo "********* Test 7: vim-delete *********"
osm vim-delete test-vim1
sleep 1
if [ $(osm vim-list | wc -l) -ne 4 ]; then
    echo -e "\e[1m\e[31mFAIL\e[0m"
    #    exit 1
else
    echo -e "\e[1m\e[32mPASS\e[0m"
fi

###
### Done
###
echo "**************************************"
echo "*********        DONE        *********"
echo "**************************************"
