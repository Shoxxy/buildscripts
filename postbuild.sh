PSWD=`cat ~/android/pswd.txt`

cd ~/android/CM14.1/out/target/product/angler/ 
echo "uploading file to AndroidFileHost.com"
curl -T cm-*.zip -u ${PSWD} ftp://uploads.fl1.androidfilehost.com --ftp-create-dirs
cd ../../../..


