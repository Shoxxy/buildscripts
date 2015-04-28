echo -n "Enter password: "; read PSWD

cd ~/android/CM12/out/target/product/ls990/ 
curl -T cm-*.zip -u hrubak:${PSWD} ftp://uploads.fl1.androidfilehost.com --ftp-create-dirs
cd ../../../..

