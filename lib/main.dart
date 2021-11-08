import 'dart:io';
import 'package:path_provider/path_provider.dart' as p;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Downloader PDF',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  String? _fileFullPath;
  String? progress;
  bool _isLoading = false;
  // final urlPdf = "http://www.pdf995.com/samples/pdf.pdf";
  final urlPdf = "https://kg.bisakode.com/api/dokumen/4/download";

  Dio? dio;

  @override
  void initState() {
    createFolder('KGTesting');
    dio = Dio();
    super.initState();
  }

  //================================Buat Folder Download==============================
  Future<String> createFolder(String fName) async {
    final folderName = fName;
    final path = Directory("storage/emulated/0/$folderName");
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();
    }
    if ((await path.exists())) {
      return path.path;
    } else {
      path.create();
      return path.path;
    }
  }

  //=========================Get App Direktory==========================================
  // Future <List<Directory>?> _getExternalStoragePath(){
  //   return p.getExternalStorageDirectories(type: p.StorageDirectory.documents);
  // }

  //================================ Downloader Document====================================
  Future _downloadAndSaveFileToStorage(String urlPath) async {

    final name = urlPdf.split('/').last;

    ProgressDialog pr;
    pr = ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(message: "Download file ...");

    try{

      //================== show dialog ==================
      await pr.show();

      // final dirList = await _getExternalStoragePath();
      // final path = dirList![0].path;
      // final file = File('$path/$name');

      final Directory _documentDir = Directory('/storage/emulated/0/KGTesting/$name');

      // await dio!.download(urlPath, file.path, onReceiveProgress: (rec, total){
      await dio!.download(urlPath, _documentDir.path, onReceiveProgress: (rec, total){
        setState(() {
          _isLoading = true;
          progress = ((rec / total)*100).toStringAsFixed(0) + " %";
          print(progress);

          //================= update dialog ===============
          pr.update(message: "Please wait : $progress");
        });
      });

      //============== hide dialog ==============
      pr.hide();

      _fileFullPath = _documentDir.path;
      
    } catch (e) {
      print(e);
    }

    setState(() {
      _isLoading = false;
    });

  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download And ProgressDialog'),
      ),
      body: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('Download to External Storage'),
                onPressed: () {
                  _downloadAndSaveFileToStorage(urlPdf);
                },
              ),
              Text('Writen: $_fileFullPath'),
            ],
          ),
        ),
      ),
    );
  }

}