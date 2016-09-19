#!/bin/bash

A_TOP=${PWD}
CUR_DIR=`dirname $0`
DATE=$(date +%D)
MACHINE_TYPE=`uname -m`
Pure_VERSION=n

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
    echo "1) Ubuntu 14.04"
    echo "2) Ubuntu 16.04"
    echo "5) Skip"
    # echo "6) Debian"
    read -n1 distribution
    echo -e "\r\n"

    case $distribution in
    "1")
        # Ubuntu 14.04
        echo "Installing packages for Ubuntu 12.04"
        sudo apt-add-repository ppa:openjdk-r/ppa -y
        sudo apt-get update
        sudo apt-get -y install git-core python gnupg flex bison gperf libsdl1.2-dev libesd0-dev libwxgtk2.8-dev \
        squashfs-tools build-essential zip curl libncurses5-dev zlib1g-dev openjdk-8-jre openjdk-8-jdk pngcrush \
        schedtool libxml2 libxml2-utils xsltproc lzop libc6-dev schedtool g++-multilib lib32z1-dev lib32ncurses5-dev \
        gcc-multilib liblz4-* pngquant ncurses-dev texinfo gcc gperf patch libtool \
        automake g++ gawk subversion expat libexpat1-dev python-all-dev binutils-static bc libcloog-isl-dev \
        libcap-dev autoconf libgmp-dev build-essential gcc-multilib g++-multilib pkg-config libmpc-dev libmpfr-dev lzma* \
        liblzma* w3m android-tools-adb maven ncftp figlet
        sudo install utils/repo /usr/bin/
        sudo install utils/ccache /usr/bin/
        ;;
    "2")
        # Ubuntu 16.04
        echo "Installing packages for Ubuntu 16.04"
        sudo apt install -y software-properties-common
        sudo apt-add-repository ppa:openjdk-r/ppa -y
        sudo apt update -y
        sudo apt install git-core python gnupg flex bison gperf libsdl1.2-dev libesd0-dev \
        squashfs-tools build-essential zip curl libncurses5-dev zlib1g-dev openjdk-8-jre openjdk-8-jdk pngcrush \
        schedtool libxml2 libxml2-utils xsltproc lzop libc6-dev schedtool g++-multilib lib32z1-dev lib32ncurses5-dev \
        gcc-multilib liblz4-* pngquant ncurses-dev texinfo gcc gperf patch libtool \
        automake g++ gawk subversion expat libexpat1-dev python-all-dev bc libcloog-isl-dev \
        libcap-dev autoconf libgmp-dev build-essential gcc-multilib g++-multilib pkg-config libmpc-dev libmpfr-dev lzma* \
        liblzma* w3m android-tools-adb maven ncftp htop -y
        makeversion=$(make -v | head -1 | awk '{print $3}')
        if [ ! "${makeversion}" == "3.81" ];
        then
        echo "Installing make 3.81 instead of ${makeversion}"
        sudo install utils/make /usr/bin/
        fi
        sudo install utils/repo /usr/bin/
        sudo install utils/ccache /usr/bin/
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
        exit
        ;;
    esac
    
    echo "Do you want us to get android sources for you? (y/n)"
    read -n1 sources
    echo -e "\r\n"

    case $sources in
    "Y" | "y")
        echo "Choose a branch:"
        echo "1) Nougut"
        read -n1 branch
        echo -e "\r\n"

        case $branch in
            "1")
                # Nougaut
                branch="n"
                ;;
            *)
                # no branch
                echo -e "${txtred}No branch choosen. Aborting."
                echo -e "\r\n ${txtrst}"
                exit
                ;;
        esac

        echo "Enter Target Directory (~/android/PureNexus):"
        read working_directory

        if [ ! -n $working_directory ]; then 
            working_directory="$HOME/android/PureNexus"
        fi

        echo "Installing to $working_directory"
        
        if [ ! -d $HOME/bin ]; then
            mkdir -p $HOME/bin
        fi
        
        export PATH=~/bin:$PATH
        curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
        chmod a+x ~/bin/repo
        source ~/.profile
        repo selfupdate
        
        mkdir -p $working_directory
        cd $working_directory
        repo init -u https://github.com/PureNexusProject/manifest.git -b $branch
        mkdir -p $working_directory/.repo/local_manifests
        touch $working_directory/.repo/local_manifests/roomservice.xml
        curl https://raw.githubusercontent.com/Hrubak/buildscripts/$branch/my_manifest.xml > $working_directory/.repo/local_manifests/roomservice.xml
        repo sync -j12
        echo "Sources synced to $working_directory. Use $working_directory autobuild.sh to start building PureNexus"        
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
echo -e "${txtgrn}    PureNexus ${Pure_VERSION} build environment setup script${txtrst}"
echo -e "${txtylw}"                             
echo -e "${txtylw} \r\n"
echo -e "${txtylw} ######################################################################"
echo -e "\r\n ${txtrst}"


        check_root
        check_machine_type
        prepare_environment
