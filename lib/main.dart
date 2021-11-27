import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:progress_dialog/progress_dialog.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

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
  final urlPdf = "http://www.pdf995.com/samples/pdf.pdf";

  Dio? dio;

  @override
  void initState() {
    createFolder('KGTesting');
    dio = Dio();
    super.initState();
  }

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

  // Future _downloadAndSaveFileToStorage(String urlPath) async {

  //   final name = urlPdf.split('/').last;

  //   ProgressDialog pr;
  //   pr = ProgressDialog(context, type: ProgressDialogType.Normal);
  //   pr.style(message: "Download file ...");

  //   try{
  //     await pr.show();
  //     final Directory _documentDir = Directory('/storage/emulated/0/MyDocuments/$name');
  //     await dio!.download(urlPath, _documentDir.path, onReceiveProgress: (rec, total){
  //       setState(() {
  //         _isLoading = true;
  //         progress = ((rec / total)*100).toStringAsFixed(0) + " %";
  //         print(progress);
  //         pr.update(message: "Please wait : $progress");
  //       });
  //     });
  //     pr.hide();
  //     _fileFullPath = _documentDir.path;
  //   } catch (e) {
  //     print(e);
  //   }

  //   setState(() {
  //     _isLoading = false;
  //   });

  // }

  // Future _downloadAndSaveFileToStorage(String urlPath) async {

  //   final name = urlPdf.split('/').last;

  //   ProgressDialog pd = ProgressDialog(context: context);

  //   try{
  //     pd.show(
  //       max: 100, 
  //       msg: 'Preparing Download...', 
  //       progressType: ProgressType.valuable
  //     );
  //     final Directory _documentDir = Directory('/storage/emulated/0/KGDocuments/$name');
  //     await dio!.download(urlPath, _documentDir.path, onReceiveProgress: (rec, total){
  //       setState(() {
  //         _isLoading = true;
  //         int progress = (((rec / total) * 100).toInt());
  //         print(progress);
  //         pd.update(value: progress, msg: 'File Downloading');
  //       });
  //     });
  //     pd.close();
  //     _fileFullPath = _documentDir.path;
  //   } catch (e) {
  //     print(e);
  //   }

  //   setState(() {
  //     _isLoading = false;
  //   });

  // }

  Future _downloadAndSaveFileToStorage(String urlPath) async {

    final name = urlPdf.split('/').last;

    ProgressDialog pd = ProgressDialog(context: context);

    try{

      await pd.show(
        max: 100,
        msg: 'Preparing Download...',
        progressType: ProgressType.valuable,
        backgroundColor: Color(0xff212121),
        progressValueColor: Color(0xff3550B4),
        progressBgColor: Colors.white70,
        msgColor: Colors.white,
        valueColor: Colors.white
      );

      final Directory _documentDir = Directory('/storage/emulated/0/MYDocuments/$name');
      await dio!.download(urlPath, _documentDir.path, onReceiveProgress: (rec, total){
        setState(() {
          _isLoading = true;
          int progress = (((rec / total) * 100).toInt());
          print(progress);
          pd.update(value: progress, msg: 'File Downloading');
        });
      });
      _fileFullPath = _documentDir.path;
    } catch (e) {
      print(e);
      pd.close();
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