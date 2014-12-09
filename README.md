Hrubak buildscripts
============

CyanogenMod buildscipt

Use setupev.sh to setup your build environment
```
cd ~
touch setupev.sh
curl https://raw.github.com/hrubak/buildscripts/cm-12.0/setupev.sh > setupev.sh
chmod a+x setupev.sh
sudo ./setupev.sh
```

Then just follow the prompts :)

or if you have a build environment already setup:
```
mkdir -p .repo/local_manifests
touch .repo/local_manifests/roomservice.xml
curl https://raw.githubusercontent.com/Hrubak/buildscripts/cm-12.0/my_manifest.xml > .repo/local_manifests/roomservice.xml
repo sync
```
Build CyanogenMod
==================
```
cd ~/android/CM12
. autobuild.sh
```
also you can set the device and add a releasename
```
. autobuild.sh d2vzw test
```
will build a a GalaxySIII Verizon rom named cm-12.0-{date}-EXPERIMENTAL-d2vzw-test.zip

If you want to use my auto patch script add (device)-tools to your roomservice.xml
ie: 
```
<project name="Hrubak/d2vzw-tools.git" path="d2vzw-tools" remote="github" revision="cm12.0" />
```


There are some NOOB steps left out... you have some edits to make on your own!
