#!/bin/bash
#to use run . build.sh {device} {extra outputname}
#example:/$ . build d2spr ImAdEtHiS


# Lets set some variables

CM_VERSION=10.1
CMD="${1}"
CMROOT=system								#folder name of your CM source ie: 'system'
DIR=~/android/${CMROOT}							#Set Working Dir
OUT=$DIR/out/target/product/${CMD}
NOW=`date +%s`
RELVER="${2}"								#Name our build
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
		echo -e "${txtylw}Syncing Source...${txtrst}"
		repo sync -j24
		echo "Files Synced"
	}
	
#Get PreBuilts and apply Patches
	extras()
	{
		# Apply patches
		if [ -f ${CMD}-tools/apply.sh ]; then
			echo -e "${txtylw}Applying patches...${txtrst}"
			${CMD}-tools/apply.sh
		else
			repo abandon auto
		fi		
		# Get prebuilts once per day
			prebuilts=$(cat prebuilts.log)
		if [ "$DATE" != "$prebuilts" ]; then
			echo -e "${txtylw}Downloading prebuilts...${txtrst}"
			pushd vendor/cm
			./get-prebuilts
			popd
        echo $DATE > prebuilts.log
		fi

	}

# Setting up Build Environment
	env_setup()
	{    
		cd $DIR
		echo -e "${txtgrn}Setting up Build Environment...${txtrst}"
		. build/envsetup.sh
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
			for FILE in ${CM_VERSION}*${CMD}*.zip; do     
				md5sum $FILE > ${FILE}.md5sum
			echo -e "${txtblu}Generated md5sum...done.${txtrst}"
			done
	}

# Upload maybe?
	post_process()
	{
        	cp $OUT/${CM_VERSION}*${CMD}*.zip $UPLOAD/
		cp $OUT/${CM_VERSION}*${CMD}*.zip.md5sum $UPLOAD/
		echo "Files Copied to Web Folder"
		cmupdater
	}		


#check for build target
	target()
	{
		if [ -z "${CMD}" ]; then
        		echo -e "${txtred}No build target set."
       			echo -e "${txtred}Usage: ./autobuild.sh d2spr (complete build)"
        		echo -e "${txtred}       ./autobuild.sh d2spr foo (Custom Release Version)"
        		echo -e "${txtred}       ./autobuild.sh clean"
        		echo -e "${txtred}       ./autobuild.sh clobber (Clobber)"
        		echo -e "\r\n ${txtrst}"
        		echo -e "${txtgrn}Target device? (d2spr):${txtrst}"
			read CMD

			if [ "$CMD" = "" ]; then
			CMD=d2spr
			fi
		fi
	}

#check for working Dir
	workingdir()
	{
		if [ ! -d "$DIR" ]; then
        		echo -e "${txtred}Custom Working Dir set."
       			echo -e "${txtred}Edit autobuild.sh and set CROOT=Path_to_your_Source"
        		echo -e "${txtred}or whatever your CM source dir is"
        		echo -e "\r\n ${txtrst}"
        		echo -e "${txtgrn}Source Dir? (CM10):${txtrst}"
			read CMROOT

			if [ "$CMROOT" = "" ]; then
				CMROOT=CM10
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

# Run script specific settings
	case "${CMD}" in
		clobber)
			make clobber
			exit
			;;
		clean)
			make clean
			rm -rf ./out/target/product
			exit
			;;
		*)
			lunch=cm_${CMD}-userdebug
			brunch=${lunch}
			;;
	esac
		
		
	export USE_CCACHE=1 CM_EXPERIMENTAL=1 CM_EXTRAVERSION=${RELVER} CM_FAST_BUILD=1 #OUT_DIR_COMMON_BASE=


	echo -e "${txtred}Do you want to MAKE clean? (y/n/clobber)[y]${txtrst}"
		read -n1 clean
		echo -e "\r\n"
	if [ -z $clean ]; then
		clean=y
	fi
	
	case $clean in
		"Y" | "y")
			echo -e "${txtylw}Making $OUT Clean${txtrst}"
			make clean
	        	rm -rf ./out/target/product
			;;
		clobber)
			echo -e "${txtylw}Clobber all the THINGS!!!${txtrst}"
			make clobber
			;;
		"N" | "n")
			echo -e "${txtblu}Dirty Build!~!~!~!${txtrst}"
			# Continue
			;;
	esac
		repo_sync
		env_setup
		extras
		build_it
		rm $OUT/*${CMD}-ota*.zip
		md5_sum
		echo -e "${txtgrn}Build Complete...!!${txtrst}"
		cd $DIR
		cd ..
	}

#Start Up...
if [ ! -d "${DIR}" ]; then
workingdir
DIR=~/android/${CMROOT}
fi
cd $DIR
echo -e "${txtylw}Starting build script ${CM_VERSION} ${CMD}${txtrst}"
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
