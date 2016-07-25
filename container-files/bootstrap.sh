#!/bin/sh
set -eu
export TERM=xterm
# Agent ConfigFile
CONFIG_FILE="/usr/local/etc/zabbix_agentd.conf"
# Bash Colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
white=`tput setaf 7`
bold=`tput bold`
reset=`tput sgr0`
separator=$(echo && printf '=%.0s' {1..100} && echo)
# Logging Finctions
log() {
  if [[ "$@" ]]; then echo "${bold}${green}[LOG `date +'%T'`]${reset} $@"; else echo; fi
}
### Magic Starts here
update_config() {
    log "Updating configuration file..."
    if [[ "$ZABBIX_SERVER" != "127.0.0.1" ]]; then
      log "Changing Zabbix Server IP to ${bold}${white}${ZABBIX_SERVER}${reset}"
      sed -i 's/Server=127.0.0.1/Server='$ZABBIX_SERVER'/g' ${CONFIG_FILE}
    fi
    if [[ "$HOSTNAME" != "" ]]; then
      log "Changing Zabbix Hostname to ${bold}${white}${HOSTNAME}${reset}."
      sed -i 's/Hostname=Zabbix server/Hostname='$HOSTNAME'/g' ${CONFIG_FILE}
    else
      log "Changing Zabbix Hostname to ${bold}${white}$(cat /etc/hostname)${reset}."
      sed -i 's/Hostname=Zabbix server/Hostname='$(cat /etc/hostname)'/g' ${CONFIG_FILE}
    fi
    if [[ "$HOST_METADATA" != "zabbix.agent" ]]; then
      log "Changing Zabbix Host Metadata to ${bold}${white}${HOST_METADATA}${reset}."
      sed -i 's/# HostMetadata=/HostMetadata='$HOST_METADATA'/g' ${CONFIG_FILE}
    fi

    ##### Zabbix psk conf #####
    if [[ "$ZABBIX_PSK" == "yes" ]]; then
      log "Updating Zabbix psk configuration..."

      log "Changing Zabbix TLSConnect to ${bold}${white}psk${reset}."
      sed -i 's/# TLSConnect=/TLSConnect=psk/g' ${CONFIG_FILE}

      log "Changing Zabbix TLSAccept to ${bold}${white}psk${reset}."
      sed -i 's/# TLSAccept=/TLSAccept=psk/g' ${CONFIG_FILE}

      log "Changing Zabbix TLSPSKIdentity to ${bold}${white}${HOSTNAME}${reset}."
      sed -i 's/# TLSPSKIdentity=/TLSPSKIdentity='$HOSTNAME'/g' ${CONFIG_FILE}

      ##### First run #####
      if [[ ! -f /home/zabbix/zabbix_agentd.psk ]]; then
	log "Generating rand hex..."
        RAND_HEX=`date +%s | sha256sum | base64 | head -c 32`
        echo $RAND_HEX > /home/zabbix/zabbix_agentd.psk
        log "GENERATED ZABBIX RAND HEX to ${bold}${white}${RAND_HEX}${reset}."

        log "Changing Zabbix TLSPSKFile to ${bold}${white}/home/zabbix/zabbix_agentd.psk${reset}."
        sed -i 's/# TLSPSKFile=/TLSPSKFile=\/home\/zabbix\/zabbix_agentd.psk/g' ${CONFIG_FILE}
      fi
    fi
    log "Config updated"
}
print_config() {
  log "Current Zabbix Agent config ${CONFIG_FILE}:"
  printf '=%.0s' {1..100} && echo
  cat ${CONFIG_FILE}
  echo ""
  printf '=%.0s' {1..100} && echo
}
start() {
    log "Starting Zabbix Agent using configuration file: ${CONFIG_FILE}"
    print_config
    zabbix_agentd -f -c ${CONFIG_FILE}
}

if [[ $(grep "million12/zabbix-agent" ${CONFIG_FILE}) ]]; then
    log "Loading default config."
    update_config
    start
else
    log "Loading custom config: ${CONFIG_FILE}"
    start
fi



















# start_agent() {
#   zabbix_agentd -f -c ${CONFIG_FILE}
# }
# if [[ $ZABBIX_SERVER != "127.0.0.1" ]]; then
#   log "Changing Zabbix Server IP to ${bold}${white}${ZABBIX_SERVER}${reset}."
#   sed -i 's/Server=127.0.0.1/Server='$ZABBIX_SERVER'/g' ${CONFIG_FILE}
# fi
# log "Startting agent..."
# log `start_agent`
