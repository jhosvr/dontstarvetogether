#!/bin/bash
#
# name: setupServer.sh
# author: jhosvr
# date: 20180415
# description: this script is executed to install and set up a new Dont Starve Together server.

usage() {
echo "$0 : creates folders and base configuration files for a don't starve dedicated server. defaults will be used if optional arguments are not specified.
  optional arguments
  -base: specify a different base location for installations. default: ${base}
  -dst : specify a different installation directory of DST Server configs. default: ${dstserverdir}
  -cmd : specify a different installation of steamcmd. default: ${steamcmddir}
  -conf: configuration file located in the conf folder. default: default.conf
"
}

####
#### DEFAULT VARIABLES
####
source functions.sh
workdir=$(pwd)

# base directory for installations
base="${HOME}/dst-server"

# steam cmd variables
steamcmddir="${base}/steamcmd"
steamcmdurl="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
steamcmdpkg=$(echo "${steamcmdurl}"|awk -F'/' '{print $NF}')

# dont starve game variables
dstgamedir="${base}/dst"
modsdir="${dstgamedir}/mods"

# dont starve server variables
dstserverdir="${base}/servers"
dstconf="${workdir}/../conf/default.conf"
modsfile="${workdir}/../conf/mods.list"

####
#### OVERRIDES
####

step="[override variables]"

while [[ ! -z "${1}" ]]; do
  case "${1}" in
    "-base")
        base="${2}"
        shift; shift;;
    "-dst")
        dstserverdir="${2}"
        shift; shift;;
    "-cmd")
        steamcmddir="${2}"
        shift; shift;;
    "-conf")
        dstconf="${workdir}/../conf/${2}"
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

fileNotFound "${base}" \
  "${step} INFO: Base directory ${base} not found, creating directory" \
  "mkdir -p ${base}"

fileNotFound "${steamcmddir}" \
  "${step} INFO: Steam-cmd directory ${steamcmddir} not found, creating directory" \
  "mkdir -p ${steamcmddir}"

fileNotFound "${dstconf}" \
  "${step} ERROR: unable to locate conf file ${dstconf}, please make sure it exists." \
  "exit 1"

cluster_token=$(grep "cluster_token=" "${dstconf}" | awk -F'=' '{print $2}')
varNotSet "${cluster_token}" \
  "${step} ERROR: cluster_token has not been set. Please check ${dstconf}, the token is required to run a server." \
  "exit 1"

cluster_name=$(grep "cluster_name=" "${dstconf}" | awk -F'=' '{print $2}')
fileFound "${dstserverdir}/${cluster_name}" \
  "${step} INFO: ${dstserverdir}/${cluster_name} already exists. Renaming this to ${dstserverdir}/${cluster_name}_$(date +%Y%m%d-%H%M)" \
  "mv ${dstserverdir}/${cluster_name} ${dstserverdir}/${cluster_name}_$(date +%Y%m%d-%H%M)"

if [[ "${dstconf}" == "../conf/default.conf" ]]; then
  echo "${step} INFO: a seperate conf file was not specified. Defaults will be applied."
fi

####
#### SCRIPT EXECUTION
####

dstserverbase="${dstserverdir}/${cluster_name}"

# Install steamcmd and DST
step="[install: steam cmd]"
fileNotFound "${steamcmddir}/steamcmd.sh" \
  "${step} INFO: steamcmd.sh was not found in ${steamcmddir}, installing Steam-cmd" \
  "install_steamcmd || fail"

step="[install: don't starve together]"
fileNotFound "${dstgamedir}" \
  "${step} INFO: DST game directory ${dstgamedir} was not found, installing don't starve together at ${dstgamedir}" \
  "install_dst || fail"

# Create folder structures and links
create_symlinks || fail
create_dstserver_folders || fail

# Generate server configuration files
generate_cluster_token || fail
generate_server_cluster_ini || fail
generate_master_server_ini || fail
generate_caves_server_ini || fail
generate_caves_default_worldgen || fail

# Generate script files
generate_mods_scripts || fail
generate_server_script || fail
