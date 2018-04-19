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

#### DEFAULT VARIABLES

conf="../conf/default.conf"
dstBase="$HOME/.klei/DoNotStarveTogether"

#### OVERRIDES

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

#### EXECUTION CHECKS

fileNotExists "${conf}" \
  "ERROR: unable to locate conf file ${conf}" \
  "exit 1"
dirNotExists "${dstBase}" \
  "ERROR: The folder ${dstBase} does not exist. Please install the game or specify another location with the -base parameter." \
  "exit 1"


#### SCRIPT EXECUTION
setupBase="${dstBase}"/"${cluster_name}"

# Create dedicated server folders
source <(sed -n '/# SECTION: server\/cluster.ini/,/# SECTION: .*/p' "${conf}")
mkdir -p "${setupBase}"/Master
mkdir -p "${setupBase}"/Caves

# Create cluster token file
source <(sed -n '/# SECTION: cluster_token.txt/,/# SECTION: .*/p' "${conf}")
echo "${cluster_token}" > "${setupBase}/cluster_token.txt"

# Create base cluster.ini file
echo "
[GAMEPLAY]
game_mode = $game_mode
max_players = $max_players
pvp = $pvp
pause_when_empty = $pause_when_empty
vote_enabled = $vote_enabled

[NETWORK]
offline_cluster = $offline_cluster
cluster_description = $cluster_description
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


# Create /server/Master/server.ini








