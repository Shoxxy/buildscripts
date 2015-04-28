Hrubak buildscripts
============

CyanogenMod buildscipt

Use setupev.sh to setup your build environment
```
cd ~
touch setupev.sh
curl https://raw.githubusercontent.com/Hrubak/buildscripts/cm-12.1/setupev.sh > setupev.sh
chmod a+x setupev.sh
sudo ./setupev.sh
```

Then just follow the prompts :)

or if you have a build environment already setup:
```
mkdir -p .repo/local_manifests
touch .repo/local_manifests/roomservice.xml
curl https://raw.githubusercontent.com/Hrubak/buildscripts/cm-12.1/my_manifest.xml > .repo/local_manifests/roomservice.xml
repo sync
```
Build CyanogenMod
==================
```
cd ~/android/CM12
. autobuild.sh
```
also you can set the device
```
. autobuild.sh ls990
```
will build a a LG G3 Sprint rom named cm-12.1-{date}-EXPERIMENTAL-ls990.zip

If you want to use my auto patch script add (device)-tools to your roomservice.xml
ie: 
```
<project name="Hrubak/ls990-tools.git" path="ls990-tools" remote="github" revision="cm12.1" />
```


There are some NOOB steps left out... you have some edits to make on your own!
