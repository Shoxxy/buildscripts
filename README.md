Hrubak buildscripts
============

CyanogenMod buildscipt

Use setupev.sh to setup your build environment
```
cd ~
touch setupev.sh
curl https://raw.github.com/hrubak/buildscripts/cm-11.0/setupev.sh > setupev.sh
chmod a+x setupev.sh
sudo ./setupev.sh
```

Then just follow the prompts :)

Build CyanogenMod
==================
```
cd ~/android/CM11
. autobuild.sh
```
also you can set the device and add a releasename
```
. autobuild.sh d2vzw test
```
will build a a GalaxySIII Verizon rom named cm-11.0-{date}-EXPERIMENTAL-d2vzw-test.zip

If you want to use my auto patch script add (device)-tools to your roomservice.xml
ie: 
```
<project name="Hrubak/d2vzw-tools.git" path="d2vzw-tools" remote="github" revision="cm11.0" />
```


