#!/bin/bash

VERS="v2.0"

# Required Packages for Debian/Ubuntu
DebianPackages=('build-essential' 'upx' 'cmake' 'libuv1-dev' 'libssl-dev' 'libhwloc-dev' 'screen' 'p7zip-full')

# Required Packages for Alpine
AlpinePackages=('build-base' 'cmake' 'libuv-dev' 'openssl-dev' 'hwloc-dev' 'screen' 'p7zip')

# Setup Variables
BUILD=0
DEBUG=0
STATIC=0
SCRIPT="$(readlink -f "$0")"
SCRIPTFILE="$(basename "$SCRIPT")"
SCRIPTPATH="$(dirname "$SCRIPT")"
SCRIPTNAME="$0"
ARGS=( "$@" )
BRANCH="master"

# Detect Package Manager
if command -v apk &> /dev/null; then
    PM="apk"
    PackagesArray=("${AlpinePackages[@]}")
elif command -v apt &> /dev/null; then
    PM="apt"
    PackagesArray=("${DebianPackages[@]}")
else
    echo "Unsupported package manager. Exiting."
    exit 1
fi

# Usage Example Function
usage_example() {
  echo -e "\e[32m=================================================="
  echo -e "==================================================\e[39m"
  echo -e "\e[33m XMRig Build Script $VERS\e[39m"
  echo
  echo -e "\e[33m by ToRxmrig\e[39m"
  echo
  echo -e "\e[32m=================================================="
  echo -e "==================================================\e[39m"
  echo
  echo " Usage:  xmrig-build [-dhs] -<0|7|8>"
  echo
  echo "    -0 | 0 | <blank>      - x86-64"
  echo "    -7 | 7                - ARMv7"
  echo "    -8 | 8                - ARMv8"
  echo
  echo "    -s | s                - Build Static"
  echo
  echo "    -h | h                - Display (this) Usage Output"
  echo "    -d | d                - Enable Debug Output"
  echo
  exit 0
}

# Flag Processing Function
flags() {
  ([ "$1" = "-h" ] || [ "$1" = "h" ]) && usage_example
  ([ "$2" = "-h" ] || [ "$2" = "h" ]) && usage_example
  ([ "$3" = "-h" ] || [ "$3" = "h" ]) && usage_example
  ([ "$4" = "-h" ] || [ "$4" = "h" ]) && usage_example

  ([ "$1" = "d" ] || [ "$1" = "-d" ]) && DEBUG=1
  ([ "$2" = "d" ] || [ "$2" = "-d" ]) && DEBUG=1
  ([ "$3" = "d" ] || [ "$3" = "-d" ]) && DEBUG=1

  ([ "$1" = "-s" ] || [ "$1" = "s" ]) && STATIC=1
  ([ "$2" = "-s" ] || [ "$2" = "s" ]) && STATIC=1
  ([ "$3" = "-s" ] || [ "$3" = "s" ]) && STATIC=1

  ([ "$1" = "7" ] || [ "$1" = "-7" ]) && BUILD=7
  ([ "$2" = "7" ] || [ "$2" = "-7" ]) && BUILD=7
  ([ "$3" = "7" ] || [ "$3" = "-7" ]) && BUILD=7

  ([ "$1" = "8" ] || [ "$1" = "-8" ]) && BUILD=8
  ([ "$2" = "8" ] || [ "$2" = "-8" ]) && BUILD=8
  ([ "$3" = "8" ] || [ "$3" = "-8" ]) && BUILD=8
}

# Script Update Function
self_update() {
  echo -e "\e[33mStatus:\e[39m"

  # Ensure we are in the script directory
  cd "$SCRIPTPATH" || { echo "Error: Cannot change to directory $SCRIPTPATH"; exit 1; }

  # Check if the directory is a Git repository
  if [ ! -d ".git" ]; then
    echo -e "\e[31mError: Not a Git repository.\e[39m"
    return 1
  fi

  # Fetch updates from the remote repository
  timeout 1s git fetch --quiet
  if [ $? -ne 0 ]; then
    echo -e "\e[31mError: Failed to fetch updates.\e[39m"
    return 1
  fi

  # Check if there are differences between the local file and the remote branch
  timeout 1s git diff --quiet --exit-code "origin/master" "$SCRIPTFILE"
  if [ $? -ne 0 ]; then
    echo -e "\e[31m  ✗ Version: Mismatched.\e[39m"
    echo

    # Fetch update
    echo -e "\e[33mFetching Update:\e[39m"
    if [ -n "$(git status --porcelain)" ]; then
      echo -e "\e[33mStashing local changes...\e[39m"
      git stash push -m 'local changes stashed before self update' --quiet
      if [ $? -ne 0 ]; then
        echo -e "\e[31mError: Failed to stash local changes.\e[39m"
        return 1
      fi
    fi

    git pull --force --quiet
    if [ $? -ne 0 ]; then
      echo -e "\e[31mError: Failed to pull updates.\e[39m"
      return 1
    fi

    # Checkout to the specified branch
    git checkout "$BRANCH" --quiet
    if [ $? -ne 0 ]; then
      echo -e "\e[31mError: Failed to checkout branch $BRANCH.\e[39m"
      return 1
    fi

    # Pull latest changes for the branch
    git pull --force --quiet
    if [ $? -ne 0 ]; then
      echo -e "\e[31mError: Failed to pull updates for branch $BRANCH.\e[39m"
      return 1
    fi

    echo -e "\e[33m  ✓ Update: Complete.\e[39m"
    echo
    echo -e "\e[33mLaunching New Version. Standby...\e[39m"
    sleep 3

    # Return to the original working directory and execute the script
    cd - > /dev/null || { echo "Error: Cannot return to the original directory"; exit 1; }
    exec "$SCRIPTNAME" "${ARGS[@]}"
    
    # Exit the old instance
    exit 1
  else
    echo -e "\e[33m  ✓ Version: Current.\e[39m"
    echo
  fi
}

# Package Check/Install Function
packages() {
  install_pkgs=" "
  for keys in "${!PackagesArray[@]}"; do
    REQUIRED_PKG=${PackagesArray[$keys]}
    if [ "$PM" = "apt" ]; then
      PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
    elif [ "$PM" = "apk" ]; then
      PKG_OK=$(apk info | grep $REQUIRED_PKG)
    fi
    if [ "" = "$PKG_OK" ]; then
      echo -e "\e[31m  ✗ $REQUIRED_PKG: Not Found.\e[39m"
      install_pkgs+=" $REQUIRED_PKG"
    else
      echo -e "\e[33m  ✓ $REQUIRED_PKG: Found.\e[39m"
    fi
  done
  if [ " " != "$install_pkgs" ]; then
    echo
    echo -e "\e[33mInstalling Packages:\e[39m"
    if [ $DEBUG -eq 1 ]; then
      $PM --dry-run add $install_pkgs
    else
      if [ "$PM" = "apt" ]; then
        apt install -y $install_pkgs
      elif [ "$PM" = "apk" ]; then
        apk add $install_pkgs
      fi
    fi
  fi
}

# Error Trapping with Cleanup
errexit() {
  # Draw 5 lines of + and message
  for i in {1..5}; do echo "+"; done
  echo -e "\e[91mError raised! Cleaning Up and Exiting.\e[39m"

  # Remove _source directory if found.
  if [ -d "$SCRIPTPATH/_source" ]; then rm -r $SCRIPTPATH/_source; fi

  # Remove xmrig directory if found.
  if [ -d "$SCRIPTPATH/xmrig" ]; then rm -r $SCRIPTPATH/xmrig; fi

  # Dirty Exit
  exit 1
}

# Phase Header
phaseheader() {
  echo
  echo -e "\e[32m=======================================\e[39m"
  echo -e "\e[35m- $1..."
  echo -e "\e[32m=======================================\e[39m"
}

# Phase Footer
phasefooter() {
  echo -e "\e[32m=======================================\e[39m"
  echo -e "\e[35m $1 Completed"
  echo -e "\e[32m=======================================\e[39m"
  echo
}

# Intro/Outro Header
inoutheader() {
  echo -e "\e[32m=================================================="
  echo -e "==================================================\e[39m"
  echo -e "\e[33m XMRig Build Script $VERS\e[39m"

  [ $BUILD -eq 7 ] && echo -ne "\e[33m for ARMv7\e[39m" && [ $STATIC -eq 1 ] && echo -e "\e[33m (static)\e[39m"
  [ $BUILD -eq 8 ] && echo -ne "\e[33m for ARMv8\e[39m" && [ $STATIC -eq 1 ] && echo -e "\e[33m (static)\e[39m"
  [ $BUILD -eq 0 ] && echo -ne "\e[33m for x86-64\e[39m" && [ $STATIC -eq 1 ] && echo -e "\e[33m (static)\e[39m"
  echo

  echo -e "\e[33m by ToRxmrig\e[39m"
  echo
  echo -e "\e[32m=================================================="
  echo -e "==================================================\e[39m"
}

# Intro/Outro Footer
inoutfooter() {
  echo
  echo -e "\e[32m=================================================="
  echo -e "==================================================\e[39m"
  echo -e "\e[33mBuild Script Complete\e[39m"
  echo
  echo -e "\e[33m by ToRxmrig\e[39m"
  echo
  echo -e "\e[32m=================================================="
  echo -e "==================================================\e[39m"
}

# Pre-Build Backup
backup() {
  if [ -d "$SCRIPTPATH/xmrig" ]; then
    echo
    echo -e "\e[33mPrior Build Found:\e[39m"
    echo -e "\e[33mBackup in Progress.\e[39m"
    rm -f xmrig-bkp.7z
    7za a xmrig-bkp.7z xmrig/ > /dev/null
    rm -r xmrig/
  fi
}

# Clone Repo, Build/Compile
compile() {
  cd $SCRIPTPATH
  echo -e "\e[33mCloning Repo:\e[39m"
  git clone https://github.com/ToRxmrig/xmrig --depth 1

  phaseheader "Installing Submodules"
  cd xmrig
  git submodule update --init --depth 1
  phasefooter "Installing Submodules"

  phaseheader "Building XMRig"
  mkdir build
  cd build

  if [ $BUILD -eq 7 ]; then
    cmake .. -DWITH_EMBEDDED_CONFIG=ON -DCMAKE_BUILD_TYPE=Release -DENABLE_HWLOC=ON -DWITH_HWLOC=ON -DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchains/armv7-linux-gnueabihf.cmake
    make -j$(nproc)
  elif [ $BUILD -eq 8 ]; then
    cmake .. -DWITH_EMBEDDED_CONFIG=ON -DCMAKE_BUILD_TYPE=Release -DENABLE_HWLOC=ON -DWITH_HWLOC=ON -DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchains/aarch64-linux-gnu.cmake
    make -j$(nproc)
  else
    cmake .. -DWITH_EMBEDDED_CONFIG=ON -DCMAKE_BUILD_TYPE=Release -DENABLE_HWLOC=ON -DWITH_HWLOC=ON
    make -j$(nproc)
  fi
  phasefooter "Building XMRig"
}

# Package Final Binary
package() {
cd $SCRIPTPATH/xmrig/build
upx -9 -o sbin xmrig
cp ./sbin /root/sbin
chmod +x /root/sbin

  echo -e "\e[33mCompressing Build:\e[39m"
  7za a xmrig.7z *
  mv xmrig.7z $SCRIPTPATH/
  cd $SCRIPTPATH
}

# Cleanup
cleanup() {
  echo -e "\e[33mCleaning Up...\e[39m"
  rm -rf "$SCRIPTPATH/xmrig"
}

# Set Flags
flags "$@"

# Display Header
inoutheader

# Perform Script Self-Update
self_update

# Install Required Packages
packages

# Perform Backup of Prior Build
backup

# Perform Compilation
compile

# Package Binary
package

# Cleanup Afterward
cleanup

# Display Footer
inoutfooter
