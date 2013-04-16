Hrubak buildscripts
============

CyanogenMod buildscipt

Use setupev.sh to setup your build environment
```
cd ~
touch setupev.sh
curl https://raw.github.com/hrubak/buildscripts/cm-10.1/setupev.sh > setupev.sh
chmod a+x setupev.sh
. setupev.sh
```

Then just follow the prompts :)

Build CyanogenMod
==================
```
cd ~/android/system
. autobuild.sh
```


