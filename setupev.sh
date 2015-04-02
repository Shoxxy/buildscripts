#!/bin/bash

A_TOP=${PWD}
CUR_DIR=`dirname $0`
DATE=$(date +%D)
MACHINE_TYPE=`uname -m`
CM_VERSION=12.0

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
        echo -e "${txtred}Please run this script as root."
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
    apt-get install openjdk-7-jdk
}

install_arch_packages()
{
    # x86_64
    pacman -S jdk7-openjdk jre7-openjdk jre7-openjdk-headless perl git gnupg flex bison gperf zip unzip sdl wxgtk \
    squashfs-tools ncurses libpng zlib libusb libusb-compat readline schedtool \
    optipng python2 perl-switch lib32-zlib lib32-ncurses lib32-readline \
    gcc-libs-multilib gcc-multilib lib32-gcc-libs binutils-multilib libtool-multilib
}

install_ubuntu_packages()
{
    # x86_64 
    apt-get update       
    apt-get install bison build-essential curl flex git-core git curl gnupg gperf libesd0-dev \
    libncurses5-dev libsdl1.2-dev libwxgtk2.8-dev libxml2 libxml2-utils libc6-dev x11proto-core-dev \
    lzop pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 \
    libgl1-mesa-dev  mingw32 tofrodos python-markdown libxml2-utils xsltproc zlib1g-dev:i386 \
    g++-multilib gcc-multilib lib32ncurses5-dev lib32readline-gplv2-dev lib32z1-dev 
}

prepare_environment()
{
    echo "Which 64-bit distribution are you running?"
    echo "1) Ubuntu 11.04"
    echo "2) Ubuntu 11.10"
    echo "3) Ubuntu 12.04"
    echo "4) Ubuntu 12.10"
    echo "5) Skip"
    # echo "6) Debian"
    read -n1 distribution
    echo -e "\r\n"

    case $distribution in
    "1")
        # Ubuntu 11.04
        echo "Installing packages for Ubuntu 11.04"
        install_sun_jdk
        apt-get install git-core gnupg flex bison gperf build-essential \
        zip curl zlib1g-dev libc6-dev lib32ncurses5-dev ia32-libs \
        x11proto-core-dev libx11-dev lib32readline5-dev lib32z-dev \
        libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown \
        libxml2-utils xsltproc libx11-dev:i386
        ;;
    "2")
        # Ubuntu 11.10
        echo "Installing packages for Ubuntu 11.10"
        install_sun_jdk
        apt-get install git-core gnupg flex bison gperf build-essential \
        zip curl zlib1g-dev libc6-dev lib32ncurses5-dev ia32-libs \
        x11proto-core-dev libx11-dev lib32readline5-dev lib32z-dev \
        libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown \
        libxml2-utils xsltproc libx11-dev:i386
        ;;
    "3")
        # Ubuntu 12.04
        echo "Installing packages for Ubuntu 12.04"
        install_sun_jdk
        install_ubuntu_packages
        ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
        ;;
    "4")
        # Ubuntu 12.10
        echo "Installing packages for Ubuntu 12.10"
        install_sun_jdk
        install_ubuntu_packages
        ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
        ;;
    "5")
        # Skip
        echo "Skiping Packages"
        ;;
    "6")
        # Debian
        echo "Installing packages for Debian"
        apt-get update
        apt-get install git-core gnupg flex bison gperf build-essential \
        zip curl libc6-dev lib32ncurses5 libncurses5-dev x11proto-core-dev \
        libx11-dev libreadline6-dev lib32readline-gplv2-dev libgl1-mesa-glx \
        libgl1-mesa-dev g++-multilib mingw32 openjdk-6-jdk tofrodos \
        python-markdown libxml2-utils xsltproc zlib1g-dev pngcrush \
        libcurl4-gnutls-dev comerr-dev krb5-multidev libcurl4-gnutls-dev \
        libgcrypt11-dev libglib2.0-dev libgnutls-dev libgnutls-openssl27 \
        libgnutlsxx27 libgpg-error-dev libgssrpc4 libgstreamer-plugins-base0.10-dev \
        libgstreamer0.10-dev libidn11-dev libkadm5clnt-mit8 libkadm5srv-mit8 \
        libkdb5-6 libkrb5-dev libldap2-dev libp11-kit-dev librtmp-dev libtasn1-3-dev \
        libxml2-dev tofrodos python-markdown lib32z-dev ia32-libs
        ln -s /usr/lib32/libX11.so.6 /usr/lib32/libX11.so
        ln -s /usr/lib32/libGL.so.1 /usr/lib32/libGL.so
        ;;
        
    *)
        # No distribution
        echo -e "${txtred}No distribution set. Aborting."
        echo -e "\r\n ${txtrst}"
        exit
        ;;
    esac
    
    echo "Do you want us to get android sources for you? (y/n)"
    read -n1 sources
    echo -e "\r\n"

    case $sources in
    "Y" | "y")
        echo "Choose a branch:"
        echo "1) cm-7 (gingerbread)"
        echo "2) cm-9 (ics)"
        echo "3) cm-10 (jellybean mr0)"
        echo "4) cm-10.1 (jellybean mr1)"
	echo "5) cm-11.0 (kit-kat)"
        echo "6) cm-12.1 (lollipop)"
        read -n1 branch
        echo -e "\r\n"

        case $branch in
            "1")
                # cm-7
                branch="gingerbread"
                ;;
            "2")
                # cm-9
                branch="ics"
                ;;
            "3")
                # cm-10
                branch="jellybean"
                ;;
            "4")
                # cm-10.1
                branch="cm-10.1"
                ;;
	    "5")
		# cm-11.0
		branch="cm-11.0"
		;;
            "6")
                # cm-12.0
                branch="cm-12.1"
                ;;
            *)
                # no branch
                echo -e "${txtred}No branch choosen. Aborting."
                echo -e "\r\n ${txtrst}"
                exit
                ;;
        esac

        echo "Enter Target Directory (~/android/CM12):"
        read working_directory

        if [ ! -n $working_directory ]; then 
            working_directory="$HOME/android/CM12"
        fi

        echo "Installing to $working_directory"
        
        if [ ! -d $HOME/bin ]; then
            mkdir -p $HOME/bin
        fi
        
        export PATH=~/bin:$PATH
        curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
        chmod a+x ~/bin/repo
        source ~/.profile
        repo selfupdate
        
        mkdir -p $working_directory
        cd $working_directory
        repo init -u git://github.com/CyanogenMod/android.git -b $branch
        mkdir -p $working_directory/.repo/local_manifests
        touch $working_directory/.repo/local_manifests/roomservice.xml
        curl https://raw.githubusercontent.com/Hrubak/buildscripts/$branch/my_manifest.xml > $working_directory/.repo/local_manifests/roomservice.xml
        repo sync -j12
        echo "Sources synced to $working_directory. Use $working_directory autobuild.sh to start building CyanogenMod"        
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
