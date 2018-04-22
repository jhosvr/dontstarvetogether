#!/bin/bash
#
# name: setupServer.sh
# author: jhosvr
# date: 20180415
# description: this script is executed to install and set up a new Dont Starve Together server.

usage() {
echo "$0 : creates folders and base configuration files for a don't starve dedicated server. defaults will be used if optional arguments are not specified.
  optional arguments
  -dstdir : specify a different installation directory of DST. default: $HOME/.klei/DoNotStarveTogether
  -cmddir : specify a different installation of steamcmd. default: $HOME/steamcmd
  -dstconf: configuration file located in the conf folder. default: ../conf/default.conf
"
}

####
#### DEFAULT VARIABLES
####
source functions.sh

dir_dst="$HOME/.klei/DoNotStarveTogether"
dir_cmd="$HOME/steamcmd"
dir_current=$(pwd)
url_cmd="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
cmd=$(echo $url_cmd | awk -F'/' '{print $NF}')
dstconf="../conf/default.conf"

####
#### OVERRIDES
####

step="[override variables]"

while [[ ! -z "${1}" ]]; do
  case "${1}" in
    "-dstdir")
        dir_dst="${2}"
        shift; shift;;
    "-cmddir")
        dir_cmd="${2}"
        shift; shift;;
    "-dstconf")
        dstconf="../conf/${2}"
        shift; shift;;
    "-h"|"-help"|"-?")
        usage && exit ;;
    *)  fail "\"${1}\" is not a valid parameter. Please check $0 -help for usage" ;;
  esac
done

####
#### EXECUTION CHECKS
####
step="[execution-checks]"

# Check for existing folders and directories
fileNotFound "${dstconf}" \
  "ERROR: unable to locate conf file ${dstconf}" \
  "exit 1"
dirNotFound "${dir_dst}" \
  "ERROR: The folder ${dir_dst} does not exist. Please install the game or specify another location with the -base parameter." \
  "exit 1"

# Check cluster token
cluster_token=$(grep "cluster_token=" "${dstconf}" | awk -F'=' '{print $2}')
isEmpty "${cluster_token}" \
  "ERROR: cluster_token variable was not set. Please check ${dstconf}, the token is required to run a server." \
  "exit 1"

# Check if server already exists
cluster_name=$(grep "cluster_name=" "${dstconf}" | awk -F'=' '{print $2}')
dirFound "${dir_dst}/${cluster_name}" \
  "ERROR: ${dir_dst}/${cluster_name} already exists. This script will exit so it does not harm any existing files." \
  "exit 1"

if [[ "${dstconf}" == "../conf/default.conf" ]]; then
  echo "WARNING: a seperate conf file was not specified. Applying defaults."
fi

####
#### SCRIPT EXECUTION
####
dir_dstserver="${dir_dst}"/"${serverName}"

install_steamcmd || fail
install_dst || fail
create_dstserver_folders || fail
generate_cluster_token || fail
generate_server_cluster_ini || fail
generate_master_server_ini || fail
generate_caves_server_ini || fail
generate_caves_worldgen || fail
generate_server_script || fail
