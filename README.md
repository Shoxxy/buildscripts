Hrubak buildscripts
============

CyanogenMod buildscipt

Use setupev.sh to setup your build environment
```
cd ~
touch setupev.sh
curl https://raw.github.com/hrubak/buildscripts/cm-10.2/setupev.sh > setupev.sh
chmod a+x setupev.sh
sudo ./setupev.sh
```

Then just follow the prompts :)

Build CyanogenMod
==================
```
cd ~/android/CM10
. autobuild.sh
```
also you can set the device and add a releasename
```
. autobuild.sh d2vzw test
```
will build a a GalaxySIII Verizon rom named cm-10.2-{date}-EXPERIMENTAL-d2vzw-test.zip

