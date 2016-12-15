#!/bin/bash

A_TOP=${PWD}
CUR_DIR=`dirname $0`
DATE=$(date +%D)
MACHINE_TYPE=`uname -m`
CM_VERSION=14.1

# Common defines (Arch-dependent)
case `uname -s` in
    Darwin)
        txtrst='\033[0m'  # Color off
        txtred='\033[0;31m' # Red
        txtgrn='\033[0;32m' # Green
        txtylw='\033[0;33m' # Yellow
        txtblu='\033[0;34m' # Blue
        THREADS=`sysctl -an hw.logicalcpu`
        ;;
    *)
        txtrst='\e[0m'  # Color off
        txtred='\e[0;31m' # Red
        txtgrn='\e[0;32m' # Green
        txtylw='\e[0;33m' # Yellow
        txtblu='\e[0;34m' # Blue
        THREADS=`cat /proc/cpuinfo | grep processor | wc -l`
        ;;
esac

check_root() {
    if [ ! $( id -u ) -eq 0 ]; then
        echo -e "${txtred}Please run this script as SU (root)."
        echo -e "\r\n ${txtrst}"
        exit
    fi
}

check_machine_type() {
    echo "Checking machine architecture..."
    if [ ${MACHINE_TYPE} == 'x86_64' ]; then
        echo -e "${txtgrn}Detected: ${MACHINE_TYPE}. Good!"
        echo -e "\r\n ${txtrst}"
    else
        echo -e "${txtred}Detected: ${MACHINE_TYPE}. Bad!"
        echo -e "${txtred}Sorry, we do only support building on 64-bit machines."
        echo -e "${txtred}32-bit is soooo 1970, consider a upgrade. ;-)"
        echo -e "\r\n ${txtrst}"
        exit
    fi
}

install_sun_jdk()
{
    apt-get update
    apt-get install openjdk-8-jdk
}

install_arch_packages()
{
    # x86_64
    pacman -S jdk7-openjdk jre7-openjdk jre7-openjdk-headless perl git gnupg flex bison gperf zip unzip sdl wxgtk \
    squashfs-tools ncurses libpng zlib libusb libusb-compat readline schedtool \
    optipng python2 perl-switch lib32-zlib lib32-ncurses lib32-readline \
    gcc-libs-multilib gcc-multilib lib32-gcc-libs binutils-multilib libtool-multilib
}

prepare_environment()
{
    echo "Which 64-bit distribution are you running?"
    echo "1) Ubuntu 16.04"
    echo "2) Skip"
    # echo "6) Debian"
    read -n1 distribution
    echo -e "\r\n"

    case $distribution in
    "1")
        # Ubuntu 16.04
        echo "Installing packages for Ubuntu 16.04 LTS"
	sudo apt-get install -y git-core bc bison build-essential curl flex git gnupg gperf libesd0-dev liblz4-tool \
	libncurses5-dev libsdl1.2-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop maven openjdk-8-jdk pngcrush \
	schedtool squashfs-tools xsltproc zip zlib1g-dev g++-multilib gcc-multilib lib32ncurses5-dev \
	lib32readline6-dev lib32z1-dev libc6-dev-i386 x11proto-core-dev libx11-dev lib32z-dev ccache \
	libgl1-mesa-dev libxml2-utils xsltproc unzip
        ;;
    *)
        # No distribution
        echo -e "${txtred}No distribution set. Aborting."
        echo -e "\r\n ${txtrst}"
        exit
        ;;
    esac
    
    echo "Do you want ADB setup? (y/n)"
    read -n1 adb
    echo -e "\r\n"
    
    case $adb in
    "Y" | "y")
        if [ ! "$(which adb)" == "" ];
        then
        echo Setting up USB Ports
        sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/snowdream/51-android/master/51-android.rules
        sudo chmod 644   /etc/udev/rules.d/51-android.rules
        sudo chown root /etc/udev/rules.d/51-android.rules
        sudo service udev restart
        adb kill-server
        sudo killall adb
        fi
        ;;
    "N" | "n")
        # nothing to do
        ;;
    esac
    
    echo "Do you want us to get android sources for you? (y/n)"
    read -n1 sources
    echo -e "\r\n"

    case $sources in
    "Y" | "y")
        echo "Choose a branch:"
        echo "1) cm-14.1"
        read -n1 branch
        echo -e "\r\n"

        case $branch in
            "1")
                # Nougaut
                branch="cm-14.1"
                ;;
            *)
                # no branch
                echo -e "${txtred}No branch choosen. Aborting."
                echo -e "\r\n ${txtrst}"
                ;;
        esac
	
        echo "Enter Target Directory (~/android/CM14.1):"
        read working_directory
        if [ -z $working_directory ]; then
            working_directory="~/android/CM14.1"
        fi
	if [ -d $working_directory ]; then
	echo "Good it exists, moving on"
	fi
	if [ ! -d $working_directory ]; then
	mkdir -p $working_directory
	fi
        echo "Installing to $working_directory"
        
        if [ ! -d $HOME/bin ]; then
            mkdir -p $HOME/bin
        fi
        
        export PATH=~/bin:$PATH
        curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
        chmod a+x ~/bin/repo
        source ~/.profile
        
        cd $working_directory
        repo init -u git://github.com/CyanogenMod/android.git -b $branch
        repo selfupdate
        mkdir -p $working_directory/.repo/local_manifests
        touch $working_directory/.repo/local_manifests/roomservice.xml
        curl https://raw.githubusercontent.com/Hrubak/buildscripts/$branch/my_manifest.xml > $working_directory/.repo/local_manifests/roomservice.xml
        repo sync -j16
        echo "Sources synced to $working_directory. Use $working_directory autobuild.sh to start building CM14.1"        
        exit
        ;;
    "N" | "n")
        # nothing to do
        exit
        ;;
    esac
}

echo -e "${txtylw} #####################################################################"
echo -e "${txtylw} \r\n"
echo -e "${txtylw}         _    _ ___   _   _  ___           _  __   "
echo -e "${txtylw}        | |  | |  _ \| | | |  _  \   /\   | |/ /   "
echo -e "${txtylw}        | |__| | |_| | | | | |_| /  /  \  | ' /    "
echo -e "${txtylw}        |  __  |    /| | | |  _ |  / /\ \ |  <     "
echo -e "${txtylw}        | |  | | |\ \| |_| | |_| \/ ____ \| . \    "
echo -e "${txtylw}        |_|  |_|_| \_\ ____/|____/_/    \_\_|\_\   "
echo -e "${txtylw} \r\n"
echo -e "${txtgrn}    CyanogenMod ${CM_VERSION} build environment setup script${txtrst}"
echo -e "${txtylw}"                             
echo -e "${txtylw} \r\n"
echo -e "${txtylw} ######################################################################"
echo -e "\r\n ${txtrst}"


        check_root
        check_machine_type
        prepare_environment
