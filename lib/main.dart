import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

void main() => runApp(FileWatcherApp());

class FileWatcherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فایل‌های جدید',
      theme: ThemeData.dark(),
      home: FileListScreen(),
    );
  }
}

class FileListScreen extends StatefulWidget {
  @override
  _FileListScreenState createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  final List<String> files = [];
  late final channel;

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect(Uri.parse('ws://178.63.171.244:5000'));

    channel.stream.listen((message) {
      final data = json.decode(message);
      if (data['type'] == 'new_file') {
        setState(() {
          files.add(data['name']);
        });
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('فایل‌های جدید')),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final fileName = files[index];
          final fileUrl = 'http://10.0.2.2:3001/files/$fileName';

          return ListTile(
            leading: fileName.endsWith('.png') || fileName.endsWith('.jpg')
                ? Image.network(fileUrl, width: 50, height: 50, fit: BoxFit.cover)
                : Icon(Icons.insert_drive_file),
            title: Text(fileName),
            onTap: () {
              if (fileName.endsWith('.png') || fileName.endsWith('.jpg')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageViewerScreen(imageUrl: fileUrl),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewerScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('نمایش تصویر')),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
