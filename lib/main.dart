import 'dart:io';
import 'package:path_provider/path_provider.dart' as p;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

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
    dio = Dio();
    super.initState();
  }

  Future <List<Directory>?> _getExternalStoragePath(){
    return p.getExternalStorageDirectories(type: p.StorageDirectory.documents);
  }

  Future _downloadAndSaveFileToStorage(
      BuildContext context, String urlPath, String fileName) async {
    ProgressDialog pr;
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(message: "Download file ...");

    try{
      //================== show dialog ==================
      await pr.show();

      final dirList = await _getExternalStoragePath();
      final path = dirList![0].path;
      final file = File('$path/$fileName');
      await dio!.download(urlPath, file.path, onReceiveProgress: (rec, total){
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

      _fileFullPath = file.path;
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
              RaisedButton(
                child: Text('Download to External Storage'),
                onPressed: () {
                  _downloadAndSaveFileToStorage(
                    context, urlPdf, "document2.pdf");
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
