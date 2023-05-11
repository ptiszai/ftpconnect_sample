# Flutter FTP Connect sample only on Windows.
This sample is based on  [ftp_connect](https://github.com/salim-lachdhaf/dartFTP).<br>
and  [Zip and Unzip](https://pub.dev/packages/archive)<br>

```bash
1.)
final FTPConnect _ftpConnect = new FTPConnect(
  "xxxx.com",       <-- overwriting the new host name
  user: "yyyyyy",   <-- overwriting the new user name
  pass: "pppppppp", <-- overwriting the new pasword name
  securityType: SecurityType.FTP,
  showLog: false,
);
2.)
String remoteDir = './public_html/ftptestfiles'; <-- overwriting the new remote diractory
3.)
copy thefiles from ./test/ftptestfiles/* to './public_html/ftptestfiles' with Ftp or other.
4.)
run.
Downloading 'dentskanload.gif' to './test/in/*'
Downloading 'downloadfileToCompress.txt' to ./test/in/*'
Downloading 'downloadfile.zip' to ./test/in/*'
Downloading 'downloadfileToCompress.zip' to ./test/in/*'
Unziping 'downloadfileToCompress.zip' to './test/in/downloadfileToCompress.txt'
Unziping 'downloadfile.zip' to './test/in/dentskanload.gif'
Uploading './test/out/uploadfileToCompress.txt' to './public_html/ftptestfiles'
Uploading './test/out/upload-background.jpg' to './public_html/ftptestfiles'
Ziping '/test/out/upload-background.jpg'and '/test/out/uploadfileToCompress.txt' to '/test/out/uploadfiles.zip'
Uploading './test/out/uploadfiles.zip' to './public_html/ftptestfiles'
Listing the remote server direction.
```<br>
