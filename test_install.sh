#!/bin/bash

set -x
set -e

pwd

# cleanup
rm -f install_osm.sh

# get latest installer
wget https://osm-download.etsi.org/ftp/osm-5.0-five/install_osm.sh
chmod +x install_osm.sh

# uninstall old OSM
./install_osm.sh --uninstall 2>&1 | tee logs/osm_uninstall.log

# install new OSM
./install_osm.sh 2>&1 | tee logs/osm_install.log
