#!/bin/bash

# name: install.sh
# author: Justin Ho
# date: 20180419
# description: installs steamcmd and Klei's Do Not Starve Together

usage() {
echo "$0 : installs steam-cmd and Klei's Don't Starve Together
  optional arguments:
    -cmd : designate a different directory to install steamcmd (default: $HOME/steamcmd)
    -dst : designate a different directory to install DST (default: $HOME/.klei/DoNotStarveTogether)"
}

#### DEFAULT VARIABLES
cmdUrl="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
cmd="$(echo "$cmdUrl" | awk -F'/' '{print $NF}')"
cmdBase="$HOME/steamcmd"
dstBase="$HOME/.klei/DoNotStarveTogehter"

#### OVERRIDES

while [[ ! -z "${1}" ]]; do
  case "${1}" in
    "-cmd")
        cmdBase="${2}"
        shift; shift;;
    "-dst")
        dstBase="${2}"
        shift; shift;;
    "-help"|"--help"|"-?")
        usage
        exit 0 ;;
  esac
done

#### SCRIPT EXECUTION

# install steamCMD
echo "Installing Steam-cmd at $cmdBase"
mkdir -p "$cmdBase"
cd "$cmdBase"
wget "$cmdUrl" || (echo "unable to retrieve $cmd from $cmdUrl" && exit 1)
tar -xvzf "$cmd"

# install Don't Starve Together
echo "Installing \"Don't Starve Together\" at $dstBase"
$cmdBase/steamcmd.sh +force_install_dir "$dstBase" +login anonymous +app_update 343050 validate +quit

