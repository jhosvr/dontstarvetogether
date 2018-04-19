#!/bin/bash
#
# name: setupServer.sh
# author: Justin Ho
# date: 20180415
# description: this script is executed to set up a new Dont Starve Together server.

usage() {
  echo "$0 : creates folders and base configuration files for a don't starve dedicated server
    required arguments
      -conf : configuration file located in the conf folder
    optional arguments
      -base : specify a different installation directory of DST. The default is in $HOME/.klei/DoNotStarveTogether
    "
}

# Error checking functions. Parameter format is $1=object $2=message-to-return $3=action-to-take
fileNotExists() { if [[ ! -f "${1}" ]]; then echo "${2}" && ${3}; fi; }
dirNotExists() { if [[ ! -d "${1}" ]]; then echo "${2}" && ${3}; fi; }
dirExists() { if [[ -d "${1}" ]]; then echo "${2}" && ${3}; fi; }
isEmpty() { if [[ -z "${1}" ]]; then echo "${2}" && ${3}; fi; }
checkFail() { if [[ "$?" != "0" ]]; then echo "ERROR: failed at step ${step}" && exit 2; fi; }

####
#### DEFAULT VARIABLES
####

conf="../conf/default.conf"
dstBase="$HOME/.klei/DoNotStarveTogether"


####
#### OVERRIDES
####
step="[establish-overrides]"

while [[ ! -z "${1}" ]]; do
  case "${1}" in
    "-conf")
        conf="../conf/${2}"
        shift; shift;;
    "-base")
        dstBase="${2}"
        shift; shift;;
    "-h"|"-help"|"-?")
        usage && exit ;;
  esac
done

checkFail

####
#### EXECUTION CHECKS
####
step="[execution-checks]"

fileNotExists "${conf}" \
  "ERROR: unable to locate conf file ${conf}" \
  "exit 1"
dirNotExists "${dstBase}" \
  "ERROR: The folder ${dstBase} does not exist. Please install the game or specify another location with the -base parameter." \
  "exit 1"

tokenCheck=$(grep "cluster_token=" "${conf}" | awk -F'=' '{print $2}')
isEmpty "${tokenCheck}" \
  "ERROR: cluster_token variable was not set. Please check ${conf}, the token is required to run a server." \
  "exit 1"
serverName=$(grep "cluster_name=" "${conf}" | awk -F'=' '{print $2}')
dirExists "${dstBase}/${serverName}" \
  "ERROR: ${dstBase}/${serverName} already exists. This script will exit so it does not harm any existing files." \
  "exit 1"
if [[ "${conf}" == "../conf/default.conf" ]]; then
  echo "WARNING: a seperate conf file was not specified. Applying defaults."
  fi

checkFail

####
#### SCRIPT EXECUTION
####
step="[script-execution]"
setupBase="${dstBase}"/"${serverName}"


step="[create-server-folders]"
source <(sed -n '/#### SECTION: server\/cluster.ini/,/#### SECTION: .*/p' "${conf}")
echo "${step} Creating server instance folders"
mkdir -p "${setupBase}"/Master
mkdir -p "${setupBase}"/Caves
checkFail


step="[create-cluster-token]"
source <(sed -n '/#### SECTION: cluster_token.txt/,/#### SECTION: .*/p' "${conf}")
echo "${step} Creating cluster token file"
echo "${cluster_token}" > "${setupBase}/cluster_token.txt"
checkFail


step="[create-cluster.ini]"
echo "${step} Generating ${cluster_name}/cluster.ini"
echo "[GAMEPLAY]
game_mode = $game_mode
max_players = $max_players
pvp = $pvp
pause_when_empty = $pause_when_empty
vote_enabled = $vote_enabled

[NETWORK]
offline_cluster = $offline_cluster
cluster_description = \"$cluster_description\"
cluster_name = \"$cluster_name\"
cluster_intention = $cluster_intention
cluster_password = $cluster_password
tick_rate = $tick_rate
whitelist_slots = $whitelist_slots
lan_only_cluster = $lan_only_cluster
auto_saver_enabled = $auto_saver_enabled

[MISC]
console_enabled = $console_enabled
max_snapshots = $max_snapshots

[SHARD]
shard_enabled = $shard_enabled
bind_ip = $bind_ip
master_ip = $master_ip
master_port = $master_port
cluster_key = $cluster_key
" > "${setupBase}"/cluster.ini
checkFail


step="[create-master-server.ini]"
echo "${step} Generating Master/server.ini"
source <(sed -n '/#### SECTION: server\/Master\/server.ini/,/#### SECTION: .*/p' "${conf}")
echo "[NETWORK]
server_port = $server_port

[SHARD]
is_master = $is_master
name = $name
id = $id

[STEAM]
master_server_port = $master_server_port
authentication_port = $authentication_port
" > "${setupBase}"/Master/server.ini
checkFail


step="[create-caves-server.ini]"
echo "${step} Generating Caves/server.ini"
source <(sed -n '/#### SECTION: server\/Caves\/server.ini/,/#### SECTION: .*/p' "${conf}")
echo "[NETWORK]
server_port = $server_port

[SHARD]
is_master = $is_master
name = $name
id = $id

[STEAM]
master_server_port = $master_server_port
authentication_port = $authentication_port
" > "${setupBase}"/Caves/server.ini
checkFail


step="[create-caves-worldgen]"
echo "${step} Generating Caves/worldgenoverride.lua"
echo "return {
  override_enabled = true,
  preset = "DST_CAVE",
}
" > "${setupBase}"/Caves/worldgenoverride.lua
checkFail

