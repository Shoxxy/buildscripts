#!/bin/bash
#to use run . build.sh {device}
#example:/$ . build angler


# Lets set some variables

CM_VERSION=14.1
CMD="${1}"
ROOT=CM14.1							#folder name of your source ie: 'system'
DIR=~/${ROOT}							#Set Working Dir
OUT=$DIR/out/target/product/${CMD}
NOW=`date +%s`
DATE=$(date +%D)
MACHINE_TYPE=`uname -m`

# Common defines (Arch-dependent)
case `uname -s` in
    Darwin)
        txtrst='\033[0m' # Color off
        txtred='\033[0;31m' # Red
        txtgrn='\033[0;32m' # Green
        txtylw='\033[0;33m' # Yellow
        txtblu='\033[0;34m' # Blue
        THREADS=`sysctl -an hw.logicalcpu`
        ;;
    *)
        txtrst='\e[0m' # Color off
        txtred='\e[0;31m' # Red
        txtgrn='\e[0;32m' # Green
        txtylw='\e[0;33m' # Yellow
        txtblu='\e[0;34m' # Blue
        THREADS=`cat /proc/cpuinfo | grep processor | wc -l`
        ;;
esac


# Get things up to date :)
	repo_sync()
	{
		repo abandon auto
		echo -e "${txtylw}Syncing Source...${txtrst}"
		repo sync
		echo "Files Synced"
	}
	
#Get PreBuilts and apply Patches
	extras()
	{
		# Apply patches
		if [ -f ${CMD}-tools/apply.sh ]; then
			echo -e "${txtylw}Applying patches...${txtrst}"
			${CMD}-tools/apply.sh
			MESG=$?
			
			echo -e "${txtgrn}EXIT PASS : ${MESG}${txtrst}"
		else
			repo abandon auto
		fi		
	}

# Setting up Build Environment
	env_setup()
	{    
		cd $DIR
		echo -e "${txtgrn}Setting up Build Environment...${txtrst}"
		. build/envsetup.sh
	}
	
# Set Build Target
	target()
	{
		lunch ${lunch}
	}

# Lets start buildin
   	 build_it()
	{
		echo -e "${txtgrn}Building Android...${txtrst}"
        brunch ${brunch}
	}	

#Make the MD5SUM
	md5_sum()
	{
                echo -e "${txtgrn}Generating md5sum...${txtrst}"
		cd $OUT
			for FILE in *${CMD}*.zip; do     
				md5sum $FILE > ${FILE}.md5sum
			echo -e "${txtblu}Generated md5sum...done.${txtrst}"
			done
	}

#check for build target
	target()
	{
		if [ -z "${CMD}" ]; then
        		echo -e "${txtred}No build target set."
       			echo -e "${txtred}Usage: ./autobuild.sh angler (complete build)"
        		echo -e "${txtred}       ./autobuild.sh angler foo (Custom Release Version)"
        		echo -e "${txtred}       ./autobuild.sh clean"
        		echo -e "${txtred}       ./autobuild.sh clobber (Clobber)"
        		echo -e "\r\n ${txtrst}"
        		echo -e "${txtgrn}Target device? (angler):${txtrst}"
			read CMD

			if [ "$CMD" = "" ]; then
			CMD=angler
			fi
		fi
	}

#check for working Dir
	workingdir()
	{
		if [ ! -d "$DIR" ]; then
        		echo -e "${txtred}Custom Working Dir set."
       			echo -e "${txtred}Edit autobuild.sh and set ROOT=Path_to_your_Source"
        		echo -e "${txtred}or whatever your source dir is"
        		echo -e "\r\n ${txtrst}"
        		echo -e "${txtgrn}Source Dir? (PureNexus):${txtrst}"
			read ROOT

			if [ "$ROOT" = "" ]; then
				ROOT=CM14.1
			fi
		else
			echo -e "${txtgrn}Working_dir=${DIR} ${txtrst}"
		fi
	}
	
#Remove Patches
	clear_patch()
	{
		repo abandon auto
	}
	
#Put it all in to action!
	main()
	{
	target
echo -e "${txtblu} #####################################################################"
echo -e "${txtblu} \r\n"
echo -e "${txtblu}         _    _ ___   _   _  ___           _  __   "
echo -e "${txtblu}        | |  | |  _ \| | | |  _  \   /\   | |/ /   "
echo -e "${txtblu}        | |__| | |_| | | | | |_| /  /  \  | ' /    "
echo -e "${txtblu}        |  __  |    /| | | |  _ |  / /\ \ |  <     "
echo -e "${txtblu}        | |  | | |\ \| |_| | |_| \/ ____ \| . \    "
echo -e "${txtblu}        |_|  |_|_| \_\ ____/|____/_/    \_\_|\_\   "
echo -e "${txtblu} \r\n"
echo -e "${txtylw}          CyanogenMod ${CM_VERSION} ${CMD} buildscript${txtrst}"
echo -e "${txtblu}"                             
echo -e "${txtblu} \r\n"
echo -e "${txtblu} ######################################################################"
echo -e "\r\n ${txtrst}"

# Starting Timer
START=$(date +%s)
env_setup

# Run script specific settings
	case "${CMD}" in
		clobber)
			make clobber
			exit
			;;
		clean)
			mka clean
			rm -rf ./out/target/product
			exit
			;;
		upload)
			upload
			exit
			;;
		*)
			lunch=${CMD}-userdebug
			brunch=${lunch}
			;;
	esac
		
		
	export USE_CCACHE=1 USE_NINJA=true #OUT_DIR_COMMON_BASE=


	echo -e "${txtred}Do you want to MAKE clean? (y/n/clobber)[y]${txtrst}"
		read -t10 clean
		echo -e "\r\n"
	if [ -z $clean ]; then
		clean=y
	fi
	
	case $clean in
		"Y" | "y")
			echo -e "${txtylw}Making $OUT Clean${txtrst}"
			mka clean
	        	rm -rf ./out/target/product
			;;
		"clobber")
			echo -e "${txtylw}Clobber all the THINGS!!!${txtrst}"
			make clobber
			;;
		"N" | "n")
			echo -e "${txtblu}Dirty Build!~!~!~!${txtrst}"
			# Continue
			;;
	esac
	
		repo_sync
		target
		extras
		build_it
		rm $OUT/*${CMD}-ota*.zip
		clear_patch
		md5_sum
		echo -e "${txtgrn}Build Complete...!!${txtrst}"
		cd $DIR
	}

#Start Up...
if [ ! -d "${DIR}" ]; then
workingdir
DIR=~/android/${ROOT}
fi
cd $DIR
echo -e "${txtylw}Starting build script ${Pure_VERSION} ${CMD}${txtrst}"
if [ -z "${RELVER}" ]; then
main
else
echo "Release Ver? = "${RELVER}
main
fi

END=$(date +%s)
ELAPSED=$((END - START))
E_MIN=$((ELAPSED / 60))
E_SEC=$((ELAPSED - E_MIN * 60))
printf "${txtgrn}Elapsed: "
[ $E_MIN != 0 ] && printf "%d min(s) " $E_MIN
printf "%d sec(s)\n ${txtrst}" $E_SEC

upload
