Hrubak buildscripts
============

PureNexus buildscipt

Use setupev.sh to setup your build environment
```
cd ~
touch setupev.sh
curl https://raw.githubusercontent.com/Hrubak/buildscripts/PureNexus/setupev.sh > setupev.sh
chmod a+x setupev.sh
sudo ./setupev.sh
```

Then just follow the prompts :)

or if you have a build environment already setup:
```
mkdir -p .repo/local_manifests
touch .repo/local_manifests/roomservice.xml
curl https://raw.githubusercontent.com/Hrubak/buildscripts/PureNexus/my_manifest.xml > .repo/local_manifests/roomservice.xml
repo sync
```
Build PureNexus
==================
```
cd ~/android/PureNexus
. autobuild.sh
```
also you can set the device
```
. autobuild.sh angler
```
will build a Nexus 6P rom named PureNexus-{date}-EXPERIMENTAL-angler.zip

If you want to use my auto patch script add (device)-tools to your roomservice.xml
ie: 
```
<project name="Hrubak/angler-tools.git" path="angler-tools" remote="github" revision="n" />
```


There are some NOOB steps left out... you have some edits to make on your own!
