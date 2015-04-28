PSWD=`cat ~/android/pswd.txt`

cd ~/android/CM12/out/target/product/ls990/ 
echo "uploading file to AndroidFileHost.com"
curl -T cm-*.zip -u ${PSWD} ftp://uploads.fl1.androidfilehost.com --ftp-create-dirs
cd ../../../..


