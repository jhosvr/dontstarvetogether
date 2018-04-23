#!/bin/bash -e

# name: functions.sh
# author: jhosvr
# date: 20180421
# description: functions file to be sourced for usage and organization within the DST scripts

####
#### Error checking functions. Parameter format is $1=object $2=message-to-return $3=action-to-take
####

fail() {
  echo "${step} ERROR: ${1}" >&2
  exit 1
}

fileNotFound() {
if [[ ! -f "${1}" ]]; then
  echo "${2}"
  ${3}
fi
}

dirNotFound() {
if [[ ! -d "${1}" ]]; then
  echo "${2}"
  ${3}
fi
}

dirFound() {
if [[ -d "${1}" ]]; then
  echo "${2}"
  ${3}
fi
}

isEmpty() {
if [[ -z "${1}" ]]; then
  echo "${2}"
  ${3}
fi
}

####
#### Installation functions
####

install_steamcmd() {
  step="[install: steam cmd]"
  mkdir -p "$dir_cmd"
  cd "$dir_cmd"
  wget "$url_cmd" || fail "could not get $cmd from $url_cmd"
  tar -xvzf "$cmd"
  cd "${dir_current}"
}

install_dst() {
  step="[install: don't starve together]"
  $dir_cmd/steamcmd.sh +force_install_dir "$dir_dst" +login anonymous +app_update 343050 validate +quit || fail "error installing don't starve together"
}

create_dstserver_folders() {
  step="[generate: dst server folders]"
  source <(sed -n '/#### SECTION: server\/cluster.ini/,/#### SECTION: .*/p' "${dstconf}")
  echo "${step} Creating dst server instance folders"
  mkdir -p "${dir_dstserver}"/Master
  mkdir -p "${dir_dstserver}"/Caves
}

####
#### File generation functions
####

generate_cluster_token() {
  step="[generate: cluster token]"
  echo "${step} Creating cluster token file"
  echo "${cluster_token}" > "${dir_dstserver}/cluster_token.txt"
}

generate_server_cluster_ini() {
  step="[generate: cluster.ini]"
  source <(sed -n '/#### SECTION: server\/cluster.ini/,/#### SECTION: .*/p' "${dstconf}")
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
" > "${dir_dstserver}"/cluster.ini
}


generate_master_server_ini() {
  step="[generate: master/server.ini]"
  echo "${step} Generating Master/server.ini"
  source <(sed -n '/#### SECTION: server\/Master\/server.ini/,/#### SECTION: .*/p' "${dstconf}")
echo "[NETWORK]
server_port = $server_port

[SHARD]
is_master = $is_master
name = $name
id = $id

[STEAM]
master_server_port = $master_server_port
authentication_port = $authentication_port
" > "${dir_dstserver}"/Master/server.ini
}

generate_caves_server_ini() {
  step="[generate: caves/server.ini]"
  echo "${step} Generating Caves/server.ini"
  source <(sed -n '/#### SECTION: server\/Caves\/server.ini/,/#### SECTION: .*/p' "${dstconf}")
echo "[NETWORK]
server_port = $server_port

[SHARD]
is_master = $is_master
name = $name
id = $id

[STEAM]
master_server_port = $master_server_port
authentication_port = $authentication_port
" > "${dir_dstserver}"/Caves/server.ini

}

generate_caves_worldgen() {
  step="[generate: caves/worldgen]"
echo "${step} Generating Caves/worldgenoverride.lua"
echo "return {
  override_enabled = true,
  preset = "DST_CAVE",
}
" > "${dir_dstserver}"/Caves/worldgenoverride.lua
}

generate_mod_scripts() {
  step="[generate: dedicated server mods script]"
  echo "$step Creating the runscript for mod configurations"
  cp -v "${modlistfile}" "${dir_dstserver}/mods.list"
  ln -sf "${dir_mods}" "${dir_dst}"/mods
  dir_mods="${dir_dst}/mods"

  echo "# name: ${cluster_name}_mods.sh
# description: this file was autogenerated by the https://github.com/jhosvr/dontstarvetogether repository's setup script

echo \"Generating mod config files\"
modlist=( \$(awk -F',' '{print \$1}' ${dir_dstserver}/mods.list) )

# Generate dedicated_server_mods_setup file
for modnumber in \"\${modlist[@]}\"; do
  echo \"--ServerModSetup(\\\"\$modnumber\\\")\" >> \"${dir_mods}/dedicated_server_mods_setup.lua\"
done

# Generate modoverrides file
echo \"return {\" > ${dir_dstserver}/Master/modoverrides.lua
for modnumber in \"\${modlist[@]}\"; do
  echo \"[\\\"workshop-\$modnumber\\\"] = { enabled = true },\" >> ${dir_dstserver}/Master/modoverrides.lua
done
echo \"}\" >> ${dir_dstserver}/Master/modoverrides.lua

cp -p ${dir_dstserver}/Master/modoverrides.lua ${dir_dstserver}/Caves/modoverrides.lua
" > "${dir_dstserver}/generate_mod_configs.sh"
chmod +x "${dir_dstserver}/generate_mod_configs.sh"
}

generate_server_script() {
  scriptName="${cluster_name// /_}"
  startScript="${HOME}/$scriptName.sh"
  step="[generate: server start script] Generating $scriptName"
  echo "${step}"
echo "#!/bin/bash
# name: $scriptName.sh
# description: this file was autogenerated by the https://github.com/jhosvr/dontstarvetogether repository's setup script

fail() {
  echo \"Error: \${1} >&2\"
  exit 1
}

fileSearch() {
  if [ ! -e \"\${1}\" ]; then
    fail Missing file: \"\${1}\"
  fi
}

cd \"$dir_cmd\" || fail \"Missing $dir_cmd directory!\"

fileSearch steamcmd.sh
fileSearch \"${dir_dstserver}/cluster.ini\"
fileSearch \"${dir_dstserver}/cluster_token.txt\"
fileSearch \"${dir_dstserver}/Master/server.ini\"
fileSearch \"${dir_dstserver}/Caves/server.ini\"

# Update DST via steam cmd
./steamcmd.sh +force_install_dir \"${dir_dst}\" +login anonymous +app_update 343050 validate +quit

# Source the mods list and generate necessary mod configs
${dir_dstserver}/generate_mod_configs.sh

# Find DST binaries
fileSearch \"${dir_dstserver}/bin\"
cd \"${dir_dstserver}/bin\" || fail \"could not find ${dir_dstserver}/bin\"

# Start DST
run_shared=(./dontstarve_dedicated_server_nullrenderer)
run_shared+=(-console)
run_shared+=(-cluster \"$cluster_name\")
run_shared+=(-monitor_parent_process \$\$)

\${run_shared[@]} -shard Caves  | sed 's/^/Caves:  /' &
\${run_shared[@]} -shard Master | sed 's/^/Master: /'
" > "${startScript}"
chmod +x "${startScript}"
}

