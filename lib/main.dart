import 'dart:io';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path/path.dart' as p;
import 'package:ftpconnect/src/commands/file.dart';
import 'package:archive/archive_io.dart';

String remoteDir = './public_html/ftptestfiles'; // my server directory

final FTPConnect _ftpConnect = new FTPConnect(
  "cpanel.ptiszai.com",
  user: "ptiszai",
  pass: "nWdVDSxufP6F",
  securityType: SecurityType.FTP,
  showLog: false,
);

Future<void> _log(String log) async {
  print(log);
  await Future.delayed(Duration(seconds: 1));
}

// Uploading file
Future<bool> _uploadWithRetry(
    String dirRemote_a, String dir_src_a, String fileName_a,
    {FileProgress? onProgress}) async {
  try {
    File fileToUpload = File('${dir_src_a}/$fileName_a');
    String fileNameRemote = '${dirRemote_a}/$fileName_a';
    //  String fileNameRemote = './public_html/objectsDetector/${fileName_a}';
    await _log('Ti:Uploading ...');
    bool res = await _ftpConnect.connect();
    if (!res) {
      throw Exception('not connected');
    }
    await _ftpConnect.setTransferType(TransferType.binary);
    res = await _ftpConnect.uploadFileWithRetry(fileToUpload,
        pRemoteName: fileNameRemote, pRetryCount: 2, onProgress: onProgress);
    await _log('Ti:file uploaded: ' + (res ? 'SUCCESSFULLY' : 'FAILED'));
    await _ftpConnect.setTransferType(TransferType.auto);
    await _ftpConnect.disconnect();
    return true;
  } catch (e) {
    await _ftpConnect.setTransferType(TransferType.auto);
    await _ftpConnect.disconnect();
    await _log('Ti:Uploading FAILED: ${e.toString()}');
    return false;
  }
}

// Downloading filw
Future<bool> _downloadWithRetry(
    String dirRemote_a, String dir_dest_a, String fileName_a,
    {FileProgress? onProgress}) async {
  try {
    bool res;
    String fileNameRemote = '${dirRemote_a}/${fileName_a}';
    res = await _ftpConnect.connect();
    if (!res) {
      throw Exception('not connected');
    }
    await _ftpConnect.setTransferType(TransferType.binary);
    res = await _ftpConnect.existFile(fileNameRemote);
    if (!res) {
      await _log('Ti:file not exist: ${fileNameRemote}');
      return false;
    }
    int _size = await _ftpConnect.sizeFile(fileNameRemote);
    if (_size < 0) {
      throw Exception('size -1');
    }
    await _log('Ti:file _size: ${_size} byte');
    File downloadedFile = File('${dir_dest_a}/$fileName_a');
    res = await _ftpConnect.downloadFileWithRetry(
        fileNameRemote, downloadedFile,
        onProgress: onProgress, pRetryCount: 2);
    if (!res) {
      throw Exception('1');
    }
    await _ftpConnect.setTransferType(TransferType.auto);
    await _ftpConnect.disconnect();
    return true;
  } catch (e) {
    await _ftpConnect.setTransferType(TransferType.auto);
    await _ftpConnect.disconnect();
    await _log('Ti:Downloading FAILED: ${e.toString()}');
    return false;
  }
}

// Change directory
Future<bool> changeDirectory(String dirName_a) async {
  try {
    await _ftpConnect.changeDirectory(dirName_a);
    return true;
  } catch (e) {
    await _ftpConnect.disconnect();
    await _log('Ti:changeDirectoryFAILED: ${e.toString()}');
    return false;
  }
}

// Get directory file name list.
Future<List<String>?> listDirectoryFilenames(String dirName_a) async {
  List<String>? res;
  try {
    await _ftpConnect.connect();
    bool _res = await changeDirectory(dirName_a);
    if (!_res) {
      throw Exception('Ti:changeDirectory');
    }
    res = await _ftpConnect.listDirectoryContentOnlyNames();
    await _ftpConnect.disconnect();
    return res;
  } catch (e) {
    await _ftpConnect.disconnect();
    await _log('Ti:Downloading FAILED: ${e.toString()}');
    return null;
  }
}

// Unzip
Future<bool> Unzip(String fullfilename_src, String fullfilename_dest) async {
  try {
    final inputStream = InputFileStream(fullfilename_src);
    final archive = ZipDecoder().decodeBuffer(inputStream);
    for (var file in archive.files) {
      // If it's a file and not a directory
      if (file.isFile) {
        final outputStream =
            OutputFileStream('${p.current}/test/unzip/${file.name}');
        file.writeContent(outputStream);
        outputStream.close();
      }
    }
    return true;
  } catch (e) {
    await _log('Ti:Unzip: ${e.toString()}');
    return false;
  }
}

// Zip
Future<bool> Zip(
    List<String> fullfilenameList_src, String fullfilename_dest) async {
  try {
    var encoder = ZipFileEncoder();
    encoder.create(fullfilename_dest);
    fullfilenameList_src.forEach((item) {
      encoder.addFile(File(item));
    });
    encoder.close();
    return true;
  } catch (e) {
    await _log('Ti:Zip: ${e.toString()}');
    return false;
  }
}

/////
///// MAIN()
/////
void main() async {
// Downloading
  FileProgress progressDown =
      (double progressInPercent, int totalReceived, int fileSize) {
    print(
        "Ti:progressInPercent:$progressInPercent, totalReceived:$totalReceived, fileSizel:$fileSize");
  };

  bool result = await _downloadWithRetry(
      remoteDir, '${p.current}/test/in', 'dentskanload.gif',
      onProgress: progressDown);
  if (!result) {
    await _log('Ti:Downloading 1. BAD.');
    return;
  }
  await _log(
      'Ti:Downloading SUCCESS dentskanload.gif.---------------------------------------------------.');

  result = await _downloadWithRetry(
      remoteDir, '${p.current}/test/in', 'downloadfileToCompress.txt',
      onProgress: progressDown);
  if (!result) {
    await _log('Ti:Downloading 1. BAD.');
    return;
  }
  await _log(
      'Ti:Downloading SUCCESS downloadfileToCompress.txt.---------------------------------------------------.');

  result = await _downloadWithRetry(
      remoteDir, '${p.current}/test/in', 'downloadfile.zip',
      onProgress: progressDown);
  if (!result) {
    await _log('Ti:Downloading 2. BAD.');
    return;
  }
  await _log(
      'Ti:Downloading SUCCESS dentskanload.zip.---------------------------------------------------.');

  result = await _downloadWithRetry(
      remoteDir, '${p.current}/test/in', 'downloadfileToCompress.zip',
      onProgress: progressDown);
  if (!result) {
    await _log('Ti:Downloading 2. BAD.');
    return;
  }
  await _log(
      'Ti:Downloading SUCCESS downloadfileToCompress.zip.---------------------------------------------------.');

  // Unzip.
  result = await Unzip('${p.current}/test/in/downloadfileToCompress.zip',
      '${p.current}/test/in/downloadfileToCompress.txt');
  if (!result) {
    await _log('Ti:Unzip BAD.');
    return;
  } else {
    await _log(
        'Ti:Unzip SUCCESS: ${p.current}/test/in/downloadfileToCompress.txt---------------------------------------------------.');
  }

  result = await Unzip('${p.current}/test/in/downloadfile.zip',
      '${p.current}/test/in/dentskanload.gif');
  if (!result) {
    await _log('Ti:Unzip BAD.');
    return;
  } else {
    await _log(
        'Ti:Unzip SUCCESS: ${p.current}/test/in/dentskanload.gif---------------------------------------------------.');
  }

  // Uploading
  FileProgress progressUp =
      (double progressSendedPercent, int totalSended, int fileSize) {
    print(
        "Ti:progressSendedPercent:$progressSendedPercent, totalReceived:$totalSended, fileSize:$fileSize");
  };

  result = await _uploadWithRetry(
      remoteDir, '${p.current}/test/out', 'uploadfileToCompress.txt',
      onProgress: progressUp);
  if (!result) {
    await _log('Ti:Uploading 1 BAD.');
  }

  result = await _uploadWithRetry(
      remoteDir, '${p.current}/test/out', 'upload-background.jpg',
      onProgress: progressUp);
  if (!result) {
    await _log('Ti:Uploading 2 BAD.');
  }

  // Zip.
  result = await Zip([
    '${p.current}/test/out/upload-background.jpg',
    '${p.current}/test/out/uploadfileToCompress.txt'
  ], '${p.current}/test/out/uploadfiles.zip');
  if (!result) {
    await _log('Ti:Zip BAD.');
    return;
  } else {
    await _log('Ti:Zip SUCCESS: ${p.current}/test/out/uploadfiles.zip');
    result = await _uploadWithRetry(
        remoteDir, '${p.current}/test/out', 'uploadfiles.zip',
        onProgress: progressUp);
    if (!result) {
      await _log('Ti:Uploading 3 BAD.');
    }
  }

  // List file name
  List<String>? filelist = await listDirectoryFilenames(remoteDir);

  print("Ti:listDirectoryFilenames:$filelist!");
  await _log('Ti:Exit');
}
