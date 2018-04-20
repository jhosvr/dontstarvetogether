#!/bin/bash

# name: install.sh
# author: Justin Ho
# date: 20180419
# description: installs steamcmd and Klei's Do Not Starve Together

checkBin() { if ! which "${1}" 2>/dev/null; then echo "ERROR: ${1} package not found. Please make sure it is installed."; fi; }

#### DEFAULT VARIABLES
steamcmd="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
steamBase=$HOME/steamcmd
kleiBase=$HOME/.klei

#### OVERRIDES

while [[ ! -z "${1}" ]]; do
  case "${1}" in
    "-steam"

#### EXECUTION CHECKS
checkBin wget
checkBin 

#### SCRIPT EXECUTION

# install steamCMD
echo "Installing Steam-cmd at $steamBase"
mkdir -p "$steamBase"
cd "$steamBase"
wget "$steamcmd"
tar -xvzf $(echo "$steamcmd" | rev | cut -d'/' -f1 | rev)

# install Don't Starve Together
echo "Installing \"Don't Starve Together\" at $kleiBase"
$steamBase/steamcmd.sh +force_install_dir "$kleiBase" +login anonymous +app_update 343050 validate +quit

